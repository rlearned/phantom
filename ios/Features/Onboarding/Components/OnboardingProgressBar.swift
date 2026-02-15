//
//  OnboardingProgressBar.swift
//  Phantom
//
//  Created on 2/15/2026.
//

import SwiftUI

/// Displays "STEP X/4" label with a purple animated progress bar
struct OnboardingProgressBar: View {
    let currentStep: Int // 1-4
    let totalSteps: Int = 4
    let progress: CGFloat // 0.0 to 1.0
    
    var body: some View {
        HStack(spacing: 16) {
            Text("STEP \(currentStep)/\(totalSteps)")
                .font(.phantomOnboardingStep)
                .foregroundColor(.phantomTextPrimary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.phantomInputBorder)
                        .frame(height: 8)
                    
                    // Filled progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.phantomPurple)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingProgressBar(currentStep: 1, progress: 0.25)
        OnboardingProgressBar(currentStep: 2, progress: 0.5)
        OnboardingProgressBar(currentStep: 3, progress: 0.75)
        OnboardingProgressBar(currentStep: 4, progress: 1.0)
    }
    .padding()
}
