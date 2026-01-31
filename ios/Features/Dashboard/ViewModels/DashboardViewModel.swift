//
//  DashboardViewModel.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var summary: DashboardSummary?
    @Published var ghosts: [Ghost]?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        async let summaryTask = loadSummary()
        async let ghostsTask = loadGhosts()
        
        _ = await (summaryTask, ghostsTask)
        
        isLoading = false
    }
    
    private func loadSummary() async {
        do {
            let fetchedSummary = try await apiClient.getDashboardSummary()
            summary = fetchedSummary
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func loadGhosts() async {
        do {
            let response = try await apiClient.listGhosts(limit: 20)
            ghosts = response.ghosts
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
