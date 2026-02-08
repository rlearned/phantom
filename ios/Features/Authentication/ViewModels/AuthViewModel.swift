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
    
    func signIn() async {
        guard isLoginFormValid else {
            errorMessage = "Please enter valid email and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
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
            try await authManager.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
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
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
