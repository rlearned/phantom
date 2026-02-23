//
//  ProfileView.swift
//  Phantom
//
//  Created on 2/22/2026.
//

import SwiftUI

struct ProfileView: View {
    // TODO: Replace placeholder toggle states with real user preference storage.
    // These should be persisted in UserDefaults or backend user settings.
    @State private var pushNotificationsEnabled: Bool = true
    @State private var dailyReminderEnabled: Bool = false
    @State private var darkModeEnabled: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Page Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Profile")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(.phantomTextPrimary)

                    Text("Manage your account settings")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.phantomTextPrimary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 20)

                // MARK: - User Identity Card
                // TODO: Replace all placeholder values below with real data from the user profile API.
                // - Load user's display name, email, and member-since date via: GET /user/profile
                // - Display the user's avatar image if they have uploaded one (UserProfile.avatarUrl).
                // - The edit (pencil) button should navigate to an Edit Profile screen where the user
                //   can update their display name and avatar.
                ProfileUserCard()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                // MARK: - Account Section
                SectionHeader(title: "Account")

                ProfileSectionCard {
                    // TODO: Navigate to a Personal Information screen where the user can
                    // view and update their full name, username, and profile details.
                    ProfileRow(
                        icon: "person",
                        title: "Personal Information"
                    ) {}

                    Divider().padding(.leading, 56)

                    // TODO: Navigate to an Email Address screen where the user can
                    // update their email and verify it via Cognito.
                    ProfileRow(
                        icon: "envelope",
                        title: "Email Address"
                    ) {}

                    Divider().padding(.leading, 56)

                    // TODO: Navigate to a Password & Security screen where the user can
                    // change their password and manage MFA via AWS Cognito.
                    ProfileRow(
                        icon: "lock",
                        title: "Password & Security"
                    ) {}
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                // MARK: - Preferences Section
                SectionHeader(title: "Preferences")

                ProfileSectionCard {
                    // TODO: Wire up Push Notifications toggle to UNUserNotificationCenter.
                    // Request notification permission when enabled.
                    // Sync the preference to backend: PUT /user/settings { pushNotifications: true/false }
                    ProfileToggleRow(
                        icon: "bell",
                        title: "Push Notifications",
                        subtitle: "Receive alerts about your trades",
                        isOn: $pushNotificationsEnabled
                    )

                    Divider().padding(.leading, 56)

                    // TODO: Wire up Daily Reminder toggle to schedule a local push notification
                    // at the user's preferred time each day (e.g., 9:00 AM).
                    // Sync preference to backend: PUT /user/settings { dailyReminder: true/false }
                    ProfileToggleRow(
                        icon: "clock",
                        title: "Daily Reminder",
                        subtitle: "Get reminded to check in daily",
                        isOn: $dailyReminderEnabled
                    )

                    Divider().padding(.leading, 56)

                    // TODO: Wire up Dark Mode toggle to apply a dark color scheme app-wide.
                    // Use @Environment(\.colorScheme) and store preference in UserDefaults.
                    // Sync preference to backend: PUT /user/settings { darkMode: true/false }
                    ProfileToggleRow(
                        icon: "moon",
                        title: "Dark Mode",
                        subtitle: "Switch to Dark theme",
                        isOn: $darkModeEnabled
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                // MARK: - Support Section
                SectionHeader(title: "Support")

                ProfileSectionCard {
                    // TODO: Navigate to a Help Center web view or in-app FAQ screen.
                    // URL: Link to the Phantom help documentation or support page.
                    ProfileRow(
                        icon: "questionmark.circle",
                        title: "Help Center"
                    ) {}

                    Divider().padding(.leading, 56)

                    // TODO: Navigate to a Terms & Privacy web view showing:
                    // - Terms of Service URL
                    // - Privacy Policy URL
                    ProfileRow(
                        icon: "doc.text",
                        title: "Terms & Privacy"
                    ) {}
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                // MARK: - Log Out
                ProfileSectionCard {
                    Button {
                        // Log out via AuthManager (functional)
                        AuthManager.shared.signOut()
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .stroke(Color.black, lineWidth: 1)
                                    .frame(width: 32, height: 32)
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                            }

                            Text("Log Out")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.phantomTextPrimary)

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100) // bottom padding for tab bar
            }
        }
        .background(Color.phantomWhite)
    }
}

// MARK: - User Identity Card

struct ProfileUserCard: View {
    var body: some View {
        HStack(spacing: 16) {
            // Avatar circle
            // TODO: Load the user's actual avatar image from UserProfile.avatarUrl
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.08))
                    .frame(width: 70, height: 70)

                // TODO: Replace initials "TL" with real user initials derived from UserProfile.name
                Text("TL")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.phantomTextPrimary)

                // Online indicator dot
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.green))
                    .offset(x: 26, y: 26)
            }
            .frame(width: 70, height: 70)

            VStack(alignment: .leading, spacing: 2) {
                // TODO: Replace "Tony Li" with real display name from UserProfile
                Text("Tony Li")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.phantomTextPrimary)

                // TODO: Replace "tonyli@uw.edu" with real email from UserProfile / AuthManager
                Text("tonyli@uw.edu")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.phantomTextPrimary)

                // TODO: Replace "Jan 2026" with real member-since date from UserProfile.createdAt
                Text("Member since Jan 2026")
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.phantomTextSecondary)
                    .padding(.top, 4)
            }

            Spacer()

            // Edit profile button (top right)
            // TODO: Navigate to Edit Profile screen where user can update name and avatar
            Button {
                // TODO: Navigate to Edit Profile screen
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 14))
                    .foregroundColor(.phantomTextPrimary)
            }
            .buttonStyle(.plain)
            .frame(alignment: .topTrailing)
        }
        .padding(16)
        .background(Color(hex: "D9D9D9"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .regular))
            .foregroundColor(.phantomTextPrimary)
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
    }
}

// MARK: - Section Card Container

struct ProfileSectionCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color(hex: "EFEEEE"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}

// MARK: - Profile Row (navigation rows with chevron)

struct ProfileRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.black, lineWidth: 1)
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(.phantomTextPrimary)
                }

                Text(title)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.phantomTextPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.phantomTextPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Profile Toggle Row (settings with toggle switch)

struct ProfileToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.black, lineWidth: 1)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.phantomTextPrimary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.phantomTextPrimary)
                Text(subtitle)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.phantomTextSecondary)
            }

            Spacer()

            // TODO: Make this toggle functional by wiring it to the respective setting
            // (push notifications, daily reminder, dark mode). See ProfileView MARK comments.
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.phantomPurple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    ProfileView()
}
