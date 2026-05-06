//
//  ProfileView.swift
//  Phantom
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var pushNotificationsEnabled: Bool = true
    @State private var dailyReminderEnabled: Bool = false
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Page Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Profile")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "#1A1A1F"))

                    Text("Manage your account settings")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(hex: "#47474F"))
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 20)

                // MARK: - User Identity Card
                ProfileUserCard(viewModel: viewModel)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                // MARK: - Account Section
                ProfileSectionHeader(title: "Account")

                VStack(spacing: 12) {
                    ProfileRowCard(
                        icon: "person",
                        title: "Personal Information"
                    ) {}

                    ProfileRowCard(
                        icon: "envelope",
                        title: "Email Address"
                    ) {}

                    ProfileRowCard(
                        icon: "lock",
                        title: "Password & Security"
                    ) {}
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                // MARK: - Preferences Section
                ProfileSectionHeader(title: "Preferences")

                VStack(spacing: 12) {
                    ProfileToggleCard(
                        icon: "bell",
                        title: "Push Notifications",
                        subtitle: "Receive alerts about your trades",
                        isOn: $pushNotificationsEnabled
                    )

                    ProfileToggleCard(
                        icon: "clock",
                        title: "Daily Reminder",
                        subtitle: "Get reminded to check in daily",
                        isOn: $dailyReminderEnabled
                    )

                    ProfileToggleCard(
                        icon: "moon",
                        title: "Dark Mode",
                        subtitle: "Switch to Dark theme",
                        isOn: $darkModeEnabled
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                // MARK: - Support Section
                ProfileSectionHeader(title: "Support")

                VStack(spacing: 12) {
                    ProfileRowCard(
                        icon: "questionmark.circle",
                        title: "Help Center"
                    ) {}

                    ProfileRowCard(
                        icon: "doc.text",
                        title: "Terms & Privacy"
                    ) {}
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                // MARK: - Log Out
                Button {
                    AuthManager.shared.signOut()
                } label: {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#D9D9D9"))
                                .frame(width: 32, height: 32)
                                .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }

                        Text("Log Out")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(hex: "#1A1A1F"))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#8A8A96"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.phantomSurface)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }
        }
        .background(Color(hex: "#F8F8FA"))
        .task {
            await viewModel.loadProfile()
        }
    }
}

// MARK: - User Identity Card

struct ProfileUserCard: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.phantomPurple.opacity(0.15))
                    .frame(width: 70, height: 70)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 3)

                Text(viewModel.initials)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.phantomPurple)

                Circle()
                    .stroke(Color.phantomSurface, lineWidth: 2)
                    .frame(width: 18, height: 18)
                    .background(Circle().fill(Color.green))
                    .offset(x: 24, y: 24)
            }
            .frame(width: 70, height: 70)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.displayName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1F"))
                    .lineLimit(1)

                Text(viewModel.email)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#8A8A96"))
                    .lineLimit(1)

                Text(viewModel.memberSince)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "#8A8A96"))
            }

            Spacer()

            Button {
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#1A1A1F"))
            }
            .buttonStyle(.plain)
            .frame(alignment: .topTrailing)
        }
        .padding(16)
        .background(Color.phantomSurface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Section Header

struct ProfileSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(Color(hex: "#1A1A1F"))
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
    }
}

// MARK: - Profile Row Card

struct ProfileRowCard: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#D9D9D9"))
                        .frame(width: 32, height: 32)
                        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#1A1A1F"))
                }

                Text(title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(hex: "#1A1A1F"))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#8A8A96"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.phantomSurface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Profile Toggle Card

struct ProfileToggleCard: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#D9D9D9"))
                    .frame(width: 32, height: 32)
                    .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#1A1A1F"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(hex: "#1A1A1F"))
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "#8A8A96"))
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.phantomPurple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.phantomSurface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
}

#Preview {
    ProfileView()
}
