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
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "#1A1A1F"))

                    // Subtitle: bodySm style (SF Pro 400 13pt, Neutral/700 #47474F)
                    Text("See how hesitation has impacted your performance over time!")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(hex: "#47474F"))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 8)

                // MARK: - Ticker Search Bar
                // Shadow-only style (no outline stroke) — matching updated Figma design.
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
                .background(Color.white)
                .cornerRadius(24)
                // Updated: shadow replaces black outline border
                .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)

                // MARK: - If You Invested vs. Your Hesitation Cards
                // Updated: both cards are now white with neutral border + shadow
                // (previously green #C5FFC5 and red #FFC8C8 with black border)
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

                        // ── "If You Invested" card ──────────────────────────────
                        // Shows the current worth of the ghost portfolio and the gain (or loss).
                        // Label shortened from "If You Had Invested" → "If You Invested" per Figma.
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: isMissedOpportunity
                                      ? "chart.line.uptrend.xyaxis"
                                      : "chart.line.downtrend.xyaxis")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#8A8A96"))
                                Spacer()
                            }

                            Text("If You Invested")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color(hex: "#1A1A1F"))

                            // Current value = original cost basis + price appreciation
                            Text(viewModel.formatCurrency(max(0, ghostPortfolioCurrentValue)))
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(hex: "#1A1A1F"))
                                .padding(.top, 4)

                            // Delta line — e.g. "Gain: $4,401 (44.2%)"
                            let deltaLabel = isMissedOpportunity ? "Gain" : "Loss Avoided"
                            Text("\(deltaLabel): \(viewModel.formatCurrency(abs(viewModel.totalHesitationTax))) (\(viewModel.formatSignedPercentage(viewModel.hesitationPercentage)))")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(Color(hex: "#8A8A96"))
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)

                        // ── "Your Hesitation" card ──────────────────────────────
                        // Shows the opportunity cost — the price of not acting.
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "chart.line.downtrend.xyaxis")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#8A8A96"))
                                Spacer()
                            }

                            Text("Your Hesitation")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color(hex: "#1A1A1F"))

                            // Opportunity cost = absolute value of hesitation tax
                            Text(viewModel.formatCurrency(abs(viewModel.totalHesitationTax)))
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(hex: "#1A1A1F"))
                                .padding(.top, 4)

                            // Loss label — e.g. "Loss: $2,031 (23.1%)"
                            let lossLabel = isMissedOpportunity ? "Loss" : "Gain (Dodged loss)"
                            Text("\(lossLabel): \(viewModel.formatCurrency(abs(viewModel.totalHesitationTax))) (\(viewModel.formatPercentage(abs(viewModel.hesitationPercentage))))")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(Color(hex: "#8A8A96"))
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
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

                // MARK: - Your Hesitation Tax Section (white card)
                // Updated: now wrapped in a white card with border + shadow (matching Figma).
                // Displays a narrative summary using the real computed hesitation tax values.
                HesitationInfoCard(
                    icon: "dollarsign.circle",
                    title: "Your Hesitation Tax"
                ) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else if viewModel.ghostCount == 0 {
                        Text("No ghost trades logged yet. Start logging to calculate your hesitation tax.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(hex: "#47474F"))
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        let taxFormatted = viewModel.formatCurrency(abs(viewModel.totalHesitationTax))
                        let pctFormatted = viewModel.formatPercentage(abs(viewModel.hesitationPercentage))
                        let direction = isMissedOpportunity ? "not taking action" : "hesitating"
                        let outcome = isMissedOpportunity
                            ? "paid a hesitation tax of \(taxFormatted) (\(pctFormatted) potential return). This represents the opportunity cost of delaying or avoiding your investment decisions."
                            : "actually avoided a loss of \(taxFormatted) (\(pctFormatted)). The market moved against your ghost trades — your hesitation worked in your favor this time."

                        Text("Across \(viewModel.ghostCount) ghost trade\(viewModel.ghostCount == 1 ? "" : "s"), by \(direction) you've \(outcome)")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(hex: "#47474F"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                // MARK: - Your Common Hesitation Triggers (white card)
                // Updated: wrapped in white card; text reformatted as a line-separated list.
                // TODO: Analyze the user's ghost trade notes and emotion tags to determine
                // their most common hesitation triggers. Use NLP or tag frequency analysis
                // from the backend to generate personalized trigger descriptions.
                HesitationInfoCard(
                    icon: "brain",
                    title: "Your Common Hesitation Triggers"
                ) {
                    Text("""
                    Fear of buying at the wrong time
                    Waiting for a "better" entry point
                    Analysis paralysis
                    Emotional decision-making
                    """)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(hex: "#47474F"))
                        .fixedSize(horizontal: false, vertical: true)
                }

                // MARK: - Overcoming Hesitation (white card)
                // Updated: wrapped in white card.
                // TODO: Generate personalized overcoming-hesitation advice based on
                // the user's specific ghost trade patterns, trigger tags, and hesitation history.
                // This could be powered by an AI/LLM call to the backend.
                HesitationInfoCard(
                    icon: "lightbulb",
                    title: "Overcoming Hesitation"
                ) {
                    Text("""
                    Set clear entry and exit rules before analyzing trades
                    Use dollar-cost averaging to reduce timing pressure
                    Trust your research and accept that no entry is perfect
                    The best time to invest was yesterday; the second best time is today
                    """)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(hex: "#47474F"))
                        .fixedSize(horizontal: false, vertical: true)
                }

                // MARK: - Ghost Performance Section (white card)
                // TODO: Implement the "Ghost Perform" tab/section that shows a breakdown
                // of how each ghost trade would have performed if executed.
                // Include: ticker, entry date, hypothetical return %, P&L.
                HesitationInfoCard(
                    icon: "chart.bar.xaxis",
                    title: "Ghost Performance"
                ) {
                    Text("Placeholder — TODO: Show per-ghost-trade performance breakdown with individual hesitation tax calculations.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(hex: "#8A8A96"))
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
        .background(Color(hex: "#F8F8FA"))
    }
}

// MARK: - Reusable Info Card
// White card with border + shadow used for all info sections (Hesitation Tax,
// Common Triggers, Overcoming Hesitation, Ghost Performance).
// Matches the Figma "Updated" card style: Neutral/50 bg, E5E5E5 border, effect_RUGM32 shadow.
struct HesitationInfoCard<Content: View>: View {
    let icon: String
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title row: small icon + section title (titleSm = SF Pro 590 17pt)
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundColor(Color(hex: "#1A1A1F"))
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1F"))
                Spacer()
                // Small chevron on the right (matching layout_CR04QR icon in Figma)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#8A8A96"))
            }

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
}

#Preview {
    HesitationTaxView(viewModel: HesitationTaxViewModel())
}
