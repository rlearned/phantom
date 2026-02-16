//
//  OnboardingStep2View.swift
//  Phantom
//
//  Created on 2/15/2026.
//

import SwiftUI

struct OnboardingStep2View: View {
    var body: some View {
        ZStack {
            Color.phantomWhite.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 40)
                
                // Progress bar
                OnboardingProgressBar(currentStep: 2, progress: 0.5)
                
                Spacer()
                    .frame(height: 80)
                
                // Title
                Text("Why it Matters")
                    .font(.phantomOnboardingTitleCenter)
                    .foregroundColor(.phantomTextPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 15)
                
                Spacer()
                    .frame(height: 24)
                
                // Info card
                OnboardingCard {
                    Text("Ghost trades usually happen during moments of hesitation, second-guessing, or uncertainty.\n\nLogging them helps you understand your decision patterns over time.")
                        .font(.phantomOnboardingBody)
                        .foregroundColor(.phantomTextSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 31)
                
                Spacer()
            }
        }
    }
}

#Preview {
    OnboardingStep2View()
}
