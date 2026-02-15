//
//  OnboardingStep1View.swift
//  Phantom
//
//  Created on 2/15/2026.
//

import SwiftUI

struct OnboardingStep1View: View {
    var body: some View {
        ZStack {
            Color.phantomWhite.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 40)
                
                // Progress bar
                OnboardingProgressBar(currentStep: 1, progress: 0.25)
                
                Spacer()
                    .frame(height: 80)
                
                // Title
                Text("What is a Ghost Trade?")
                    .font(.phantomOnboardingTitle)
                    .foregroundColor(.phantomTextPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)
                
                Spacer()
                    .frame(height: 24)
                
                // Info card
                OnboardingCard {
                    Text("A ghost trade is a trade you seriously considered placing but did not execute.\n\nIt reflects a real decision moment when you analyzed an opportunity but chose not to act.")
                        .font(.phantomOnboardingBody)
                        .foregroundColor(.phantomTextSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 31)
                
                Spacer()
                
                VStack {
                    OnboardingNavigationBar(
                        currentPage: 1,
                        totalPages: 5,
                        onPrevious: {},
                        onNext: {})
                }
            }
        }
    }
}

#Preview {
    OnboardingStep1View()
}
