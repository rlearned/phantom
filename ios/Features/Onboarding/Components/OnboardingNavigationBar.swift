//
//  OnboardingNavigationBar.swift
//  Phantom
//
//  Created on 2/15/2026.
//

import SwiftUI

// Bottom navigation bar with left/right arrows and dot indicators
struct OnboardingNavigationBar: View {
    let currentPage: Int
    let totalPages: Int
    let onPrevious: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack {
            // Left arrow
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(currentPage > 0 ? .phantomTextPrimary : .phantomLightGray)
                    .frame(width: 40, height: 40)
                    .background(Color.phantomWhite)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            .disabled(currentPage == 0)
            
            Spacer()
            
            // Dot indicators
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.phantomPurple : Color.phantomLightGray)
                        .frame(width: index == currentPage ? 12 : 8, height: index == currentPage ? 12 : 8)
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                }
            }
            
            Spacer()
            
            // Right arrow
            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.phantomTextPrimary)
                    .frame(width: 40, height: 40)
                    .background(Color.phantomWhite)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
        .padding(.horizontal, 80)
        .padding(.vertical, 16)
    }
}

#Preview {
    OnboardingNavigationBar(
        currentPage: 1,
        totalPages: 5,
        onPrevious: {},
        onNext: {}
    )
}
