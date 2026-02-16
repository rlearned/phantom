//
//  OnboardingStep3View.swift
//  Phantom
//
//  Created on 2/15/2026.
//

import SwiftUI

struct OnboardingStep3View: View {
    var body: some View {
        ZStack {
            Color.phantomWhite.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 40)
                
                // Progress bar
                OnboardingProgressBar(currentStep: 3, progress: 0.75)
                
                Spacer()
                    .frame(height: 40)
                
                // Title
                Text("Example Ghost Trade")
                    .font(.phantomOnboardingTitleCenter)
                    .foregroundColor(.phantomTextPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 15)
                
                Spacer()
                    .frame(height: 16)
                
                // Example card wrapped in the purple card background
                ZStack {
                    // Purple card background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.phantomCardBackground)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                    
                    VStack {
                        ExampleGhostTradeCard()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                    }
                }
                .padding(.horizontal, 28)
                
                Spacer()
            }
        }
    }
}

#Preview {
    OnboardingStep3View()
}
