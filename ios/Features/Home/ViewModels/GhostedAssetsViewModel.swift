//
//  GhostedAssetsViewModel.swift
//  Phantom
//
//  Created on 3/1/2026.
//

import Foundation
import SwiftUI
import Combine

/// Fetches the user's ghost trades and aggregates them by ticker to produce
/// a ranked list of frequently-ghosted assets.
@MainActor
class GhostedAssetsViewModel: ObservableObject {
    @Published var assets: [GhostedAsset] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch up to 200 ghosts so we get a representative sample.
            let response = try await apiClient.listGhosts(limit: 200)
            assets = Self.aggregate(response.ghosts)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Groups ghosts by ticker, counts occurrences, and returns them sorted
    /// from most-ghosted to least-ghosted.
    private static func aggregate(_ ghosts: [Ghost]) -> [GhostedAsset] {
        var counts: [String: Int] = [:]
        for ghost in ghosts {
            counts[ghost.ticker, default: 0] += 1
        }
        return counts
            .map { GhostedAsset(ticker: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
}
