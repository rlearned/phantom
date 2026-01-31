//
//  GhostLoggingViewModel.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class GhostLoggingViewModel: ObservableObject {
    @Published var ticker = ""
    @Published var direction = "BUY"
    @Published var shareSizeText = ""
    @Published var selectedTags: [String] = []
    @Published var noteText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var createdGhost: Ghost?
    
    private let apiClient = APIClient.shared
    
    var isStep1Valid: Bool {
        !ticker.isEmpty && !shareSizeText.isEmpty && shareSize > 0
    }
    
    var isStep2Valid: Bool {
        !selectedTags.isEmpty
    }
    
    var shareSize: Double {
        Double(shareSizeText) ?? 0
    }
    
    func createGhost() async {
        guard isStep1Valid && isStep2Valid else {
            errorMessage = "Please complete all required fields"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // First, fetch current market price
            let quote = try await apiClient.getMarketQuote(symbol: ticker)
            
            // Create ghost with fetched price
            let request = CreateGhostRequest(
                ticker: ticker.uppercased(),
                direction: direction,
                intendedPrice: quote.price,
                intendedSize: shareSize,
                hesitationTags: selectedTags.isEmpty ? nil : selectedTags,
                noteText: noteText.isEmpty ? nil : noteText,
                voiceKey: nil
            )
            
            let ghost = try await apiClient.createGhost(request)
            createdGhost = ghost
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateNotes() async {
        guard let ghostId = createdGhost?.ghostId, !noteText.isEmpty else {
            return
        }
        
        isLoading = true
        
        do {
            let request = UpdateGhostRequest(status: nil, noteText: noteText)
            let updatedGhost = try await apiClient.updateGhost(ghostId: ghostId, request: request)
            createdGhost = updatedGhost
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
