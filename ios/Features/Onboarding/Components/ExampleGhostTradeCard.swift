//
//  ExampleGhostTradeCard.swift
//  Phantom
//
//  Created on 2/15/2026.
//

import SwiftUI

// A mock ghost trade card showing an example AAPL trade for the onboarding flow
struct ExampleGhostTradeCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: Apple icon + ticker + trade type
            HStack(spacing: 12) {
                // Apple logo placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.phantomWhite)
                        .frame(width: 34, height: 34)
                        .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
                    
                    Image(systemName: "apple.logo")
                        .font(.system(size: 20))
                        .foregroundColor(.phantomTextPrimary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("AAPL Apple Inc.")
                        .font(.phantomSubheadlineMedium)
                        .fontWeight(.bold)
                        .foregroundColor(.phantomTextPrimary)
                    
                    Text("Planned Buy")
                        .font(.phantomSmallMedium)
                        .foregroundColor(.phantomGreen)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.phantomGreen)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 16)
            
            // Order Price
            Text("Order Price: $180.00")
                .font(.phantomSmallMedium)
                .foregroundColor(.phantomTextPrimary)
                .padding(.horizontal, 16)
                .padding(.top, 12)
            
            // Reason for Hesitation
            Text("Reason for Hesitation:")
                .font(.phantomSubheadlineMedium)
                .foregroundColor(.phantomTextPrimary)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            // Hesitation tags
            HStack(spacing: 8) {
                OnboardingTag(text: "Fear of Loss")
                OnboardingTag(text: "Not Enough Confidence")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Emotional State
            Text("Emotional State")
                .font(.phantomSubheadlineMedium)
                .foregroundColor(.phantomTextPrimary)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            // Emotion tags
            HStack(spacing: 8) {
                OnboardingTag(text: "Fear")
                OnboardingTag(text: "High Stress")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Notes
            Text("Notes:")
                .font(.phantomSubheadlineMedium)
                .foregroundColor(.phantomTextPrimary)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            Text("There were rumors that iPhone Sales were declining")
                .font(.phantomSmallMedium)
                .foregroundColor(.phantomDarkGray)
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.phantomWhite)
                .stroke(Color.phantomWhite, lineWidth: 0.5)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }
}

/// Small tag chip used in the example ghost trade card
struct OnboardingTag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundColor(.phantomPurple)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color.phantomTagBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(Color.phantomTagBorder, lineWidth: 1)
            )
            .cornerRadius(100)
    }
}

#Preview {
    ExampleGhostTradeCard()
        .padding()
        .background(Color.phantomCardBackground)
}
