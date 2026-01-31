//
//  LoginView.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showingSignUp = false
    
    var body: some View {
        ZStack {
            Color.phantomWhite.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo placeholder
                Circle()
                    .fill(Color.phantomPurple)
                    .frame(width: 64, height: 64)
                
                // App Name
                Text("Phantom")
                    .phantomTitleStyle()
                
                Text("Log the trades you didn't take")
                    .phantomSubheadlineStyle()
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // Login Form
                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(PhantomTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(PhantomTextFieldStyle())
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.phantomBodySmall)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    PhantomButton(
                        title: viewModel.isLoading ? "Signing In..." : "Sign In",
                        style: .primary,
                        action: {
                            Task {
                                await viewModel.signIn()
                            }
                        },
                        isEnabled: !viewModel.isLoading && viewModel.isLoginFormValid,
                        fullWidth: true
                    )
                    .padding(.top, 8)
                }
                
                // Sign Up Link
                Button(action: { showingSignUp = true }) {
                    Text("Don't have an account? ")
                        .font(.phantomBodyMedium)
                        .foregroundColor(.phantomTextSecondary) +
                    Text("Sign Up")
                        .font(.phantomBodyMedium)
                        .foregroundColor(.phantomPurple)
                }
                
                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
    }
}

// Custom TextField Style
struct PhantomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.phantomBodyMedium)
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.phantomTextPrimary, lineWidth: 1)
            )
    }
}

#Preview {
    LoginView()
}
