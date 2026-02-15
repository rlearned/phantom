//
//  OnboardingCard.swift
//  Phantom
//
//  Created on 2/15/2026.
//

import SwiftUI

/// Reusable card component with light purple background and drop shadow
struct OnboardingCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.phantomCardBackground)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
    }
}

#Preview {
    OnboardingCard {
        Text("A ghost trade is a trade you seriously considered placing but did not execute.")
            .font(.phantomOnboardingBody)
            .foregroundColor(.phantomTextSecondary)
    }
    .padding()
}
