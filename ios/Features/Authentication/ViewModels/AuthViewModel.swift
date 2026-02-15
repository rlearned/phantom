//
//  AuthViewModel.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var confirmationCode = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isPasswordVisible = false
    
    // MARK: - Remember Me (Placeholder)
    // TODO: Implement persistent "remember me" logic — store preference in UserDefaults/Keychain
    // and use it to decide whether to auto-fill credentials or keep the session alive longer.
    @Published var rememberMe: Bool = false
    
    private let authManager = AuthManager.shared
    
    var isLoginFormValid: Bool {
        !email.isEmpty && !password.isEmpty && isValidEmail(email)
    }
    
    var isSignUpFormValid: Bool {
        !email.isEmpty && !password.isEmpty &&
        !confirmPassword.isEmpty && isValidEmail(email) &&
        password == confirmPassword && password.count >= 8
    }
    
    var isConfirmationCodeValid: Bool {
        confirmationCode.count == 6
    }
    
    // MARK: - Remember Me Toggle (Placeholder)
    
    // TODO: When enabled, persist the user session so they don't need to re-enter credentials.
    func toggleRememberMe() {
        rememberMe.toggle()
        // TODO: Persist this preference
        // UserDefaults.standard.set(rememberMe, forKey: "rememberMePreference")
        // If rememberMe is true, consider extending token refresh behavior
        // If rememberMe is false, clear stored credentials on sign-out
    }
    
    // MARK: - Sign In
    
    func signIn() async {
        guard isLoginFormValid else {
            errorMessage = "Please enter valid email and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: If rememberMe is enabled, store credentials securely for auto-login
            try await authManager.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Sign Up
    
    func signUp() async {
        guard isSignUpFormValid else {
            if password != confirmPassword {
                errorMessage = "Passwords do not match"
            } else if password.count < 8 {
                errorMessage = "Password must be at least 8 characters"
            } else {
                errorMessage = "Please fill in all fields correctly"
            }
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.signUp(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Confirm Sign Up (now transitions to onboarding)
    
    func confirmSignUp() async {
        guard isConfirmationCodeValid else {
            errorMessage = "Please enter the 6-digit code"
            return
        }
        
        guard case .confirmingSignUp(let email, let password) = authManager.authState else {
            errorMessage = "No pending sign-up to confirm"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.confirmSignUp(email: email, code: confirmationCode)
            // After successful confirmation, transition to onboarding instead of auto sign-in
            DispatchQueue.main.async {
                self.authManager.authState = .onboarding(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Complete Onboarding (auto sign-in after onboarding)
    
    func completeOnboarding() async {
        guard case .onboarding(let email, let password) = authManager.authState else {
            // Fallback: if not in onboarding state, just go to sign-out
            DispatchQueue.main.async {
                self.authManager.authState = .signedOut
            }
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
            // If auto sign-in fails, redirect to login
            DispatchQueue.main.async {
                self.authManager.authState = .signedOut
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Social Sign-In Placeholders
    
    // TODO: Implement Google Sign-In using Google Sign-In SDK
    func signInWithGoogle() async {
        // TODO: Implement Google Sign-In
        print("Google Sign-In tapped — not yet implemented")
    }
    
    // TODO: Implement Apple Sign-In using AuthenticationServices
    func signInWithApple() async {
        // TODO: Implement Apple Sign-In
        print("Apple Sign-In tapped — not yet implemented")
    }
    
    // MARK: - Forgot Password
    
    func forgotPassword() async {
        guard !email.isEmpty && isValidEmail(email) else {
            errorMessage = "Please enter your email address first"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.resetPassword(email: email)
            errorMessage = "Password reset code sent to your email"
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Resend Confirmation Code
    
    func resendConfirmationCode() async {
        guard case .confirmingSignUp(let email, _) = authManager.authState else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.signUp(email: email, password: "")
        } catch {
            // Cognito will resend the code even if password is wrong for existing user
            // A dedicated resendConfirmationCode API would be cleaner
        }
        
        isLoading = false
    }
    
    // MARK: - Validation
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
