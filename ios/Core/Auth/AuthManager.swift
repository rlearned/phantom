//
//  AuthManager.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import Foundation
import SwiftUI
import Combine
import AWSCognitoIdentityProvider

enum AuthState {
    case signedOut
    case confirmingSignUp(email: String, password: String)
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
    
    private let client: CognitoIdentityProviderClient
    
    private init() {
        let config = try! CognitoIdentityProviderClient.CognitoIdentityProviderClientConfiguration(
            region: CognitoConfig.region
        )
        self.client = CognitoIdentityProviderClient(config: config)
        
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
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String) async throws {
        let input = SignUpInput(
            clientId: CognitoConfig.clientId,
            password: password,
            userAttributes: [
                CognitoIdentityProviderClientTypes.AttributeType(name: "email", value: email)
            ],
            username: email
        )
        
        do {
            _ = try await client.signUp(input: input)
            DispatchQueue.main.async {
                self.authState = .confirmingSignUp(email: email, password: password)
            }
        } catch let error as SignUpOutputError {
            throw AuthError.signUpFailed(error.localizedDescription)
        } catch {
            throw AuthError.signUpFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Confirm Sign Up
    
    func confirmSignUp(email: String, code: String) async throws {
        let input = ConfirmSignUpInput(
            clientId: CognitoConfig.clientId,
            confirmationCode: code,
            username: email
        )
        
        do {
            _ = try await client.confirmSignUp(input: input)
        } catch {
            throw AuthError.confirmationFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Sign In
    
    func signIn(email: String, password: String) async throws {
        let input = InitiateAuthInput(
            authFlow: .userPasswordAuth,
            authParameters: [
                "USERNAME": email,
                "PASSWORD": password,
            ],
            clientId: CognitoConfig.clientId
        )
        
        do {
            let output = try await client.initiateAuth(input: input)
            
            guard let result = output.authenticationResult,
                  let accessToken = result.accessToken,
                  let idToken = result.idToken,
                  let refreshToken = result.refreshToken else {
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
        
        let input = InitiateAuthInput(
            authFlow: .refreshTokenAuth,
            authParameters: [
                "REFRESH_TOKEN": refreshToken,
            ],
            clientId: CognitoConfig.clientId
        )
        
        do {
            let output = try await client.initiateAuth(input: input)
            
            guard let result = output.authenticationResult,
                  let accessToken = result.accessToken,
                  let idToken = result.idToken else {
                throw AuthError.tokenRefreshFailed("Missing tokens in refresh response")
            }
            
            KeychainHelper.save(accessToken, for: .accessToken)
            KeychainHelper.save(idToken, for: .idToken)
            // Refresh token is not returned on refresh — keep the existing one
            
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
        let input = ForgotPasswordInput(
            clientId: CognitoConfig.clientId,
            username: email
        )
        
        do {
            _ = try await client.forgotPassword(input: input)
        } catch {
            throw AuthError.resetPasswordFailed(error.localizedDescription)
        }
    }
    
    func confirmResetPassword(email: String, code: String, newPassword: String) async throws {
        let input = ConfirmForgotPasswordInput(
            clientId: CognitoConfig.clientId,
            confirmationCode: code,
            password: newPassword,
            username: email
        )
        
        do {
            _ = try await client.confirmForgotPassword(input: input)
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
