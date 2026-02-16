//
//  OnboardingStep4View.swift
//  Phantom
//
//  Created on 2/15/2026.
//

import SwiftUI

struct OnboardingStep4View: View {
    var body: some View {
        ZStack {
            Color.phantomWhite.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 40)
                
                // Progress bar
                OnboardingProgressBar(currentStep: 4, progress: 1.0)
                
                Spacer()
                    .frame(height: 80)
                
                // Title
                Text("A Quick Disclaimer")
                    .font(.phantomTitleLight)
                    .foregroundColor(.phantomTextPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 19)
                
                Spacer()
                    .frame(height: 48)
                
                // Subtitle
                Text("Phantom is Not Financial Advice")
                    .font(.phantomTitle)
                    .foregroundColor(.phantomTextPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 19)
                
                Spacer()
                    .frame(height: 24)
                
                // Description
                Text("Phantom is a tool for personal reflection and tracking considered trades. It does not provide financial advice or recommendations.")
                    .font(.phantomOnboardingBody)
                    .foregroundColor(.phantomTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                
                Spacer()
                    .frame(height: 40)
                
                // Advisory note
                Text("*Always consult a certified financial advisor for any investment decisions")
                    .font(.phantomCaptionBold)
                    .foregroundColor(.phantomTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 33)
                
                Spacer()
            }
        }
    }
}

#Preview {
    OnboardingStep4View()
}
