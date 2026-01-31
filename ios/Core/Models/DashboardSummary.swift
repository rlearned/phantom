//
//  DashboardSummary.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import Foundation

struct DashboardSummary: Codable {
    let ghostCountTotal: Int
    let ghostCount30d: Int
    let lastGhostAtEpochMs: Int64?
    let streakDays: Int?
    let topHesitationTags30d: [HesitationTag]?
    
    var lastGhostDate: Date? {
        guard let epochMs = lastGhostAtEpochMs else { return nil }
        return Date(timeIntervalSince1970: Double(epochMs) / 1000.0)
    }
}

struct HesitationTag: Codable, Identifiable {
    let tag: String
    let count: Int
    
    var id: String { tag }
}

struct AchievementsResponse: Codable {
    let achievements: [Achievement]?
}

struct Achievement: Codable, Identifiable {
    let id: String
    let name: String
    let unlocked: Bool
}

struct StreaksResponse: Codable {
    let currentStreak: Int
    let longestStreak: Int
}

struct MarketQuoteResponse: Codable {
    let symbol: String
    let price: Double
    let providerTs: String
    let fetchedAt: String
}
