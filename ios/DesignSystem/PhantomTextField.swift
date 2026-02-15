//
//  PhantomTextField.swift
//  Phantom
//
//  Originally defined in LoginView.swift, moved to DesignSystem on 2/15/2026.
//

import SwiftUI

// Custom TextField Style (used across authentication views)
struct PhantomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.phantomBodyMedium)
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.phantomTextPrimary, lineWidth: 1)
            )
    }
}
