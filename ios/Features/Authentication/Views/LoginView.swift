//
//  LoginView.swift
//  Phantom
//
//  Created on 1/30/2026.
//  Redesigned on 2/15/2026 to match Figma onboarding Step 5/5.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showingSignUp = false
    
    var body: some View {
        ZStack {
            Color.phantomWhite.ignoresSafeArea()
            
            // Background blurred gradient ellipses
            backgroundGradients
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 60)
                    
                    // Content card
                    contentCard
                        .padding(.horizontal, 34)
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
    }
    
    // MARK: - Background Gradients
    
    private var backgroundGradients: some View {
        ZStack {
            // Left purple blur
            Circle()
                .fill(Color.phantomLavender)
                .frame(width: 357, height: 357)
                .blur(radius: 226)
                .offset(x: -210, y: -200)
            
            // Right purple blur
            Ellipse()
                .fill(Color.phantomLavender)
                .frame(width: 357, height: 357)
                .blur(radius: 226)
                .offset(x: 200, y: 100)
        }
    }
    
    // MARK: - Content Card
    
    private var contentCard: some View {
        VStack(spacing: 24) {
            // Headline
            headlineSection
            
            // Social sign-in buttons
            socialSignInButtons
            
            // Or divider
            orDivider
            
            // Email & Password fields
            inputFields
            
            // Remember me & Forgot password
            rememberAndForgotRow
            
            // Error message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.phantomSmall)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            // Log In button
            loginButton
            
            // Sign Up link
            signUpLink
        }
        .padding(24)
        .background(Color.phantomWhite)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
    }
    
    // MARK: - Headline
    
    private var headlineSection: some View {
        VStack(spacing: 12) {
            Text("Get Started now")
                .font(.phantomHeadlineBold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.phantomPurple,
                            Color.phantomGradientPurple,
                            Color.phantomLavender
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .multilineTextAlignment(.center)
            
            Text("Create an account or log in to explore our app")
                .font(.phantomSmall)
                .foregroundColor(.phantomGray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Social Sign-In Buttons
    
    private var socialSignInButtons: some View {
        VStack(spacing: 12) {
            // Google Sign-In
            // TODO: Implement actual Google Sign-In with Google Sign-In SDK
            Button(action: {
                Task {
                    await viewModel.signInWithGoogle()
                }
            }) {
                HStack(spacing: 10) {
                    // Google icon (using SF Symbol as placeholder)
                    Image(systemName: "g.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                    
                    Text("Sign in with Google")
                        .font(.phantomBodySmallSemibold)
                        .foregroundColor(.phantomSecondaryDark)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.phantomWhite)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.phantomSeparator, lineWidth: 1)
                )
                .shadow(color: Color(hex: "F4F5FA").opacity(0.6), radius: 3, x: 0, y: -3)
            }
            
            // Apple Sign-In
            // TODO: Implement actual Apple Sign-In with AuthenticationServices
            Button(action: {
                Task {
                    await viewModel.signInWithApple()
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 18))
                        .foregroundColor(.phantomSecondaryDark)
                    
                    Text("Sign in with Apple")
                        .font(.phantomBodySmallSemibold)
                        .foregroundColor(.phantomSecondaryDark)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.phantomWhite)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.phantomSeparator, lineWidth: 1)
                )
                .shadow(color: Color(hex: "F4F5FA").opacity(0.6), radius: 3, x: 0, y: -3)
            }
        }
    }
    
    // MARK: - Or Divider
    
    private var orDivider: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(Color.phantomInputBorder)
                .frame(height: 1)
            
            Text("Or")
                .font(.phantomSmall)
                .foregroundColor(.phantomGray)
            
            Rectangle()
                .fill(Color.phantomInputBorder)
                .frame(height: 1)
        }
    }
    
    // MARK: - Input Fields
    
    private var inputFields: some View {
        VStack(alignment: .trailing, spacing: 16) {
            // Email field
            VStack(alignment: .leading, spacing: 2) {
                Text("Email")
                    .font(.phantomSmallMedium)
                    .foregroundColor(.phantomGray)
                
                TextField("example@gmail.com", text: $viewModel.email)
                    .font(.phantomBodySmallMedium)
                    .foregroundColor(.phantomSecondaryDark)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(Color.phantomWhite)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.phantomInputBorder, lineWidth: 1)
                    )
                    .shadow(color: Color(hex: "E4E5E7").opacity(0.24), radius: 1, x: 0, y: 1)
            }
            
            // Password field
            VStack(alignment: .leading, spacing: 2) {
                Text("Password")
                    .font(.phantomSmallMedium)
                    .foregroundColor(.phantomGray)
                
                HStack {
                    if viewModel.isPasswordVisible {
                        TextField("", text: $viewModel.password)
                            .font(.phantomBodySmallMedium)
                            .foregroundColor(.phantomSecondaryDark)
                    } else {
                        SecureField("", text: $viewModel.password)
                            .font(.phantomBodySmallMedium)
                            .foregroundColor(.phantomSecondaryDark)
                    }
                    
                    Button(action: {
                        viewModel.isPasswordVisible.toggle()
                    }) {
                        Image(systemName: viewModel.isPasswordVisible ? "eye" : "eye.slash")
                            .font(.system(size: 16))
                            .foregroundColor(.phantomLightGray)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color.phantomWhite)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.phantomInputBorder, lineWidth: 1)
                )
                .shadow(color: Color(hex: "E4E5E7").opacity(0.24), radius: 1, x: 0, y: 1)
            }
        }
    }
    
    // MARK: - Remember Me & Forgot Password
    
    private var rememberAndForgotRow: some View {
        HStack {
            // Remember me toggle
            Button(action: {
                viewModel.toggleRememberMe()
            }) {
                HStack(spacing: 5) {
                    // Checkbox
                    Image(systemName: viewModel.rememberMe ? "checkmark.square.fill" : "square")
                        .font(.system(size: 19))
                        .foregroundColor(viewModel.rememberMe ? .phantomPurple : .phantomGray)
                    
                    Text("Remember me")
                        .font(.phantomSmallMedium)
                        .foregroundColor(.phantomGray)
                }
            }
            
            Spacer()
            
            // Forgot Password
            Button(action: {
                Task {
                    await viewModel.forgotPassword()
                }
            }) {
                Text("Forgot Password ?")
                    .font(.phantomSmallSemibold)
                    .foregroundColor(.phantomPurple)
            }
        }
    }
    
    // MARK: - Log In Button
    
    private var loginButton: some View {
        Button(action: {
            Task {
                await viewModel.signIn()
            }
        }) {
            Text(viewModel.isLoading ? "Logging In..." : "Log In")
                .font(.phantomBodySmallSemibold)
                .foregroundColor(.phantomWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [Color.phantomPurple, Color.phantomPurple],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(30)
                .shadow(
                    color: Color(hex: "375DFB").opacity(1),
                    radius: 0, x: 0, y: 0
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white, Color.white.opacity(0)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
        }
        .disabled(viewModel.isLoading || !viewModel.isLoginFormValid)
        .opacity(viewModel.isLoginFormValid ? 1.0 : 0.6)
    }
    
    // MARK: - Sign Up Link
    
    private var signUpLink: some View {
        HStack(spacing: 6) {
            Text("Don't have an account?")
                .font(.phantomSmallMedium)
                .foregroundColor(.phantomGray)
            
            Button(action: { showingSignUp = true }) {
                Text("Sign Up")
                    .font(.phantomSmallSemibold)
                    .foregroundColor(.phantomPurple)
            }
        }
    }
}

#Preview {
    LoginView()
}
