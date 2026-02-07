//
//  PhantomButton.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

enum PhantomButtonStyle {
    case primary
    case secondary
    case tertiary
}

struct PhantomButton: View {
    let title: String
    let style: PhantomButtonStyle
    let action: () -> Void
    var isEnabled: Bool = true
    var fullWidth: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.phantomHeadline)
                .foregroundColor(textColor)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .padding(.horizontal, 34)
                .padding(.vertical, 12)
                .background(backgroundColor)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .phantomPurple
        case .secondary:
            return .clear
        case .tertiary:
            return .clear
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary:
            return .phantomWhite
        case .secondary:
            return .phantomPurple
        case .tertiary:
            return .phantomTextPrimary
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary:
            return .clear
        case .secondary:
            return .phantomPurple
        case .tertiary:
            return .phantomTextPrimary
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .primary:
            return 0
        case .secondary:
            return 2
        case .tertiary:
            return 1
        }
    }
}

// Small button variant for tags
struct PhantomSmallButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .font(.phantomBodyMedium)
                .foregroundColor(isSelected ? .phantomWhite : .phantomTextSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.phantomPurple : Color.clear)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.phantomTextPrimary, lineWidth: 1)
                )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PhantomButton(title: "Start Log", style: .primary, action: {})
        PhantomButton(title: "Next", style: .secondary, action: {})
        PhantomButton(title: "Back", style: .tertiary, action: {})
        PhantomSmallButton(title: "Buy", isSelected: false, action: {})
        PhantomSmallButton(title: "Sell", isSelected: true, action: {})
    }
    .padding()
}
