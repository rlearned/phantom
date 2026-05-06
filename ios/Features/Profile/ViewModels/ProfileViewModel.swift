//
//  ProfileViewModel.swift
//  Phantom
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {

    @Published var profile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    // MARK: - Display Helpers

    var email: String {
        AuthManager.shared.currentUserEmail ?? "—"
    }

    var displayName: String {
        guard let email = AuthManager.shared.currentUserEmail else {
            return "Phantom User"
        }
        let local = email.split(separator: "@").first.map(String.init) ?? email
        let cleaned = local
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
        return cleaned.split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }

    var initials: String {
        let parts = displayName.split(separator: " ")
        if parts.count >= 2 {
            return (parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        if let first = parts.first {
            return String(first.prefix(2)).uppercased()
        }
        return "U"
    }

    var memberSince: String {
        guard let createdAtRaw = profile?.createdAt else { return "—" }
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = isoFormatter.date(from: createdAtRaw)
            ?? ISO8601DateFormatter().date(from: createdAtRaw)
        guard let date else { return "—" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return "Member since \(formatter.string(from: date))"
    }

    // MARK: - Loading

    func loadProfile() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            profile = try await apiClient.getUserProfile()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
