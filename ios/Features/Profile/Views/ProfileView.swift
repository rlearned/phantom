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
                // Updated: title → titleMd (SF Pro 590 20px, #1A1A1F)
                //          subtitle → bodySm (SF Pro 400 13px, #47474F) — matches Figma 882:98
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
                // Updated: white bg, 16px radius, E5E5E5 border + shadow — matches Figma 882:92.
                // TODO: Replace all placeholder values below with real data from the user profile API.
                // - Load user's display name, email, and member-since date via: GET /user/profile
                // - Display the user's avatar image if they have uploaded one (UserProfile.avatarUrl).
                // - The edit (pencil) button should navigate to an Edit Profile screen where the user
                //   can update their display name and avatar.
                ProfileUserCard()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                // MARK: - Account Section
                // Updated: section header → titleMd (SF Pro 590 20px, #1A1A1F)
                ProfileSectionHeader(title: "Account")

                // Updated: each row is its own individual card (was one grouped card)
                VStack(spacing: 12) {
                    // TODO: Navigate to a Personal Information screen where the user can
                    // view and update their full name, username, and profile details.
                    ProfileRowCard(
                        icon: "person",
                        title: "Personal Information"
                    ) {}

                    // TODO: Navigate to an Email Address screen where the user can
                    // update their email and verify it via Cognito.
                    ProfileRowCard(
                        icon: "envelope",
                        title: "Email Address"
                    ) {}

                    // TODO: Navigate to a Password & Security screen where the user can
                    // change their password and manage MFA via AWS Cognito.
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
                    // TODO: Wire up Push Notifications toggle to UNUserNotificationCenter.
                    // Request notification permission when enabled.
                    // Sync the preference to backend: PUT /user/settings { pushNotifications: true/false }
                    ProfileToggleCard(
                        icon: "bell",
                        title: "Push Notifications",
                        subtitle: "Receive alerts about your trades",
                        isOn: $pushNotificationsEnabled
                    )

                    // TODO: Wire up Daily Reminder toggle to schedule a local push notification
                    // at the user's preferred time each day (e.g., 9:00 AM).
                    // Sync preference to backend: PUT /user/settings { dailyReminder: true/false }
                    ProfileToggleCard(
                        icon: "clock",
                        title: "Daily Reminder",
                        subtitle: "Get reminded to check in daily",
                        isOn: $dailyReminderEnabled
                    )

                    // TODO: Wire up Dark Mode toggle to apply a dark color scheme app-wide.
                    // Use @Environment(\.colorScheme) and store preference in UserDefaults.
                    // Sync preference to backend: PUT /user/settings { darkMode: true/false }
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
                    // TODO: Navigate to a Help Center web view or in-app FAQ screen.
                    ProfileRowCard(
                        icon: "questionmark.circle",
                        title: "Help Center"
                    ) {}

                    // TODO: Navigate to a Terms & Privacy web view showing:
                    // - Terms of Service URL
                    // - Privacy Policy URL
                    ProfileRowCard(
                        icon: "doc.text",
                        title: "Terms & Privacy"
                    ) {}
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                // MARK: - Log Out
                // Individual card style matching other rows
                Button {
                    // Log out via AuthManager (functional)
                    AuthManager.shared.signOut()
                } label: {
                    HStack(spacing: 16) {
                        // Updated: grey fill circle with shadow (matches row icon style)
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
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 100) // bottom padding for tab bar
            }
        }
        .background(Color(hex: "#F8F8FA")) // Updated: was .phantomWhite
    }
}

// MARK: - User Identity Card

struct ProfileUserCard: View {
    var body: some View {
        // Updated: white card, 16px radius, E5E5E5 border + shadow — matches Figma 882:92
        HStack(spacing: 16) {
            // Avatar circle — Updated: #D9D9D9 fill + shadow (Figma: Ellipse 4, fill_Y6QPJF)
            // TODO: Load the user's actual avatar image from UserProfile.avatarUrl
            ZStack {
                Circle()
                    .fill(Color(hex: "#D9D9D9"))
                    .frame(width: 70, height: 70)
                    .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 3)

                // TODO: Replace initials "TL" with real user initials derived from UserProfile.name
                Text("U")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(Color(hex: "#1A1A1F"))

                // Online indicator dot
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.green))
                    .offset(x: 26, y: 26)
            }
            .frame(width: 70, height: 70)

            VStack(alignment: .leading, spacing: 4) {
                // Updated: titleSm (SF Pro 590 17pt, #1A1A1F) — matches Figma 882:95
                // TODO: Replace "Username" with real display name from UserProfile
                Text("Username")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1F"))

                // Updated: caption (SF Pro 510 11pt, #8A8A96) — matches Figma 882:194
                // TODO: Replace "user@uw.edu" with real email from UserProfile / AuthManager
                Text("user@uw.edu")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "#8A8A96"))

                // Updated: caption style, #8A8A96 — matches Figma 882:196
                // TODO: Replace "sometime..." with real member-since date from UserProfile.createdAt
                Text("Member since sometime...")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "#8A8A96"))
            }

            Spacer()

            // Edit profile button — matches Figma 882:198 (pencil icon, top-right)
            // TODO: Navigate to Edit Profile screen where user can update name and avatar
            Button {
                // TODO: Navigate to Edit Profile screen
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#1A1A1F"))
            }
            .buttonStyle(.plain)
            .frame(alignment: .topTrailing)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
        )
        // Updated shadow: effect_X9QCSI from Figma
        .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Section Header
// Updated: titleMd (SF Pro 590 20px, #1A1A1F) — matches Figma 882:96 / 882:200

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
// Updated: individual white card per row (was grouped card with dividers).
// Icon: grey fill circle with shadow; title: bodyMd (SF Pro 400 15px, #1A1A1F).
// Matches Figma 882:218 / 882:230.

struct ProfileRowCard: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Updated: grey fill + shadow (was black stroke circle)
                ZStack {
                    Circle()
                        .fill(Color(hex: "#D9D9D9"))
                        .frame(width: 32, height: 32)
                        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#1A1A1F"))
                }

                // Updated: bodyMd (SF Pro 400 15px, #1A1A1F)
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
            .background(Color.white)
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
// Updated: individual white card per toggle row; same card style as ProfileRowCard.
// TODO: Make each toggle functional — see ProfileView MARK comments.

struct ProfileToggleCard: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Updated: grey fill + shadow
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
                // Updated: bodyMd (SF Pro 400 15px, #1A1A1F)
                Text(title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(hex: "#1A1A1F"))
                // Caption style, #8A8A96
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
        .background(Color.white)
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
