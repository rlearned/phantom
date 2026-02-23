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
            }
        }
        .background(Color.phantomWhite)
    }
}

// MARK: - Top Action Bar

struct TopActionBar: View {
    @Binding var selectedTab: HomeTab

    var body: some View {
        HStack(spacing: 0) {
            // "Home" tab
            Button {
                selectedTab = .home
            } label: {
                Text("Home")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(selectedTab == .home ? .phantomTextPrimary : Color.black.opacity(0.35))
                    .padding(.bottom, 4)
                    .overlay(alignment: .bottom) {
                        if selectedTab == .home {
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(.phantomTextPrimary)
                        }
                    }
            }
            .buttonStyle(.plain)
            .padding(.leading, 24)

            Spacer()

            // "Hesitation" tab
            Button {
                selectedTab = .hesitation
            } label: {
                Text("Hesitation")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(selectedTab == .hesitation ? .phantomTextPrimary : Color.black.opacity(0.35))
                    .padding(.bottom, 4)
                    .overlay(alignment: .bottom) {
                        if selectedTab == .hesitation {
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(.phantomTextPrimary)
                        }
                    }
            }
            .buttonStyle(.plain)
            .padding(.trailing, 24)
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(Color.phantomWhite)
    }
}

// MARK: - Home Overview Content

struct HomeOverviewContent: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Streak Card (full width)
                // TODO: Implement streak feature.
                // Replace the placeholder value "7" with the real streak count fetched from
                // backend (DashboardSummary.streakDays or GET /streak).
                // Wire up the flame icon to animate based on streak milestones.
                HomeStreakCard()

                // MARK: - "Overview" Section Header
                Text("Overview")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.phantomTextPrimary)

                // MARK: - 2x2 Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {

                    // Ghosted Trades
                    // TODO: Replace placeholder "23" with real ghostCountTotal from
                    // DashboardSummary fetched via DashboardViewModel.
                    HomeStatCard(
                        value: "23",
                        label: "Ghosted Trades",
                        icon: nil
                    )

                    // Avg per Trade
                    // TODO: Replace placeholder "$2,081.91" with computed average:
                    // totalHesitationTax / ghostCountTotal, fetched from backend.
                    HomeStatCard(
                        value: "$2,081.91",
                        label: "Avg per Trade",
                        icon: "chart.line.uptrend.xyaxis"
                    )

                    // Total Hesitation Tax
                    // TODO: Replace placeholder "$1,023.21" with real total hesitation tax
                    // calculated from all ghost trades via the HesitationTax service.
                    HomeStatCard(
                        value: "$1,023.21",
                        label: "Total Hesitation Tax",
                        icon: "dollarsign.circle"
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

                // MARK: - Insight for This Week Card
                // TODO: Replace the placeholder insight with a real AI-generated weekly insight.
                // Implementation steps:
                //   1. Fetch the user's ghost trades for the past 7 days from the backend.
                //   2. Send trade data to an LLM/analytics endpoint (e.g., GET /insights/weekly).
                //   3. The endpoint should return: a short headline and a 1–2 sentence explanation.
                //   4. Display the returned headline as the subheading and explanation as body text.
                //   5. Refresh this insight weekly (cache with timestamp).
                InsightOfTheWeekCard()

                // Bottom padding to clear the custom tab bar
                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
    }
}

// MARK: - Streak Card Component

struct HomeStreakCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Current Streak")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.phantomTextPrimary)

                HStack(alignment: .bottom, spacing: 4) {
                    // TODO: Replace "7" with real streak value from backend (DashboardSummary.streakDays)
                    Text("7")
                        .font(.system(size: 32, weight: .regular))
                        .foregroundColor(.phantomTextPrimary)
                    Text("days")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.phantomTextPrimary)
                        .padding(.bottom, 5)
                }
            }

            Spacer()

            Image(systemName: "flame.fill")
                .font(.system(size: 28))
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}

// MARK: - Stat Card Component

struct HomeStatCard: View {
    let value: String
    let label: String
    let icon: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let icon = icon {
                HStack {
                    Spacer()
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.phantomTextPrimary)
                }
            }

            Text(value)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.phantomTextPrimary)

            Text(label)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.phantomTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 115, alignment: .topLeading)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}

// MARK: - Insight of the Week Card

struct InsightOfTheWeekCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "lightbulb")
                    .font(.system(size: 16))
                Text("Insight for this week")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.phantomTextPrimary)
                Spacer()
            }

            // TODO: Replace with real AI-generated insight headline from backend.
            // See HomeOverviewContent MARK: - Insight for This Week for implementation details.
            Text("You hesitate most on Mondays")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.phantomTextPrimary)

            Divider()
                .background(Color.black.opacity(0.2))

            // TODO: Replace with real AI-generated insight body from backend.
            Text("67% of your ghost trades happen at the start of the week. Consider setting automated entry rules to overcome this pattern.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.phantomTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}

#Preview {
    HomeView()
}
