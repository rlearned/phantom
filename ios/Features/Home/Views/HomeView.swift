//
//  HomeView.swift
//  Phantom
//
//  Created on 2/22/2026.
//

import SwiftUI

enum HomeTab {
    case home
    case hesitation
    case ghosted
    case placeholder2
}

struct HomeView: View {
    @State private var selectedHomeTab: HomeTab = .home

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Action Bar (secondary nav — only visible on Home tab of bottom bar)
            TopActionBar(selectedTab: $selectedHomeTab)

            // MARK: - Content Area
            switch selectedHomeTab {
            case .home:
                HomeOverviewContent()
            case .hesitation:
                HesitationTaxView()
            case .ghosted:
                FrequentlyGhostedAssetsView()
            case .placeholder2:
                // TODO: Replace with the real feature view when implemented
                VStack {
                    Spacer()
                    Text("Placeholder")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.phantomTextSecondary)
                    Spacer()
                }
            }
        }
        .background(Color(hex: "#F8F8FA"))
    }
}

// MARK: - Top Action Bar

struct TopActionBar: View {
    @Binding var selectedTab: HomeTab

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 28) {
                TopActionBarItem(title: "Home", tab: .home, selectedTab: $selectedTab)
                TopActionBarItem(title: "Hesitation", tab: .hesitation, selectedTab: $selectedTab)
                TopActionBarItem(title: "Ghosted", tab: .ghosted, selectedTab: $selectedTab)
                // TODO: Replace "Placeholder" with the real feature tab name when implemented
                TopActionBarItem(title: "Placeholder", tab: .placeholder2, selectedTab: $selectedTab)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 12)
        }
        .background(Color(hex: "#F8F8FA"))
    }
}

struct TopActionBarItem: View {
    let title: String
    let tab: HomeTab
    @Binding var selectedTab: HomeTab

    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            Text(title)
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(selectedTab == tab ? .phantomPurple : Color.black.opacity(0.35))
                .padding(.bottom, 4)
                .overlay(alignment: .bottom) {
                    if selectedTab == tab {
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.phantomPurple)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Home Overview Content (Home 1)

struct HomeOverviewContent: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // MARK: - Streak Card (full width)
                // TODO: Replace placeholder "7" with real streak count from backend
                // (DashboardSummary.streakDays or GET /streak).
                HomeStreakCard()

                // MARK: - Insight for This Week Card
                // TODO: Replace the placeholder insight with a real AI-generated weekly insight.
                InsightOfTheWeekCard()

                // MARK: - "Overview" Section Header
                Text("Overview")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1F"))
                    .padding(.top, 4)

                // MARK: - 2x2 Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {

                    // Ghosted Trades
                    // TODO: Replace placeholder "23" with real ghostCountTotal from
                    // DashboardSummary fetched via DashboardViewModel.
                    HomeStatCard(
                        value: "23",
                        label: "Ghosted Trades",
                        icon: "person.crop.circle.badge.questionmark"
                    )

                    // Total Hesitation Tax
                    // TODO: Replace placeholder "$1,023.21" with real total hesitation tax
                    // calculated from all ghost trades via the HesitationTax service.
                    HomeStatCard(
                        value: "$1,023.21",
                        label: "Total Hesitation Tax",
                        icon: "dollarsign.circle"
                    )

                    // Avg per Trade
                    // TODO: Replace placeholder "$2,081.91" with computed average:
                    // totalHesitationTax / ghostCountTotal, fetched from backend.
                    HomeStatCard(
                        value: "$2,081.91",
                        label: "Avg per Trade",
                        icon: "chart.line.uptrend.xyaxis"
                    )

                    // Hesitation Percentage
                    // TODO: Replace placeholder "21%" with real hesitation percentage:
                    // (hesitatedTrades / totalConsideredTrades) * 100, from backend analytics.
                    HomeStatCard(
                        value: "21%",
                        label: "Hesitation Percentage",
                        icon: "percent"
                    )
                }

                // Bottom padding to clear the custom tab bar
                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .background(Color(hex: "#F8F8FA"))
    }
}

// MARK: - Streak Card Component

struct HomeStreakCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Current Streak")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1F"))

                // TODO: Replace "7 Days" with real streak value from backend
                Text("7 Days")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "#8A8A96"))
            }

            Spacer()

            Image(systemName: "flame.fill")
                .font(.system(size: 24))
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Stat Card Component

struct HomeStatCard: View {
    let value: String
    let label: String
    let icon: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let icon = icon {
                HStack {
                    Spacer()
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#8A8A96"))
                }
            }

            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(hex: "#1A1A1F"))

            Text(label)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(hex: "#8A8A96"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 115, alignment: .topLeading)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Insight of the Week Card

struct InsightOfTheWeekCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.phantomPurple)
                Text("Insight for this week")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1F"))
                Spacer()
            }

            // TODO: Replace with real AI-generated insight headline from backend.
            Text("You hesitate most on Mondays")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(hex: "#8A8A96"))

            // TODO: Replace with real AI-generated insight body from backend.
            Text("67% of your ghost trades happen at the start of the week. Consider setting automated entry rules to overcome this pattern.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(hex: "#8A8A96"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Frequently Ghosted Assets View (Home 2)

struct FrequentlyGhostedAssetsView: View {
    @StateObject private var viewModel = GhostedAssetsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Frequently Ghosted Assets")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1F"))
                    .padding(.top, 4)

                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding(.top, 40)
                        Spacer()
                    }
                } else if viewModel.assets.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "ghost")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "#8A8A96"))
                        Text("No ghosted assets yet.\nStart logging to see your patterns.")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(hex: "#8A8A96"))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    VStack(spacing: 0) {
                        ForEach(viewModel.assets) { asset in
                            GhostedAssetRow(asset: asset)
                                .background(Color.white)

                            if asset.id != viewModel.assets.last?.id {
                                Divider()
                                    .padding(.leading, 72)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .background(Color(hex: "#F8F8FA"))
        .task {
            await viewModel.load()
        }
    }
}

// MARK: - Ghosted Asset Row

struct GhostedAssetRow: View {
    let asset: GhostedAsset

    var body: some View {
        HStack(spacing: 16) {
            // Avatar circle with initials
            ZStack {
                Circle()
                    .fill(Color.phantomPurple.opacity(0.12))
                    .frame(width: 44, height: 44)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 1)

                Text(asset.initials)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.phantomPurple)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(asset.ticker)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1F"))

                Text("Ghosted \(asset.count)×")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "#8A8A96"))
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    HomeView()
}
