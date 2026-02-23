//
//  HesitationTaxView.swift
//  Phantom
//
//  Created on 2/22/2026.
//

import SwiftUI

struct HesitationTaxView: View {
    // TODO: Replace this placeholder ticker state with a real view model
    // that fetches hesitation tax data from the backend for a given ticker.
    @State private var searchTicker: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Hesitation Tax")
                        .font(.system(size: 22, weight: .regular, design: .default))
                        .foregroundColor(.phantomTextPrimary)

                    Text("See how hesitation has impacted your\nperformance over time")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.phantomTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 8)

                // MARK: - Ticker Search Bar
                // TODO: Implement ticker search functionality.
                // When a valid ticker is entered:
                //   1. Call the backend API to fetch ghost trades for that ticker.
                //   2. Calculate "If You Had Invested" value using historical price data.
                //   3. Compare against the user's actual hesitation amount.
                //   4. Display the hesitation tax (opportunity cost) below.
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.black.opacity(0.4))
                        .font(.system(size: 14))

                    TextField("SEARCH TICKER (E.G. NVDA)", text: $searchTicker)
                        .font(.system(size: 14, weight: .regular))
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                }
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.black, lineWidth: 1)
                )

                // MARK: - If You Had Invested vs. Your Hesitation Cards
                // TODO: Replace placeholder values with real computed data:
                //   - "If You Had Invested": total portfolio value if ghost trades were executed.
                //   - "Your Hesitation": actual amount invested (if any, otherwise $0).
                //   - "Gain" and "Loss" values should reflect market performance delta.
                HStack(spacing: 12) {
                    // "If You Had Invested" card
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 14))
                            Spacer()
                        }
                        Text("If You Had Invested")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.phantomTextPrimary)

                        Text("$14,956.20")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.phantomTextPrimary)
                            .padding(.top, 4)

                        Text("Gain: $4,401.35 (44.2%)")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.phantomTextPrimary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "C5FFC5"))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.black, lineWidth: 1)
                    )

                    // "Your Hesitation" card
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "chart.line.downtrend.xyaxis")
                                .font(.system(size: 14))
                            Spacer()
                        }
                        Text("Your Hesitation")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.phantomTextPrimary)

                        Text("$1,002.50")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.phantomTextPrimary)
                            .padding(.top, 4)

                        Text("Loss: $4,401.35 (44.2%)")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.phantomTextPrimary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "FFC8C8"))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }

                // MARK: - Performance Chart Placeholder
                // TODO: Implement a line chart comparing:
                //   - Ghost portfolio performance (what you would have made)
                //   - Actual portfolio performance (what you did make)
                // Use Swift Charts framework. X-axis = date, Y-axis = portfolio value.
                // Data source: backend API endpoint for historical ghost trade performance.
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.06))
                        .frame(height: 120)
                        .overlay(
                            Text("Chart: Ghost vs. Actual Performance")
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(.phantomTextSecondary)
                        )
                    Text("Chart placeholder — TODO: Implement Swift Charts comparison graph")
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(.phantomTextSecondary)
                }

                // MARK: - Your Hesitation Tax Section
                // TODO: Calculate and display the real hesitation tax for the searched ticker.
                // Formula: hesitationTax = (currentPrice - ghostEntryPrice) * shares
                // If no ticker is searched, aggregate across all ghost trades.
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 20))
                        Text("Your Hesitation Tax")
                            .font(.system(size: 15, weight: .regular))
                    }

                    Text("By not taking action on AAPL, you've paid a hesitation tax of $3,589.26 (35.9% potential return). This represents the opportunity cost of delaying or avoiding your investment decision.")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(.phantomTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // MARK: - Your Common Hesitation Triggers
                // TODO: Analyze the user's ghost trade notes and emotion tags to determine
                // their most common hesitation triggers. Use NLP or tag frequency analysis
                // from the backend to generate personalized trigger descriptions.
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "brain")
                            .font(.system(size: 20))
                        Text("Your Common Hesitation Triggers")
                            .font(.system(size: 15, weight: .regular))
                    }

                    Text("Fear of buying at the wrong time, waiting for a \"better\" entry point, analysis paralysis, and emotional decision-making all contribute to hesitation. The market rewards action over perfection.")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(.phantomTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // MARK: - Overcoming Hesitation Section
                // TODO: Generate personalized overcoming-hesitation advice based on
                // the user's specific ghost trade patterns, trigger tags, and hesitation history.
                // This could be powered by an AI/LLM call to the backend.
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb")
                            .font(.system(size: 20))
                        Text("Overcoming Hesitation")
                            .font(.system(size: 15, weight: .regular))
                    }

                    Text("Set clear entry and exit rules before analyzing trades.\n\nUse dollar-cost averaging to reduce timing pressure.\n\nTrust your research and accept that no entry is perfect.\n\nThe best time to invest was yesterday; the second best time is today.")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(.phantomTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // MARK: - Ghost Performance Section
                // TODO: Implement the "Ghost Perform" tab/section that shows a breakdown
                // of how each ghost trade would have performed if executed.
                // Include: ticker, entry date, hypothetical return %, P&L.
                // Navigate from here to a detailed per-ghost hesitation tax view.
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 20))
                        Text("Ghost Performance")
                            .font(.system(size: 15, weight: .regular))
                    }

                    Text("Placeholder — TODO: Show per-ghost-trade performance breakdown with individual hesitation tax calculations.")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(.phantomTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 100) // Bottom padding for tab bar
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
        }
        .background(Color.phantomWhite)
    }
}

#Preview {
    HesitationTaxView()
}
