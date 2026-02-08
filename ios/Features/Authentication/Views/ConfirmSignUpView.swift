//
//  ConfirmSignUpView.swift
//  Phantom
//
//  Created on 2/7/2026.
//

import SwiftUI

struct ConfirmSignUpView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            Color.phantomWhite.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                Circle()
                    .fill(Color.phantomPurple)
                    .frame(width: 64, height: 64)
                
                Text("Verify Email")
                    .phantomTitleStyle()
                
                Text("We sent a 6-digit code to your email.\nEnter it below to verify your account.")
                    .phantomSubheadlineStyle()
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                VStack(spacing: 16) {
                    TextField("Confirmation Code", text: $viewModel.confirmationCode)
                        .textFieldStyle(PhantomTextFieldStyle())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.phantomBodySmall)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    PhantomButton(
                        title: viewModel.isLoading ? "Verifying..." : "Verify",
                        style: .primary,
                        action: {
                            Task {
                                await viewModel.confirmSignUp()
                            }
                        },
                        isEnabled: !viewModel.isLoading && viewModel.isConfirmationCodeValid,
                        fullWidth: true
                    )
                    .padding(.top, 8)
                }
                
                Button(action: {
                    AuthManager.shared.signOut()
                }) {
                    Text("Back to Sign In")
                        .font(.phantomBodyMedium)
                        .foregroundColor(.phantomPurple)
                }
                
                Spacer()
            }
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    ConfirmSignUpView()
}
