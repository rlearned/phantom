//
//  Typography.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

extension Font {
    // DM Sans Font Styles (matching Figma)
    
    // Headings
    static let phantomLargeTitle = Font.custom("DMSans-Bold", size: 40)
    static let phantomTitle = Font.custom("DMSans-SemiBold", size: 32)
    static let phantomHeadline = Font.custom("DMSans-Regular", size: 24)
    
    // Body Text
    static let phantomBody = Font.custom("DMSans-Regular", size: 18)
    static let phantomBodyMedium = Font.custom("DMSans-Regular", size: 16)
    static let phantomBodySmall = Font.custom("DMSans-Regular", size: 14)
    
    // Special
    static let phantomCaption = Font.custom("DMSans-Light", size: 14)
    static let phantomSubheadline = Font.custom("DMSans-Light", size: 20)
}

// Text Style Modifiers
extension View {
    func phantomLargeTitleStyle() -> some View {
        self.font(.phantomLargeTitle)
            .foregroundColor(.phantomTextPrimary)
    }
    
    func phantomTitleStyle() -> some View {
        self.font(.phantomTitle)
            .foregroundColor(.phantomTextPrimary)
    }
    
    func phantomHeadlineStyle() -> some View {
        self.font(.phantomHeadline)
            .foregroundColor(.phantomTextPrimary)
    }
    
    func phantomBodyStyle() -> some View {
        self.font(.phantomBody)
            .foregroundColor(.phantomTextPrimary)
    }
    
    func phantomBodyMediumStyle() -> some View {
        self.font(.phantomBodyMedium)
            .foregroundColor(.phantomTextPrimary)
    }
    
    func phantomCaptionStyle() -> some View {
        self.font(.phantomCaption)
            .foregroundColor(.phantomTextSecondary)
    }
    
    func phantomSubheadlineStyle() -> some View {
        self.font(.phantomSubheadline)
            .foregroundColor(.phantomTextSecondary)
    }
}
