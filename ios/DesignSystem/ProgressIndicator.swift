//
//  ProgressIndicator.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

struct ProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 16) {
            Text("STEP \(currentStep)/\(totalSteps)")
                .font(.phantomCaption)
                .foregroundColor(.phantomTextPrimary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.phantomTextSecondary.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(8)
                    
                    // Progress
                    Rectangle()
                        .fill(Color.phantomPurple)
                        .frame(width: geometry.size.width * progressPercentage, height: 8)
                        .cornerRadius(8)
                }
            }
            .frame(height: 8)
        }
        .frame(height: 20)
    }
    
    private var progressPercentage: CGFloat {
        CGFloat(currentStep) / CGFloat(totalSteps)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressIndicator(currentStep: 1, totalSteps: 2)
        ProgressIndicator(currentStep: 2, totalSteps: 2)
    }
    .padding()
}
