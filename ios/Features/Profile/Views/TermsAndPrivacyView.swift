//
//  TermsAndPrivacyView.swift
//  Phantom
//

import SwiftUI

struct TermsAndPrivacyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Terms & Privacy")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "#1A1A1F"))

                        Text("Last updated: May 2026")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(hex: "#47474F"))
                    }
                    .padding(.top, 8)

                    // MARK: - Terms of Service
                    LegalSectionCard(icon: "doc.text", title: "Terms of Service") {
                        LegalBlock(heading: "1. Acceptance of Terms",
                                   bodyText: "By accessing or using Phantom, you agree to be bound by these Terms of Service. If you do not agree, please do not use the app.")
                        LegalBlock(heading: "2. Use of the App",
                                   bodyText: "Phantom is provided for personal, non-commercial use only. You agree not to misuse the service, attempt to gain unauthorized access, or use it in any way that violates applicable law.")
                        LegalBlock(heading: "3. Ghost Trade Data",
                                   bodyText: "All trade logs and behavioral data you enter are used solely to generate your Investor DNA profile and Hesitation Tax reports. You own your data and may request deletion at any time.")
                        LegalBlock(heading: "4. No Financial Advice",
                                   bodyText: "Phantom is an analytics and self-reflection tool. Nothing in the app constitutes financial, investment, or trading advice. All insights are based solely on your own logged data.")
                        LegalBlock(heading: "5. Account Termination",
                                   bodyText: "We reserve the right to suspend or terminate accounts that violate these terms, engage in fraudulent activity, or compromise the security of our platform.")
                        LegalBlock(heading: "6. Changes to Terms",
                                   bodyText: "We may update these terms from time to time. Continued use of Phantom after changes are posted constitutes your acceptance of the revised terms.")
                    }

                    // MARK: - Privacy Policy
                    LegalSectionCard(icon: "hand.raised", title: "Privacy Policy") {
                        LegalBlock(heading: "1. Data We Collect",
                                   bodyText: "We collect the data you voluntarily provide: your name, email address, and ghost trade logs (ticker, direction, notes, emotion tags). We do not collect real portfolio holdings or brokerage credentials.")
                        LegalBlock(heading: "2. How We Use Your Data",
                                   bodyText: "Your data is used to calculate your Hesitation Tax, build your Investor DNA profile, and generate personalized behavioral insights. We do not sell your data to third parties.")
                        LegalBlock(heading: "3. Data Storage & Security",
                                   bodyText: "Your data is stored securely on AWS infrastructure with encryption at rest and in transit. Access is restricted to authorized systems only. We follow industry-standard security practices.")
                        LegalBlock(heading: "4. Third-Party Services",
                                   bodyText: "Phantom uses AWS Cognito for authentication and market data APIs to fetch current asset prices. These services have their own privacy policies governing their use of data.")
                        LegalBlock(heading: "5. Your Rights",
                                   bodyText: "You may request to access, correct, or delete your personal data at any time by contacting us. Upon account deletion, all associated ghost trade data will be permanently removed within 30 days.")
                        LegalBlock(heading: "6. Contact Us",
                                   bodyText: "For privacy-related questions or data requests, reach out to us at privacy@phantom.app. We aim to respond within 5 business days.")
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
            }
            .background(Color(hex: "#F8F8FA"))
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

// MARK: - Legal Section Card

private struct LegalSectionCard<Content: View>: View {
    let icon: String
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#D9D9D9"))
                        .frame(width: 32, height: 32)
                        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#1A1A1F"))
                }

                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1F"))
            }

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.phantomSurface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Legal Block

private struct LegalBlock: View {
    let heading: String
    let bodyText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(heading)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "#1A1A1F"))

            Text(bodyText)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(hex: "#47474F"))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
    }
}

#Preview {
    TermsAndPrivacyView()
}
