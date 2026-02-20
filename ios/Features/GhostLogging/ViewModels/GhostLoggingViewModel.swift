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
    @Published var priceSource = "MARKET"        // "MANUAL" or "MARKET"
    @Published var quantityType = "SHARES"       // "SHARES" or "DOLLARS"
    @Published var intendedPriceText = ""        // manual price entry (scenarios A/B)
    @Published var quantityText = ""             // shares or dollar amount
    @Published var selectedTags: [String] = []
    @Published var noteText = ""
    @Published var isTickerValid = false
    @Published var isValidating = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var createdGhost: Ghost?
    
    private let apiClient = APIClient.shared
    
    var intendedPriceValue: Double? {
        Double(intendedPriceText)
    }
    
    var quantityValue: Double? {
        Double(quantityText)
    }
    
    var isStep1Valid: Bool {
        guard !ticker.isEmpty else { return false }
        guard let qty = quantityValue, qty > 0 else { return false }
        if priceSource == "MANUAL" {
            guard let price = intendedPriceValue, price > 0 else { return false }
        }
        return true
    }
    
    var isStep2Valid: Bool {
        !selectedTags.isEmpty
    }
    
    //TODO: Replace this mock with actual API call, and include logic to validate the ticker
    func validateTicker() async {
        guard !ticker.trimmingCharacters(in: .whitespaces).isEmpty else {
            isTickerValid = false
            return
        }
        
        isValidating = true
        errorMessage = nil
        
        // Mock: simulate API fetch delay (~1 second)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // TODO: Actually call apiClient.getMarketQuote(symbol: ticker) here
        isTickerValid = true
        
        isValidating = false
    }
    
    func createGhost() async {
        guard isStep1Valid && isStep2Valid else {
            errorMessage = "Please complete all required fields"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Determine the intended price
            let price: Double
            if priceSource == "MANUAL", let manualPrice = intendedPriceValue {
                price = manualPrice
            } else {
                // Fetch current market price for MARKET price source
                let quote = try await apiClient.getMarketQuote(symbol: ticker)
                price = quote.price
            }
            
            // Build request with correct quantity fields
            let request = CreateGhostRequest(
                ticker: ticker.uppercased(),
                direction: direction,
                priceSource: priceSource,
                quantityType: quantityType,
                intendedPrice: price,
                intendedShares: quantityType == "SHARES" ? quantityValue : nil,
                intendedDollars: quantityType == "DOLLARS" ? quantityValue : nil,
                hesitationTags: selectedTags.isEmpty ? nil : selectedTags,
                noteText: noteText.isEmpty ? nil : noteText,
                voiceKey: nil
            )
            
            print(request)
            
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
