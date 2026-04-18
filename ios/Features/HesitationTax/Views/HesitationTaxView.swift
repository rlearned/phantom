//
//  HesitationTaxView.swift
//  Phantom
//
//  Created on 2/22/2026.
//

import SwiftUI

struct HesitationTaxView: View {
    @ObservedObject var viewModel: HesitationTaxViewModel

    // TODO: Wire up ticker search to filter hesitation data per-symbol.
    // When a valid ticker is entered:
    //   1. Re-fetch ghost trades filtered by that ticker.
    //   2. Re-calculate hesitation tax for just that ticker.
    //   3. Refresh the cards and chart below.
    @State private var searchTicker: String = ""

    // MARK: - Computed display values

    /// Current value of the ghost portfolio: what you would own today.
    private var ghostPortfolioCurrentValue: Double {
        viewModel.ifInvestedValue + viewModel.totalHesitationTax
    }

    /// True when the market moved in the ghost-trade direction (tax > 0 = missed gain).
    private var isMissedOpportunity: Bool {
        viewModel.totalHesitationTax >= 0
    }

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
                // TODO: Implement per-ticker filtering — see TODOs on searchTicker above.
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
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding(.vertical, 20)
                        Spacer()
                    }
                } else {
                    HStack(spacing: 12) {

                        // ── "If You Had Invested" card (green) ──────────────────
                        // Shows the current worth of the ghost portfolio and the gain (or loss).
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: isMissedOpportunity
                                      ? "chart.line.uptrend.xyaxis"
                                      : "chart.line.downtrend.xyaxis")
                                    .font(.system(size: 14))
                                Spacer()
                            }
                            Text("If You Had Invested")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.phantomTextPrimary)

                            // Current value = original cost basis + price appreciation
                            Text(viewModel.formatCurrency(max(0, ghostPortfolioCurrentValue)))
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.phantomTextPrimary)
                                .padding(.top, 4)

                            // Delta line — e.g. "Gain: $4,401.35 (+44.2%)"
                            let deltaLabel = isMissedOpportunity ? "Gain" : "Loss Avoided"
                            Text("\(deltaLabel): \(viewModel.formatCurrency(abs(viewModel.totalHesitationTax))) (\(viewModel.formatSignedPercentage(viewModel.hesitationPercentage)))")
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

                        // ── "Your Hesitation" card (red) ────────────────────────
                        // Shows the opportunity cost — the price of not acting.
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "chart.line.downtrend.xyaxis")
                                    .font(.system(size: 14))
                                Spacer()
                            }
                            Text("Your Hesitation")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.phantomTextPrimary)

                            // Opportunity cost = absolute value of hesitation tax
                            Text(viewModel.formatCurrency(abs(viewModel.totalHesitationTax)))
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.phantomTextPrimary)
                                .padding(.top, 4)

                            // Loss label — e.g. "Loss: $4,401.35 (44.2%)"
                            let lossLabel = isMissedOpportunity ? "Loss" : "Gain (Dodged loss)"
                            Text("\(lossLabel): \(viewModel.formatCurrency(abs(viewModel.totalHesitationTax))) (\(viewModel.formatPercentage(abs(viewModel.hesitationPercentage))))")
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
                // Displays a narrative summary using the real computed hesitation tax values.
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 20))
                        Text("Your Hesitation Tax")
                            .font(.system(size: 15, weight: .regular))
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else if viewModel.ghostCount == 0 {
                        Text("No ghost trades logged yet. Start logging to calculate your hesitation tax.")
                            .font(.system(size: 13, weight: .light))
                            .foregroundColor(.phantomTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        let taxFormatted = viewModel.formatCurrency(abs(viewModel.totalHesitationTax))
                        let pctFormatted = viewModel.formatPercentage(abs(viewModel.hesitationPercentage))
                        let direction = isMissedOpportunity ? "not taking action" : "hesitating"
                        let outcome = isMissedOpportunity
                            ? "paid a hesitation tax of \(taxFormatted) (\(pctFormatted) potential return). This represents the opportunity cost of delaying or avoiding your investment decisions."
                            : "actually avoided a loss of \(taxFormatted) (\(pctFormatted)). The market moved against your ghost trades — your hesitation worked in your favor this time."

                        Text("Across \(viewModel.ghostCount) ghost trade\(viewModel.ghostCount == 1 ? "" : "s"), by \(direction) you've \(outcome)")
                            .font(.system(size: 13, weight: .light))
                            .foregroundColor(.phantomTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
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

                // Error banner (non-fatal)
                if let error = viewModel.errorMessage {
                    Text("⚠ \(error)")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                Spacer().frame(height: 100) // Bottom padding for tab bar
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
        }
        .background(Color.phantomWhite)
    }
}

#Preview {
    HesitationTaxView(viewModel: HesitationTaxViewModel())
}
