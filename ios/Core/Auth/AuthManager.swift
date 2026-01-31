//
//  AuthManager.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import Foundation
import SwiftUI
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUserId: String?
    
    private let accessTokenKey = "phantom.accessToken"
    private let userIdKey = "phantom.userId"
    
    private init() {
        // Check if user is already logged in
        if let token = getAccessToken(), !token.isEmpty {
            isAuthenticated = true
            currentUserId = UserDefaults.standard.string(forKey: userIdKey)
        }
    }
    
    // MARK: - Token Management
    
    func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: accessTokenKey)
    }
    
    func saveAccessToken(_ token: String, userId: String) {
        UserDefaults.standard.set(token, forKey: accessTokenKey)
        UserDefaults.standard.set(userId, forKey: userIdKey)
        DispatchQueue.main.async {
            self.isAuthenticated = true
            self.currentUserId = userId
        }
    }
    
    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.currentUserId = nil
        }
    }
    
    // MARK: - Authentication Methods (Mock for now)
    // TODO: Integrate AWS Amplify Cognito
    
    func signIn(email: String, password: String) async throws {
        // Mock implementation
        // In production, this would call Amplify.Auth.signIn()
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
        
        // Mock token and user ID
        let mockToken = "mock-jwt-token-\(UUID().uuidString)"
        let mockUserId = "user-\(UUID().uuidString)"
        
        saveAccessToken(mockToken, userId: mockUserId)
    }
    
    func signUp(email: String, password: String) async throws {
        // Mock implementation
        // In production, this would call Amplify.Auth.signUp()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // After sign up, automatically sign in
        try await signIn(email: email, password: password)
    }
    
    func signOut() {
        // In production, this would call Amplify.Auth.signOut()
        clearTokens()
    }
    
    func resetPassword(email: String) async throws {
        // Mock implementation
        // In production, this would call Amplify.Auth.resetPassword()
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
