//
//  MainTabView.swift
//  Phantom
//
//  Created on 2/22/2026.
//

import SwiftUI

enum AppTab {
    case home
    case dashboard
    case ghosts
    case dna
    case profile
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .dashboard:
                    DashboardView(navigateToHome: {
                        selectedTab = .home
                    })
                case .ghosts:
                    RecentGhostsView()
                case .dna:
                    InvestorDNAView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            BottomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct BottomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(
                icon: "house",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }

            TabBarItem(
                icon: "plus",
                selectedIcon: "plus",
                isSelected: selectedTab == .dashboard
            ) {
                selectedTab = .dashboard
            }

            TabBarItem(
                icon: "book",
                isSelected: selectedTab == .ghosts
            ) {
                selectedTab = .ghosts
            }

            DNATabBarItem(
                isSelected: selectedTab == .dna
            ) {
                selectedTab = .dna
            }

            TabBarItem(
                icon: "person.crop.circle",
                isSelected: selectedTab == .profile
            ) {
                selectedTab = .profile
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -4)
        )
    }
}

struct TabBarItem: View {
    let icon: String
    var selectedIcon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isSelected ? (selectedIcon ?? "\(icon).fill") : icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .phantomPurple : Color.black.opacity(0.35))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - DNA Tab Bar Item

struct DNATabBarItem: View {
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.phantomPurple : Color.phantomPurple.opacity(0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: "atom")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .phantomPurple)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
}
