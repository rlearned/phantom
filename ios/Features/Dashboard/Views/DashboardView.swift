//
//  DashboardView.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingStartLog = false
    /// Called when the user taps the top-right logo button to return to the home tab.
    var navigateToHome: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.phantomWhite.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Phantom")
                                    .phantomTitleStyle()
                                
                                if let summary = viewModel.summary {
                                    Text("\(summary.ghostCountTotal) ghosts logged")
                                        .font(.phantomBodyMedium)
                                        .foregroundColor(.phantomTextSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            // TODO: Replace this purple circle with the actual Phantom logo asset.
                            // The button navigates back to the Home tab via the navigateToHome callback
                            // injected by MainTabView.
                            Button(action: {
                                navigateToHome?()
                            }) {
                                Circle()
                                    .fill(Color.phantomPurple)
                                    .frame(width: 40, height: 40)
                            }
                        }
                        
                        // Stats Cards
                        if let summary = viewModel.summary {
                            VStack(spacing: 16) {
                                // Total Ghosts
                                StatCard(
                                    title: "Total Ghosts",
                                    value: "\(summary.ghostCountTotal)",
                                    subtitle: "\(summary.ghostCount30d) in last 30 days"
                                )
                                
                                // Streak
                                if let streakDays = summary.streakDays {
                                    StatCard(
                                        title: "Current Streak",
                                        value: "\(streakDays)",
                                        subtitle: "days logging"
                                    )
                                }
                                
                                // Top Hesitation Tags
                                if let tags = summary.topHesitationTags30d, !tags.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Top Hesitation Tags (30d)")
                                            .font(.phantomBodyMedium)
                                            .foregroundColor(.phantomTextSecondary)
                                        
                                        ForEach(tags) { tag in
                                            HStack {
                                                Text(tag.tag)
                                                    .font(.phantomBodyMedium)
                                                    .foregroundColor(.phantomTextPrimary)
                                                
                                                Spacer()
                                                
                                                Text("\(tag.count)")
                                                    .font(.phantomBodyMedium)
                                                    .foregroundColor(.phantomPurple)
                                            }
                                            .padding()
                                            .background(Color.phantomLightPurple)
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Ghost List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Ghosts")
                                .phantomHeadlineStyle()
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding()
                            } else if let ghosts = viewModel.ghosts, !ghosts.isEmpty {
                                ForEach(ghosts.prefix(5)) { ghost in
                                    GhostListItem(ghost: ghost)
                                }
                                
                                if ghosts.count > 5 {
                                    NavigationLink("View All Ghosts") {
                                        GhostListView()
                                    }
                                    .font(.phantomBodyMedium)
                                    .foregroundColor(.phantomPurple)
                                    .padding(.top, 8)
                                }
                            } else {
                                Text("No ghosts yet. Start logging!")
                                    .font(.phantomBodyMedium)
                                    .foregroundColor(.phantomTextSecondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            }
                        }
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.phantomBodySmall)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 32)
                }
                .refreshable {
                    await viewModel.loadData()
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingStartLog = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 64, height: 64)
                                .background(Color.phantomPurple)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(64)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingStartLog) {
                StartLogView()
            }
            .task {
                await viewModel.loadData()
            }
        }
    }
}

// Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.phantomBodyMedium)
                .foregroundColor(.phantomTextSecondary)
            
            Text(value)
                .font(.custom("DMSans-Bold", size: 36))
                .foregroundColor(.phantomTextPrimary)
            
            Text(subtitle)
                .font(.phantomCaption)
                .foregroundColor(.phantomTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.phantomLightPurple)
        .cornerRadius(12)
    }
}

// Ghost List Item Component
struct GhostListItem: View {
    let ghost: Ghost
    
    var body: some View {
        HStack(spacing: 12) {
            // Direction Indicator
            Circle()
                .fill(ghost.direction == "BUY" ? Color.green : Color.red)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(ghost.ticker)
                    .font(.phantomBody)
                    .foregroundColor(.phantomTextPrimary)
                
                Text(ghost.createdDate, style: .date)
                    .font(.phantomCaption)
                    .foregroundColor(.phantomTextSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(ghost.direction)
                    .font(.phantomBodyMedium)
                    .foregroundColor(.phantomTextPrimary)
                
                Text("$\(ghost.intendedPrice, specifier: "%.2f")")
                    .font(.phantomCaption)
                    .foregroundColor(.phantomTextSecondary)
            }
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.phantomTextSecondary.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    DashboardView()
}
