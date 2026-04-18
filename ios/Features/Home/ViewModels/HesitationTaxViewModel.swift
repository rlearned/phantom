//
//  HesitationTaxViewModel.swift
//  Phantom
//
//  Created on 4/18/2026.
//

import Foundation
import SwiftUI
import Combine

// ─────────────────────────────────────────────────────────────────────────────
// HESITATION TAX — DEFINITIONS & FORMULAS
// ─────────────────────────────────────────────────────────────────────────────
//  This definition board is for reference because the numbers are way too confusing...

//  Ghost Trade
//  ───────────
//  A trade the user CONSIDERED but did NOT execute. Each ghost stores:
//    • ticker         — the stock/crypto symbol (e.g. "AAPL")
//    • direction      — "BUY" or "SELL"
//    • quantityType   — "SHARES" (explicit share count) or "DOLLARS" (dollar amount)
//    • intendedShares — number of shares, present when quantityType == "SHARES"
//    • intendedDollars— dollar amount intended, present when quantityType == "DOLLARS"
//    • loggedQuote.price — market price of the ticker AT THE MOMENT the ghost was logged
//
//  Resolving Shares
//  ────────────────
//  We always work in share units.  If quantityType == "DOLLARS":
//    shares = intendedDollars / loggedQuote.price
//  If quantityType == "SHARES":
//    shares = intendedShares
//
//  Net Shares (per ticker)
//  ───────────────────────
//  Multiple ghosts for the same ticker are combined into one net position:
//    netShares = Σ(BUY shares) − Σ(SELL shares)
//  Positive → net long exposure. Negative → net short exposure.
//
//  Weighted Average Logged Price (per ticker)
//  ──────────────────────────────────────────
//  Each ghost may have been logged at a different price. We weight by share count:
//    weightedAvgLoggedPrice = Σ(loggedPrice × shares) / Σ(shares)
//  This gives the effective cost basis of the aggregated ghost position.
//
//  Hesitation Tax (per ticker)
//  ───────────────────────────
//  The opportunity cost of NOT taking action:
//    hesitationTaxForTicker = (currentPrice − weightedAvgLoggedPrice) × netShares
//  Positive → market moved in your intended direction; you missed a gain.
//  Negative → market moved against you; your hesitation saved money.
//
//  Total Hesitation Tax
//  ────────────────────
//  Aggregate across all tickers:
//    totalHesitationTax = Σ hesitationTaxForTicker
//
//  If Invested Value
//  ─────────────────
//  The total capital the user WOULD HAVE deployed across all BUY ghost trades,
//  valued at the logged price (i.e., the original cost basis):
//    ifInvestedValue = Σ (intendedDollars)              for DOLLARS-type BUY ghosts
//                    + Σ (intendedShares × loggedPrice)  for SHARES-type BUY ghosts
//  This is used as the denominator for the hesitation percentage.
//
//  Average Hesitation Tax per Trade
//  ─────────────────────────────────
//    avgPerTrade = totalHesitationTax / ghostCount
//  Tells the user the average opportunity cost (or savings) per ghost trade logged.
//
//  Hesitation Percentage
//  ─────────────────────
//    hesitationPercentage = (totalHesitationTax / ifInvestedValue) × 100
//  Expresses the hesitation tax as a % of what the user would have invested.
//  e.g. 44.2% means the market gained 44.2% on the capital you ghosted.
//
//  Ghost Portfolio Current Value (display-only, computed in views)
//  ───────────────────────────────────────────────────────────────
//    ghostPortfolioCurrentValue = ifInvestedValue + totalHesitationTax
//  This is the hypothetical current value of the ghost portfolio today —
//  the original investment plus (or minus) the price movement since logging.
// ─────────────────────────────────────────────────────────────────────────────

/// Computes all Hesitation Tax metrics by fetching ghost trades and current
/// market prices, then aggregating them on a per-ticker basis.
@MainActor
class HesitationTaxViewModel: ObservableObject {

    // MARK: - Published Outputs

    /// Total number of ghost trades fetched (all statuses, all tickers).
    /// Used as the denominator for avgPerTrade.
    @Published var ghostCount: Int = 0

    /// Total hesitation tax across all tickers.
    ///
    /// Formula:  totalHesitationTax = Σ [ (currentPrice − weightedAvgLoggedPrice) × netShares ]
    ///           summed over every unique ticker.
    ///
    /// Positive value → you missed out on gains (market went up on your ghost BUYs).
    /// Negative value → your hesitation saved money (market moved against your intent).
    @Published var totalHesitationTax: Double = 0

    /// Average hesitation tax per ghost trade.
    ///
    /// Formula:  avgPerTrade = totalHesitationTax / ghostCount
    ///
    /// Gives the user an at-a-glance sense of how much each individual
    /// ghost trade costs them on average in opportunity cost.
    @Published var avgPerTrade: Double = 0

    /// Total capital that would have been deployed on BUY ghost trades,
    /// valued at the price logged at the moment of ghosting (the cost basis).
    ///
    /// Formula:  ifInvestedValue
    ///             = Σ intendedDollars                    (for DOLLARS-type BUY ghosts)
    ///             + Σ (intendedShares × loggedQuote.price) (for SHARES-type BUY ghosts)
    ///
    /// Used as the denominator for hesitationPercentage, and as the baseline
    /// for "If You Had Invested" card: current value = ifInvestedValue + totalHesitationTax.
    @Published var ifInvestedValue: Double = 0

    /// Hesitation tax as a percentage of ifInvestedValue.
    ///
    /// Formula:  hesitationPercentage = (totalHesitationTax / ifInvestedValue) × 100
    ///
    /// e.g. 44.2% means the market gained 44.2% on the total capital you ghosted.
    /// A negative value means you avoided a loss of that percentage.
    @Published var hesitationPercentage: Double = 0

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Private

    private let apiClient = APIClient.shared

    // MARK: - Load

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            // ── Step 1: Fetch ghost trades ────────────────────────────────────
            // Fetch up to 200 ghosts to get a representative sample.
            let response = try await apiClient.listGhosts(limit: 200)
            let ghosts = response.ghosts

            // ghostCount = total number of ghost trades logged by the user.
            ghostCount = ghosts.count

            guard !ghosts.isEmpty else {
                isLoading = false
                return
            }

            // ── Step 2: Group ghosts by ticker ───────────────────────────────
            // Multiple ghosts for the same ticker will be netted together
            // to produce one combined position per ticker.
            var tickerGroups: [String: [Ghost]] = [:]
            for ghost in ghosts {
                tickerGroups[ghost.ticker, default: []].append(ghost)
            }

            // ── Step 3: Fetch current price for each unique ticker (parallel) ─
            // We fire one GET /v1/market/quote?symbol= request per ticker,
            // all in parallel via TaskGroup. Tickers that fail (e.g. delisted)
            // are silently skipped — those tickers won't contribute to the tax.
            let tickers = Array(tickerGroups.keys)
            var currentPrices: [String: Double] = [:]

            await withTaskGroup(of: (String, Double?).self) { group in
                for ticker in tickers {
                    group.addTask {
                        do {
                            let quote = try await APIClient.shared.getMarketQuote(symbol: ticker)
                            return (ticker, quote.price)
                        } catch {
                            return (ticker, nil)
                        }
                    }
                }
                for await (ticker, price) in group {
                    if let price = price {
                        currentPrices[ticker] = price
                    }
                }
            }

            // ── Step 4: Aggregate per ticker and compute metrics ──────────────
            var totalTax = 0.0
            var totalIfInvested = 0.0

            for (ticker, tickerGhosts) in tickerGroups {
                guard let currentPrice = currentPrices[ticker] else { continue }

                // Per-ticker accumulators
                var netShares = 0.0             // Σ BUY shares − Σ SELL shares
                var weightedLoggedPriceSum = 0.0 // Σ (loggedPrice × shares), for weighted avg
                var totalSharesForWeight = 0.0   // Σ shares, denominator for weighted avg

                for ghost in tickerGhosts {
                    let loggedPrice = ghost.loggedQuote.price

                    // ── Resolve share count ───────────────────────────────────
                    // If the ghost was logged in DOLLARS, convert to shares:
                    //   shares = intendedDollars / loggedPrice
                    // If logged in SHARES, use directly:
                    //   shares = intendedShares
                    let shares: Double
                    if ghost.quantityType == "DOLLARS" {
                        let dollars = ghost.intendedDollars ?? 0
                        shares = loggedPrice > 0 ? dollars / loggedPrice : 0
                    } else {
                        // quantityType == "SHARES"
                        shares = ghost.intendedShares ?? 0
                    }

                    // ── Net shares ────────────────────────────────────────────
                    // BUY = positive exposure (you wanted to own shares).
                    // SELL = negative exposure (you wanted to reduce/short).
                    //   netShares = Σ BUY shares − Σ SELL shares
                    let signedShares = ghost.direction == "BUY" ? shares : -shares
                    netShares += signedShares

                    // ── Weighted average logged price ─────────────────────────
                    // Weight each ghost's logged price by its share count so
                    // larger positions have proportionally more influence:
                    //   weightedAvgLoggedPrice = Σ(loggedPrice × shares) / Σ(shares)
                    weightedLoggedPriceSum += loggedPrice * shares
                    totalSharesForWeight += shares

                    // ── If Invested Value ─────────────────────────────────────
                    // Accumulate the total capital the user would have deployed
                    // on BUY ghosts at their logged (entry) price:
                    //   ifInvestedValue
                    //     += intendedDollars               (DOLLARS-type BUY)
                    //     += intendedShares × loggedPrice  (SHARES-type BUY)
                    if ghost.direction == "BUY" {
                        if ghost.quantityType == "DOLLARS" {
                            totalIfInvested += ghost.intendedDollars ?? 0
                        } else {
                            totalIfInvested += shares * loggedPrice
                        }
                    }
                }

                // ── Weighted average logged price for this ticker ─────────────
                //   weightedAvgLoggedPrice = Σ(loggedPrice × shares) / Σ(shares)
                let avgLoggedPrice = totalSharesForWeight > 0
                    ? weightedLoggedPriceSum / totalSharesForWeight
                    : 0

                // ── Hesitation tax for this ticker ────────────────────────────
                //   hesitationTax = (currentPrice − avgLoggedPrice) × netShares
                //
                // Intuition: if currentPrice > avgLoggedPrice and netShares > 0
                //   (net long ghost), the market went up — you missed that gain.
                //   The tax is how many dollars of gain you left on the table.
                let taxForTicker = (currentPrice - avgLoggedPrice) * netShares
                totalTax += taxForTicker
            }

            // ── Step 5: Publish final computed values ─────────────────────────

            // totalHesitationTax = Σ [ (currentPrice − avgLoggedPrice) × netShares ]
            totalHesitationTax = totalTax

            // ifInvestedValue = Σ capital deployed on BUY ghosts at logged price
            ifInvestedValue = totalIfInvested

            // avgPerTrade = totalHesitationTax / ghostCount
            avgPerTrade = ghostCount > 0 ? totalTax / Double(ghostCount) : 0

            // hesitationPercentage = (totalHesitationTax / ifInvestedValue) × 100
            hesitationPercentage = totalIfInvested > 0
                ? (totalTax / totalIfInvested) * 100
                : 0

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Formatting Helpers

    /// Formats a dollar value as currency string, e.g. "$1,234.56".
    /// Negative values are shown with a minus sign, e.g. "-$500.00".
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    /// Formats a percentage value, e.g. "12.3%" or "-5.0%".
    func formatPercentage(_ value: Double) -> String {
        String(format: "%.1f%%", value)
    }

    /// Formats a percentage with an explicit sign prefix, e.g. "+12.3%" or "-5.0%".
    /// Used for gain/loss delta labels on the Hesitation Tax cards.
    func formatSignedPercentage(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f%%", value))"
    }
}
