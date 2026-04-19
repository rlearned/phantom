//
//  RecentGhostsViewModel.swift
//  Phantom
//

import Foundation
import SwiftUI
import Combine

// MARK: - Sort & Filter

enum GhostSortOption: String, CaseIterable, Identifiable {
    case newest
    case oldest
    case tickerAZ
    case valueDesc

    var id: String { rawValue }

    var label: String {
        switch self {
        case .newest:    return "Newest"
        case .oldest:    return "Oldest"
        case .tickerAZ:  return "Ticker A–Z"
        case .valueDesc: return "Highest $"
        }
    }
}

enum GhostDirectionFilter: String, CaseIterable, Identifiable {
    case all
    case buy
    case sell

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all:  return "All"
        case .buy:  return "Buy"
        case .sell: return "Sell"
        }
    }
}

// MARK: - ViewModel

@MainActor
class RecentGhostsViewModel: ObservableObject {

    @Published var ghosts: [Ghost] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var sortOption: GhostSortOption = .newest
    @Published var directionFilter: GhostDirectionFilter = .all
    @Published var searchText: String = ""

    private let apiClient = APIClient.shared

    // MARK: - Derived Lists

    var filteredAndSorted: [Ghost] {
        var result = ghosts

        switch directionFilter {
        case .all:
            break
        case .buy:
            result = result.filter { $0.direction.uppercased() == "BUY" }
        case .sell:
            result = result.filter { $0.direction.uppercased() == "SELL" }
        }

        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            let needle = trimmedSearch.uppercased()
            result = result.filter { $0.ticker.uppercased().contains(needle) }
        }

        switch sortOption {
        case .newest:
            result.sort { $0.createdAtEpochMs > $1.createdAtEpochMs }
        case .oldest:
            result.sort { $0.createdAtEpochMs < $1.createdAtEpochMs }
        case .tickerAZ:
            result.sort { $0.ticker.uppercased() < $1.ticker.uppercased() }
        case .valueDesc:
            result.sort { dollarValue(of: $0) > dollarValue(of: $1) }
        }

        return result
    }

    // MARK: - Quick Stats

    var totalCount: Int { ghosts.count }

    var thisWeekCount: Int {
        let weekAgoMs = Int64((Date().addingTimeInterval(-7 * 24 * 60 * 60)).timeIntervalSince1970 * 1000)
        return ghosts.filter { $0.createdAtEpochMs >= weekAgoMs }.count
    }

    var totalDollarValue: Double {
        ghosts.reduce(0) { $0 + dollarValue(of: $1) }
    }

    var mostGhostedTicker: String? {
        let counts = Dictionary(grouping: ghosts, by: { $0.ticker.uppercased() }).mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    var mostGhostedTickerCount: Int {
        guard let top = mostGhostedTicker else { return 0 }
        return ghosts.filter { $0.ticker.uppercased() == top }.count
    }

    func dollarValue(of ghost: Ghost) -> Double {
        if let dollars = ghost.intendedDollars { return dollars }
        if let shares = ghost.intendedShares { return shares * ghost.intendedPrice }
        return 0
    }

    // MARK: - Loading

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.listGhosts(limit: 100)
            ghosts = response.ghosts
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
