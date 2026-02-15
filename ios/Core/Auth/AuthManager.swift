//
//  AuthManager.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import Foundation
import SwiftUI
import Combine

enum AuthState {
    case signedOut
    case confirmingSignUp(email: String, password: String)
    case onboarding(email: String, password: String)
    case signedIn
}

enum AuthError: Error, LocalizedError {
    case signUpFailed(String)
    case confirmationFailed(String)
    case signInFailed(String)
    case tokenRefreshFailed(String)
    case resetPasswordFailed(String)
    case notSignedIn
    
    var errorDescription: String? {
        switch self {
        case .signUpFailed(let msg): return msg
        case .confirmationFailed(let msg): return msg
        case .signInFailed(let msg): return msg
        case .tokenRefreshFailed(let msg): return msg
        case .resetPasswordFailed(let msg): return msg
        case .notSignedIn: return "Not signed in"
        }
    }
}

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var authState: AuthState = .signedOut
    @Published var currentUserId: String?
    
    var isAuthenticated: Bool {
        if case .signedIn = authState { return true }
        return false
    }
    
    private let cognitoEndpoint = "https://cognito-idp.\(CognitoConfig.region).amazonaws.com"
    private let session = URLSession.shared
    
    private init() {
        if let token = getAccessToken(), !token.isEmpty {
            authState = .signedIn
            currentUserId = extractSubFromToken(token)
        }
    }
    
    // MARK: - Token Management
    
    func getAccessToken() -> String? {
        return KeychainHelper.read(.accessToken)
    }
    
    private func saveTokens(accessToken: String, idToken: String, refreshToken: String) {
        KeychainHelper.save(accessToken, for: .accessToken)
        KeychainHelper.save(idToken, for: .idToken)
        KeychainHelper.save(refreshToken, for: .refreshToken)
        
        let userId = extractSubFromToken(idToken)
        
        DispatchQueue.main.async {
            self.authState = .signedIn
            self.currentUserId = userId
        }
    }
    
    private func clearTokens() {
        KeychainHelper.deleteAll()
        DispatchQueue.main.async {
            self.authState = .signedOut
            self.currentUserId = nil
        }
    }
    
    // MARK: - Cognito HTTP API
    
    private func callCognito(target: String, payload: [String: Any]) async throws -> [String: Any] {
        guard let url = URL(string: cognitoEndpoint) else {
            throw AuthError.signInFailed("Invalid Cognito endpoint")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-amz-json-1.1", forHTTPHeaderField: "Content-Type")
        request.setValue("AWSCognitoIdentityProviderService.\(target)", forHTTPHeaderField: "X-Amz-Target")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.signInFailed("Invalid response")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AuthError.signInFailed("Failed to parse response")
        }
        
        if httpResponse.statusCode != 200 {
            let type = (json["__type"] as? String) ?? "UnknownError"
            let message = (json["message"] as? String) ?? (json["Message"] as? String) ?? "Unknown error"
            let shortType = type.components(separatedBy: "#").last ?? type
            throw AuthError.signInFailed("\(shortType): \(message)")
        }
        
        return json
    }
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String) async throws {
        let payload: [String: Any] = [
            "ClientId": CognitoConfig.clientId,
            "Username": email,
            "Password": password,
            "UserAttributes": [
                ["Name": "email", "Value": email]
            ]
        ]
        
        do {
            _ = try await callCognito(target: "SignUp", payload: payload)
            DispatchQueue.main.async {
                self.authState = .confirmingSignUp(email: email, password: password)
            }
        } catch let error as AuthError {
            throw AuthError.signUpFailed(error.localizedDescription)
        } catch {
            throw AuthError.signUpFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Confirm Sign Up
    
    func confirmSignUp(email: String, code: String) async throws {
        let payload: [String: Any] = [
            "ClientId": CognitoConfig.clientId,
            "Username": email,
            "ConfirmationCode": code
        ]
        
        do {
            _ = try await callCognito(target: "ConfirmSignUp", payload: payload)
        } catch {
            throw AuthError.confirmationFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Sign In
    
    func signIn(email: String, password: String) async throws {
        let payload: [String: Any] = [
            "ClientId": CognitoConfig.clientId,
            "AuthFlow": "USER_PASSWORD_AUTH",
            "AuthParameters": [
                "USERNAME": email,
                "PASSWORD": password
            ]
        ]
        
        do {
            let json = try await callCognito(target: "InitiateAuth", payload: payload)
            
            guard let result = json["AuthenticationResult"] as? [String: Any],
                  let accessToken = result["AccessToken"] as? String,
                  let idToken = result["IdToken"] as? String,
                  let refreshToken = result["RefreshToken"] as? String else {
                throw AuthError.signInFailed("Missing tokens in auth response")
            }
            
            saveTokens(accessToken: accessToken, idToken: idToken, refreshToken: refreshToken)
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.signInFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        clearTokens()
    }
    
    // MARK: - Token Refresh
    
    func refreshTokens() async throws {
        guard let refreshToken = KeychainHelper.read(.refreshToken) else {
            throw AuthError.notSignedIn
        }
        
        let payload: [String: Any] = [
            "ClientId": CognitoConfig.clientId,
            "AuthFlow": "REFRESH_TOKEN_AUTH",
            "AuthParameters": [
                "REFRESH_TOKEN": refreshToken
            ]
        ]
        
        do {
            let json = try await callCognito(target: "InitiateAuth", payload: payload)
            
            guard let result = json["AuthenticationResult"] as? [String: Any],
                  let accessToken = result["AccessToken"] as? String,
                  let idToken = result["IdToken"] as? String else {
                throw AuthError.tokenRefreshFailed("Missing tokens in refresh response")
            }
            
            KeychainHelper.save(accessToken, for: .accessToken)
            KeychainHelper.save(idToken, for: .idToken)
            
            let userId = extractSubFromToken(idToken)
            DispatchQueue.main.async {
                self.currentUserId = userId
            }
        } catch let error as AuthError {
            throw error
        } catch {
            clearTokens()
            throw AuthError.tokenRefreshFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Reset Password
    
    func resetPassword(email: String) async throws {
        let payload: [String: Any] = [
            "ClientId": CognitoConfig.clientId,
            "Username": email
        ]
        
        do {
            _ = try await callCognito(target: "ForgotPassword", payload: payload)
        } catch {
            throw AuthError.resetPasswordFailed(error.localizedDescription)
        }
    }
    
    func confirmResetPassword(email: String, code: String, newPassword: String) async throws {
        let payload: [String: Any] = [
            "ClientId": CognitoConfig.clientId,
            "Username": email,
            "ConfirmationCode": code,
            "Password": newPassword
        ]
        
        do {
            _ = try await callCognito(target: "ConfirmForgotPassword", payload: payload)
        } catch {
            throw AuthError.resetPasswordFailed(error.localizedDescription)
        }
    }
    
    // MARK: - JWT Parsing
    
    private func extractSubFromToken(_ token: String) -> String? {
        let segments = token.split(separator: ".")
        guard segments.count >= 2 else { return nil }
        
        var base64 = String(segments[1])
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let sub = json["sub"] as? String else {
            return nil
        }
        
        return sub
    }
}
