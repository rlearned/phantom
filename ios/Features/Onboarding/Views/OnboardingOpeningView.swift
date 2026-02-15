//
//  OnboardingOpeningView.swift
//  Phantom
//
//  Created on 2/15/2026.
//

import SwiftUI

struct OnboardingOpeningView: View {
    let onNext: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.phantomWhite.ignoresSafeArea()
                
                // Looper background (faded)
                Image("LooperBG")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.2)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
                
                // 3D Coin images scattered
                coinImages(in: geometry)
                
                // Center content
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Logo icon
                    Image("Logo")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 50)
                        .foregroundColor(.phantomPurple)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                    
                    // App name
                    VStack(spacing: 8) {
                        Text("Phantom")
                            .font(.phantomLargeTitle)
                            .foregroundColor(.phantomTextPrimary)
                        
                        Text("Log the trades you didn't take")
                            .font(.phantomOnboardingBody)
                            .foregroundColor(.phantomTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                    
                    Spacer()
                    
                    // Tap to continue
                    Button(action: onNext) {
                        VStack(spacing: 8) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.phantomPurple)
                            
                            Text("Tap to continue")
                                .font(.phantomBodySmall)
                                .foregroundColor(.phantomGray)
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
        }
    }
    
    private func coinImages(in geometry: GeometryProxy) -> some View {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        
        return ZStack {
            // Polygon (top left area)
            Image("Polygon3D")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 140, height: 144)
                .position(x: 30, y: screenHeight * 0.30)
            
            // Ethereum (top right area)
            Image("Ethereum3D")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 112)
                .position(x: screenWidth - 20, y: screenHeight * 0.08)
            
            // Bitcoin (bottom right area)
            Image("Bitcoin3D")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 104)
                .position(x: screenWidth - 30, y: screenHeight * 0.45)
        }
    }
}

#Preview {
    OnboardingOpeningView(onNext: {})
}
