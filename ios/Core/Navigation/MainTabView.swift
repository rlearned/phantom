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
    case book
    case profile
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            // Page content
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .dashboard:
                    DashboardView()
                case .book:
                    // Tab is intentionally non-functional — stays on current screen
                    Color.clear
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Bottom Tab Bar
            BottomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct BottomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            // House → Home
            TabBarItem(
                icon: "house",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }

            // Plus → Dashboard (Ghost Logging)
            TabBarItem(
                icon: "plus",
                isSelected: selectedTab == .dashboard
            ) {
                selectedTab = .dashboard
            }

            // Book → No-op (stays on current screen)
            TabBarItem(
                icon: "book",
                isSelected: selectedTab == .book
            ) {
                // TODO: Book feature — currently intentionally non-functional
                // Do not change selectedTab; tapping does nothing
            }

            // Person → Profile
            TabBarItem(
                icon: "person.crop.circle",
                isSelected: selectedTab == .profile
            ) {
                selectedTab = .profile
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 28) // Account for home indicator safe area
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -4)
        )
    }
}

struct TabBarItem: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isSelected ? "\(icon).fill" : icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .phantomBlack : Color.black.opacity(0.35))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
}
