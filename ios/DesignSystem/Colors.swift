//
//  Colors.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI
import UIKit

extension Color {
    // MARK: - Primary Colors
    static let phantomPurple = Color(hex: "3803B1")
    static let phantomBlack = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 1)

    // MARK: - Adaptive Surfaces
    static let phantomSurface = Color.adaptive(lightHex: "FFFFFF", darkHex: "1A1A20")
    static let phantomSurfaceElevated = Color.adaptive(lightHex: "FFFFFF", darkHex: "24242C")
    static let phantomWhite = Color.adaptive(lightHex: "FFFFFF", darkHex: "1A1A20")
    static let phantomOnAccent = Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
    static let phantomTabIconInactive = Color.adaptive(lightHex: "1A1A1F", darkHex: "F0F0F5", lightAlpha: 0.35, darkAlpha: 0.5)

    // MARK: - Background Colors
    static let phantomLightPurple = Color(hex: "F1F0FB")
    static let phantomBorderPurple = Color(hex: "E2E4FB")
    static let phantomCardBackground = Color(hex: "E2E4FB")

    // MARK: - Text Colors
    static let phantomTextPrimary = Color(hex: "000000")
    static let phantomTextSecondary = Color(hex: "000000").opacity(0.67)
    static let phantomTextTertiary = Color(hex: "000000").opacity(0.5)
    static let phantomSecondaryDark = Color(hex: "1A1C1E")

    // MARK: - Onboarding Colors
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

    // MARK: - Gradients
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

    // MARK: - Adaptive Color Helpers

    init(hex: String) {
        let normalized = Self.normalizeHex(hex)
        let lightUIColor = UIColor(rgbHex: normalized)
        let darkHex = Self.darkModeMap[normalized] ?? Self.derivedDarkHex(for: normalized)
        let darkUIColor = UIColor(rgbHex: darkHex)
        let dynamic = UIColor { trait in
            trait.userInterfaceStyle == .dark ? darkUIColor : lightUIColor
        }
        self.init(uiColor: dynamic)
    }

    static func adaptive(lightHex: String, darkHex: String, lightAlpha: Double = 1.0, darkAlpha: Double = 1.0) -> Color {
        let lightUIColor = UIColor(rgbHex: normalizeHex(lightHex)).withAlphaComponent(CGFloat(lightAlpha))
        let darkUIColor = UIColor(rgbHex: normalizeHex(darkHex)).withAlphaComponent(CGFloat(darkAlpha))
        return Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? darkUIColor : lightUIColor
        })
    }

    private static func normalizeHex(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if trimmed.count == 3 {
            let chars = Array(trimmed)
            return "\(chars[0])\(chars[0])\(chars[1])\(chars[1])\(chars[2])\(chars[2])".uppercased()
        }
        return trimmed.uppercased()
    }

    private static func derivedDarkHex(for normalized: String) -> String {
        guard normalized.count == 6 || normalized.count == 8 else { return normalized }
        let rgb = normalized.suffix(6)
        var int: UInt64 = 0
        Scanner(string: String(rgb)).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        if luminance > 0.85 {
            return "1A1A20"
        }
        if luminance < 0.2 {
            return "F0F0F5"
        }
        return normalized
    }

    private static let darkModeMap: [String: String] = [
        "F8F8FA": "0E0F14",
        "F4F5FA": "0E0F14",
        "F1F0FB": "1A152F",
        "F0F0F3": "1F1F26",
        "EFF0F6": "26262E",
        "EDF1F3": "26262E",
        "FFFFFF": "1A1A20",
        "E8E0FF": "2D2470",
        "E5E5E5": "2A2A33",
        "E4E5E7": "2A2A33",
        "E2E4FB": "1F1F35",
        "DDD4F9": "2A2270",
        "DBDEE4": "33333D",
        "D9D9D9": "2D2D36",
        "CFD2D7": "3A3A44",
        "C5C5CD": "3A3A44",
        "1A1A1F": "F0F0F5",
        "1A1C1E": "E5E5EA",
        "000000": "F0F0F5",
        "47474F": "B0B0BC",
        "54555A": "A8A8B4",
        "8A8A96": "9C9CA8",
        "6C7278": "9C9CA8",
        "3C3D3B": "C5C5CD",
        "ACB5BB": "5C6064",
        "3803B1": "8B6FFF",
        "5B37D4": "9B82EA",
        "3D2494": "7B61FF",
        "7B61FF": "9B82EA",
        "A49EF4": "A49EF4",
        "9B82EA": "B5A0F3",
        "7E5BEC": "A092F5",
        "0A8A3C": "34C759",
        "0BAA36": "34C759",
        "C7341E": "FF6B5A",
        "E08A1E": "FFA94D",
        "3D6FB4": "5C9BFF",
        "375DFB": "6B8BFF"
    ]
}

// MARK: - UIColor hex helper

private extension UIColor {
    convenience init(rgbHex: String) {
        var int: UInt64 = 0
        Scanner(string: rgbHex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch rgbHex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
}
