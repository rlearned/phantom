//
//  SignUpView.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.phantomWhite.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Logo placeholder
                    Circle()
                        .fill(Color.phantomPurple)
                        .frame(width: 64, height: 64)
                    
                    Text("Create Account")
                        .phantomTitleStyle()
                    
                    // Sign Up Form
                    VStack(spacing: 16) {
                        TextField("Email", text: $viewModel.email)
                            .textFieldStyle(PhantomTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $viewModel.password)
                            .textFieldStyle(PhantomTextFieldStyle())
                        
                        SecureField("Confirm Password", text: $viewModel.confirmPassword)
                            .textFieldStyle(PhantomTextFieldStyle())
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.phantomBodySmall)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        PhantomButton(
                            title: viewModel.isLoading ? "Creating Account..." : "Sign Up",
                            style: .primary,
                            action: {
                                Task {
                                    await viewModel.signUp()
                                }
                            },
                            isEnabled: !viewModel.isLoading && viewModel.isSignUpFormValid,
                            fullWidth: true
                        )
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.phantomTextPrimary)
                    }
                }
            }
        }
    }
}

#Preview {
    SignUpView()
}
