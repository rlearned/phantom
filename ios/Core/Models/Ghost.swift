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
    let intendedPrice: Double
    let intendedSize: Double
    let hesitationTags: [String]?
    let noteText: String?
    let voiceKey: String?
    let status: String
    let loggedQuote: QuoteData
    
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
    let intendedPrice: Double
    let intendedSize: Double
    let hesitationTags: [String]?
    let noteText: String?
    let voiceKey: String?
}

struct UpdateGhostRequest: Codable {
    let status: String?
    let noteText: String?
}

struct GhostListResponse: Codable {
    let ghosts: [Ghost]
    let lastEvaluatedKey: String?
}
