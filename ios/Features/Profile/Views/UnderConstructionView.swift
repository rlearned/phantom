//
//  UnderConstructionView.swift
//  Phantom
//

import SwiftUI

struct UnderConstructionView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F8F8FA")
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#D9D9D9"))
                            .frame(width: 72, height: 72)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        Image(systemName: "wrench.and.screwdriver")
                            .font(.system(size: 30))
                            .foregroundColor(Color(hex: "#1A1A1F"))
                    }

                    // Message card
                    VStack(spacing: 8) {
                        Text("Under Construction")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "#1A1A1F"))

                        Text("Come back later!")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(hex: "#47474F"))
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity)
                    .background(Color.phantomSurface)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
                    .padding(.horizontal, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#8A8A96"))
                    }
                }
            }
        }
    }
}

#Preview {
    UnderConstructionView()
}
