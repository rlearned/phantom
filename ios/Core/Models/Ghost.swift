//
//  Ghost.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import Foundation

struct Ghost: Codable, Identifiable {
    let ghostId: String
    let userId: String
    let createdAtEpochMs: Int64
    let ticker: String
    let direction: String
    let priceSource: String
    let quantityType: String
    let intendedPrice: Double
    let intendedShares: Double?
    let intendedDollars: Double?
    let hesitationTags: [String]?
    let noteText: String?
    let voiceKey: String?
    let status: String
    let loggedQuote: QuoteData
    let emotionStress: Double?      // 0.0 = calm, 1.0 = high stress
    let emotionSentiment: Double?   // 0.0 = fear, 1.0 = greed

    var id: String { ghostId }
    
    var createdDate: Date {
        Date(timeIntervalSince1970: Double(createdAtEpochMs) / 1000.0)
    }
    
    var isOpen: Bool {
        status == "OPEN"
    }
}

struct QuoteData: Codable {
    let price: Double
    let providerTs: String
    let capturedAtEpochMs: Int64
    let source: String
}

struct CreateGhostRequest: Codable {
    let ticker: String
    let direction: String
    let priceSource: String
    let quantityType: String
    let intendedPrice: Double
    let intendedShares: Double?
    let intendedDollars: Double?
    let hesitationTags: [String]?
    let noteText: String?
    let voiceKey: String?
    let emotionStress: Double?
    let emotionSentiment: Double?
}

struct UpdateGhostRequest: Codable {
    let status: String?
    let noteText: String?
    let emotionStress: Double?
    let emotionSentiment: Double?
}

struct GhostListResponse: Codable {
    let ghosts: [Ghost]
    let lastEvaluatedKey: String?
}
