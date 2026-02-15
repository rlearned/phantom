//
//  Colors.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

extension Color {
    // Primary Colors
    static let phantomPurple = Color(hex: "3803B1")
    static let phantomBlack = Color(hex: "000000")
    static let phantomWhite = Color(hex: "FFFFFF")
    
    // Background Colors
    static let phantomLightPurple = Color(hex: "F1F0FB")
    static let phantomBorderPurple = Color(hex: "E2E4FB")
    static let phantomCardBackground = Color(hex: "E2E4FB")
    
    // Text Colors
    static let phantomTextPrimary = Color(hex: "000000")
    static let phantomTextSecondary = Color(hex: "000000").opacity(0.67)
    static let phantomTextTertiary = Color(hex: "000000").opacity(0.5)
    static let phantomSecondaryDark = Color(hex: "1A1C1E")
    
    // Onboarding Colors
    static let phantomGray = Color(hex: "6C7278")
    static let phantomGreen = Color(hex: "0BAA36")
    static let phantomTagBackground = Color(hex: "3803B1").opacity(0.1)
    static let phantomTagBorder = Color(hex: "3803B1").opacity(0.15)
    static let phantomInputBorder = Color(hex: "EDF1F3")
    static let phantomGradientPurple = Color(hex: "7B61FF")
    static let phantomLavender = Color(hex: "A49EF4")
    static let phantomDarkGray = Color(hex: "3C3D3B")
    static let phantomLightGray = Color(hex: "ACB5BB")
    static let phantomSeparator = Color(hex: "EFF0F6")
    
    // Gradient
    static let phantomPurpleGradient = LinearGradient(
        colors: [Color(hex: "3803B1"), Color(hex: "7B61FF"), Color(hex: "A49EF4")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let phantomButtonGradient = LinearGradient(
        colors: [Color(hex: "3803B1"), Color(hex: "3803B1")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Helper initializer for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
