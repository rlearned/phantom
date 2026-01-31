//
//  UserProfile.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import Foundation

struct UserProfile: Codable {
    let userId: String
    let createdAt: String
    let timezone: String?
    let plan: String
    let settings: [String: AnyCodable]?
}

struct UpdateUserRequest: Codable {
    let timezone: String?
    let settings: [String: AnyCodable]?
}

// Helper to handle arbitrary JSON values
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else {
            value = [:]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let bool = value as? Bool {
            try container.encode(bool)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let string = value as? String {
            try container.encode(string)
        }
    }
}
