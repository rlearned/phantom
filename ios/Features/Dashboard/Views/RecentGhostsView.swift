//
//  RecentGhostsView.swift
//  Phantom
//

import SwiftUI

// MARK: - Root View

struct RecentGhostsView: View {
    @StateObject private var viewModel = RecentGhostsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F8F8FA").ignoresSafeArea()

                if viewModel.isLoading && viewModel.ghosts.isEmpty {
                    loadingView
                } else if viewModel.ghosts.isEmpty {
                    emptyView
                } else {
                    contentView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if viewModel.ghosts.isEmpty {
                    await viewModel.loadData()
                }
            }
        }
    }

    // MARK: - States

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Spacer()
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.phantomPurple.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "ghost")
                    .font(.system(size: 32))
                    .foregroundColor(.phantomPurple)
            }
            Text("No ghosts yet")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "#1A1A1F"))
            Text("Ghosts you log will show up here, with sorting and history.")
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "#8A8A96"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                header

                statsRow

                searchAndFilter

                sortBar

                listSection

                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .refreshable {
            await viewModel.loadData()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Your Ghosts")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "#1A1A1F"))

            Text("\(viewModel.totalCount) logged · \(viewModel.thisWeekCount) this week")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#8A8A96"))
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 10) {
            StatPill(
                value: "\(viewModel.totalCount)",
                label: "Total"
            )
            StatPill(
                value: dollarShort(viewModel.totalDollarValue),
                label: "Value"
            )
            StatPill(
                value: viewModel.mostGhostedTicker ?? "—",
                label: viewModel.mostGhostedTicker == nil
                    ? "Top ticker"
                    : "Top × \(viewModel.mostGhostedTickerCount)"
            )
        }
    }

    // MARK: - Search & Filter

    private var searchAndFilter: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(hex: "#8A8A96"))
                    .font(.system(size: 14, weight: .medium))
                TextField("Search ticker", text: $viewModel.searchText)
                    .font(.system(size: 15))
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.characters)
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(hex: "#C5C5CD"))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
            )

            HStack(spacing: 8) {
                ForEach(GhostDirectionFilter.allCases) { option in
                    FilterPill(
                        label: option.label,
                        isActive: viewModel.directionFilter == option
                    ) {
                        viewModel.directionFilter = option
                    }
                }
                Spacer()
            }
        }
    }

    // MARK: - Sort Bar

    private var sortBar: some View {
        HStack {
            Text("\(viewModel.filteredAndSorted.count) result\(viewModel.filteredAndSorted.count == 1 ? "" : "s")")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "#8A8A96"))

            Spacer()

            Menu {
                ForEach(GhostSortOption.allCases) { option in
                    Button {
                        viewModel.sortOption = option
                    } label: {
                        if viewModel.sortOption == option {
                            Label(option.label, systemImage: "checkmark")
                        } else {
                            Text(option.label)
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 12, weight: .semibold))
                    Text(viewModel.sortOption.label)
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.phantomPurple)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.phantomPurple.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }

    // MARK: - List

    private var listSection: some View {
        VStack(spacing: 10) {
            if viewModel.filteredAndSorted.isEmpty {
                Text("No matches for the current filter.")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#8A8A96"))
                    .padding(.vertical, 32)
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(viewModel.filteredAndSorted) { ghost in
                    NavigationLink {
                        GhostDetailView(ghost: ghost)
                    } label: {
                        RichGhostRow(ghost: ghost, dollarValue: viewModel.dollarValue(of: ghost))
                    }
                    .buttonStyle(.plain)
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }

    // MARK: - Helpers

    private func dollarShort(_ value: Double) -> String {
        if value >= 1_000_000 { return String(format: "$%.1fM", value / 1_000_000) }
        if value >= 1_000 { return String(format: "$%.1fK", value / 1_000) }
        return String(format: "$%.0f", value)
    }
}

// MARK: - Stat Pill

private struct StatPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "#1A1A1F"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "#8A8A96"))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#F0F0F3"), lineWidth: 1)
        )
    }
}

// MARK: - Filter Pill

private struct FilterPill: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isActive ? .white : Color(hex: "#54555A"))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isActive ? Color.phantomPurple : Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isActive ? Color.clear : Color(hex: "#E5E5E5"), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Rich Ghost Row

private struct RichGhostRow: View {
    let ghost: Ghost
    let dollarValue: Double

    private var directionUpper: String { ghost.direction.uppercased() }
    private var isBuy: Bool { directionUpper == "BUY" }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: ghost.createdDate)
    }

    private var sizeText: String {
        if let shares = ghost.intendedShares {
            return String(format: "%.2f sh", shares)
        }
        if let dollars = ghost.intendedDollars {
            return String(format: "$%.0f", dollars)
        }
        return ""
    }

    private var emotionDot: (color: Color, label: String)? {
        guard let stress = ghost.emotionStress, let sentiment = ghost.emotionSentiment else {
            return nil
        }
        if stress >= 0.6 && sentiment <= 0.4 { return (.red, "Fearful") }
        if stress >= 0.6 && sentiment >= 0.6 { return (.orange, "Greedy") }
        if stress <= 0.4 && sentiment >= 0.6 { return (.green, "Confident") }
        if stress <= 0.4 && sentiment <= 0.4 { return (.blue, "Calm") }
        return (.gray, "Mixed")
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.phantomPurple.opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(String(ghost.ticker.prefix(2)))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.phantomPurple)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(ghost.ticker)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#1A1A1F"))

                    DirectionPill(direction: directionUpper, isBuy: isBuy)
                }

                HStack(spacing: 6) {
                    Text(dateText)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#8A8A96"))

                    if let tags = ghost.hesitationTags, !tags.isEmpty {
                        Text("·")
                            .foregroundColor(Color(hex: "#C5C5CD"))
                        Image(systemName: "tag.fill")
                            .font(.system(size: 9))
                            .foregroundColor(Color(hex: "#8A8A96"))
                        Text("\(tags.count)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "#8A8A96"))
                    }

                    if let emotion = emotionDot {
                        Text("·")
                            .foregroundColor(Color(hex: "#C5C5CD"))
                        Circle()
                            .fill(emotion.color)
                            .frame(width: 6, height: 6)
                        Text(emotion.label)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "#8A8A96"))
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {
                Text(String(format: "$%.2f", ghost.intendedPrice))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1F"))
                Text(sizeText)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#8A8A96"))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#F0F0F3"), lineWidth: 1)
        )
    }
}

// MARK: - Direction Pill

private struct DirectionPill: View {
    let direction: String
    let isBuy: Bool

    var body: some View {
        Text(direction)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(isBuy ? Color(hex: "#0A8A3C") : Color(hex: "#C7341E"))
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background((isBuy ? Color(hex: "#0A8A3C") : Color(hex: "#C7341E")).opacity(0.1))
            .cornerRadius(4)
    }
}

#Preview {
    RecentGhostsView()
}
