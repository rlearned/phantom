//
//  GhostedAsset.swift
//  Phantom
//
//  Created on 3/1/2026.
//

import Foundation

/// Represents a stock ticker that the user has frequently ghosted (considered but not traded).
struct GhostedAsset: Identifiable {
    let ticker: String
    /// Number of times the user has ghosted this ticker.
    let count: Int

    var id: String { ticker }

    /// The first two uppercase letters of the ticker, used as the avatar initials.
    var initials: String { String(ticker.prefix(2)).uppercased() }
}
