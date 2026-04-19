//
//  GhostListView.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

struct GhostListView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.phantomWhite.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if let ghosts = viewModel.ghosts, !ghosts.isEmpty {
                        ForEach(ghosts) { ghost in
                            NavigationLink(destination: GhostDetailView(ghost: ghost)) {
                                GhostListItem(ghost: ghost)
                            }
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "ghost")
                                .font(.system(size: 64))
                                .foregroundColor(.phantomTextSecondary)
                            
                            Text("No ghosts yet")
                                .font(.phantomHeadline)
                                .foregroundColor(.phantomTextPrimary)
                            
                            Text("Start logging your missed trades")
                                .font(.phantomBodyMedium)
                                .foregroundColor(.phantomTextSecondary)
                        }
                        .padding(.top, 64)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.phantomBodySmall)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
            }
            .refreshable {
                await viewModel.loadData()
            }
        }
        .navigationTitle("All Ghosts")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadData()
        }
    }
}

// MARK: - Ghost Detail View

struct GhostDetailView: View {
    let ghost: Ghost
    @Environment(\.dismiss) var dismiss

    private var directionUpper: String { ghost.direction.uppercased() }
    private var isBuy: Bool { directionUpper == "BUY" }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy · h:mm a"
        return formatter.string(from: ghost.createdDate)
    }

    private var sizeText: String {
        if let shares = ghost.intendedShares {
            return String(format: "%.2f shares", shares)
        }
        if let dollars = ghost.intendedDollars {
            return String(format: "$%.2f", dollars)
        }
        return "—"
    }

    private var dollarValue: Double {
        if let dollars = ghost.intendedDollars { return dollars }
        if let shares = ghost.intendedShares { return shares * ghost.intendedPrice }
        return 0
    }

    var body: some View {
        ZStack {
            Color(hex: "#F8F8FA").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    heroCard
                    detailsCard
                    if let tags = ghost.hesitationTags, !tags.isEmpty {
                        hesitationCard(tags: tags)
                    }
                    if ghost.emotionStress != nil || ghost.emotionSentiment != nil {
                        emotionCard
                    }
                    if let notes = ghost.noteText, !notes.isEmpty {
                        notesCard(notes: notes)
                    }
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Hero

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(ghost.ticker)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A1F"))

                    HStack(spacing: 6) {
                        Circle()
                            .fill(isBuy ? Color(hex: "#0A8A3C") : Color(hex: "#C7341E"))
                            .frame(width: 8, height: 8)
                        Text(directionUpper)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isBuy ? Color(hex: "#0A8A3C") : Color(hex: "#C7341E"))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "$%.2f", ghost.intendedPrice))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A1F"))
                    Text(sizeText)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#8A8A96"))
                }
            }

            Text(dateText)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "#8A8A96"))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#F0F0F3"), lineWidth: 1)
        )
    }

    // MARK: - Details

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            ModernDetailRow(label: "Status", value: ghost.status)
            Divider().padding(.leading, 16)
            ModernDetailRow(label: "Position value", value: String(format: "$%.2f", dollarValue))
            Divider().padding(.leading, 16)
            ModernDetailRow(label: "Market price (at log)", value: String(format: "$%.2f", ghost.loggedQuote.price))
            Divider().padding(.leading, 16)
            ModernDetailRow(label: "Source", value: ghost.priceSource.replacingOccurrences(of: "_", with: " ").capitalized)
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#F0F0F3"), lineWidth: 1)
        )
    }

    // MARK: - Hesitation Tags

    private func hesitationCard(tags: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hesitation Reasons")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "#1A1A1F"))

            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.phantomPurple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.phantomPurple.opacity(0.1))
                        .cornerRadius(14)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#F0F0F3"), lineWidth: 1)
        )
    }

    // MARK: - Emotion

    private var emotionCard: some View {
        let stress = ghost.emotionStress ?? 0.5
        let sentiment = ghost.emotionSentiment ?? 0.5

        let stressLabel: String = {
            if stress >= 0.66 { return "High stress" }
            if stress >= 0.33 { return "Moderate stress" }
            return "Calm"
        }()
        let sentimentLabel: String = {
            if sentiment >= 0.66 { return "Greedy" }
            if sentiment >= 0.33 { return "Neutral" }
            return "Fearful"
        }()

        return VStack(alignment: .leading, spacing: 12) {
            Text("Emotional State")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "#1A1A1F"))

            HStack(spacing: 10) {
                EmotionMiniBadge(label: stressLabel, color: stress >= 0.5 ? Color(hex: "#C7341E") : Color(hex: "#0A8A3C"))
                EmotionMiniBadge(label: sentimentLabel, color: sentiment >= 0.5 ? Color(hex: "#E08A1E") : Color(hex: "#3D6FB4"))
            }

            EmotionMiniCompass(stress: stress, sentiment: sentiment)
                .frame(height: 140)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#F0F0F3"), lineWidth: 1)
        )
    }

    // MARK: - Notes

    private func notesCard(notes: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Notes")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "#1A1A1F"))

            Text(notes)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#54555A"))
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#F0F0F3"), lineWidth: 1)
        )
    }
}

// MARK: - Modern Detail Row

private struct ModernDetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#8A8A96"))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#1A1A1F"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Emotion Mini Badge

private struct EmotionMiniBadge: View {
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "#1A1A1F"))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.08))
        .cornerRadius(10)
    }
}

// MARK: - Mini Emotion Compass

private struct EmotionMiniCompass: View {
    let stress: Double
    let sentiment: Double

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.phantomLightPurple)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.phantomBorderPurple, lineWidth: 1)
                    )

                Rectangle()
                    .fill(Color.phantomBorderPurple)
                    .frame(width: 1, height: geo.size.height)
                Rectangle()
                    .fill(Color.phantomBorderPurple)
                    .frame(width: geo.size.width, height: 1)

                VStack {
                    Text("STRESS")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#8A8A96"))
                        .padding(.top, 6)
                    Spacer()
                    Text("CALM")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#8A8A96"))
                        .padding(.bottom, 6)
                }

                HStack {
                    Text("FEAR")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#8A8A96"))
                        .padding(.leading, 6)
                    Spacer()
                    Text("GREED")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#8A8A96"))
                        .padding(.trailing, 6)
                }

                Circle()
                    .fill(Color.phantomPurple)
                    .frame(width: 14, height: 14)
                    .shadow(color: Color.phantomPurple.opacity(0.35), radius: 3, x: 0, y: 1)
                    .position(
                        x: CGFloat(sentiment) * geo.size.width,
                        y: (1.0 - CGFloat(stress)) * geo.size.height
                    )
            }
        }
    }
}

// Detail Row Component
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.phantomBodyMedium)
                .foregroundColor(.phantomTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(.phantomBodyMedium)
                .foregroundColor(.phantomTextPrimary)
        }
    }
}

// Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            let pos = result.positions[index]
            subview.place(
                at: CGPoint(x: bounds.minX + pos.x, y: bounds.minY + pos.y),
                proposal: .unspecified
            )
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    NavigationStack {
        GhostListView()
    }
}
