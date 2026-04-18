//
//  InvestorDNAView.swift
//  Phantom
//
//  Investor DNA feature — Iteration 2
//  Implements all 5 states from the Figma design.
//

import SwiftUI

// MARK: - Date Formatter Helper

private let ghostDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "MMM d"
    return f
}()

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Root View
// ─────────────────────────────────────────────────────────────────────────────

struct InvestorDNAView: View {
    @StateObject private var viewModel = InvestorDNAViewModel()

    // Sheet presentation state
    @State private var showRadarDrillDown = false
    @State private var selectedTrait: TraitInfo? = nil

    var body: some View {
        ZStack {
            // Full-screen white background — always covers the entire page
            Color.white.ignoresSafeArea()

            if viewModel.isLoading {
                loadingView
            } else {
                switch viewModel.viewState {
                case .empty:
                    DNAEmptyView()
                case .inProgress:
                    DNAInProgressView(viewModel: viewModel)
                case .filled:
                    DNAFilledView(
                        viewModel: viewModel,
                        showRadarDrillDown: $showRadarDrillDown,
                        selectedTrait: $selectedTrait
                    )
                }
            }
        }
        // Radar drill-down sheet (State 4)
        .sheet(isPresented: $showRadarDrillDown) {
            DNARadarDrillDownView(viewModel: viewModel)
        }
        // Trait detail sheet directly from dominant-trait tap (State 3 → 5)
        .sheet(item: $selectedTrait) { trait in
            DNATraitDetailView(viewModel: viewModel, trait: trait)
        }
        .task {
            await viewModel.loadData()
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Spacer()
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - State 1: Empty (0 ghosts)
// ─────────────────────────────────────────────────────────────────────────────

struct DNAEmptyView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.phantomPurple.opacity(0.1))
                        .frame(width: 80, height: 80)
                    Image(systemName: "dna")
                        .font(.system(size: 32))
                        .foregroundColor(.phantomPurple)
                }

                VStack(spacing: 10) {
                    Text("Build Your Investor DNA")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A1F"))
                        .multilineTextAlignment(.center)

                    Text("Log 3 Ghost Trades to unlock your initial profile.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(hex: "#54555A"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }

                // CTA button
                Button {
                    // TODO: Navigate to ghost logging flow
                } label: {
                    Text("Log a Ghost")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Color.phantomPurple)
                        .cornerRadius(24)
                }
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - State 2: In Progress (1–6 ghosts)
// ─────────────────────────────────────────────────────────────────────────────

struct DNAInProgressView: View {
    @ObservedObject var viewModel: InvestorDNAViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Header
                DNAHeaderView(
                    title: "Investor DNA",
                    subtitle: "Your profile is forming"
                )

                // Radar card — locked/blurred
                DNARadarInProgressCard(viewModel: viewModel)

                // Early signal banner
                if let topTrait = viewModel.earlySignalTrait {
                    DNAEarlySignalBanner(trait: topTrait, ghostCount: viewModel.ghostCount)
                }

                // Disclaimer
                Text("Your profile becomes more reliable with more data. Keep logging to build confidence in these patterns.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(hex: "#C5C5CD"))
                    .fixedSize(horizontal: false, vertical: true)

                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }
}

// MARK: Radar In-Progress Card

private struct DNARadarInProgressCard: View {
    @ObservedObject var viewModel: InvestorDNAViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Spacer()
                Text("Tendencies Forming")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1F"))
                Spacer()
            }

            // Blurred radar chart
            RadarChartView(
                axes: viewModel.radarAxes,
                values: viewModel.radarValues
            )
            .frame(height: 220)
            .blur(radius: 5)
            .overlay(
                Color(hex: "#F8F8FA").opacity(0.45)
                    .cornerRadius(8)
            )

            // Progress bar section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(viewModel.ghostCount) of 7 Logged")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#1A1A1F"))
                    Spacer()
                }

                // Progress track
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "#E8E0FF"))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.phantomPurple)
                            .frame(width: geo.size.width * min(CGFloat(viewModel.ghostCount) / 7.0, 1.0), height: 6)
                    }
                }
                .frame(height: 6)

                Text("Log \(viewModel.ghostsUntilUnlock) more ghost\(viewModel.ghostsUntilUnlock == 1 ? "" : "s") to see your full tendencies.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(hex: "#54555A"))
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
}

// MARK: Early Signal Banner

private struct DNAEarlySignalBanner: View {
    let trait: TraitInfo
    let ghostCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("EARLY SIGNAL")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "#9B82EA"))
                .tracking(1.0)

            Text("You may lean toward \(trait.levelLabel.lowercased())")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "#3D2494"))

            Text("Based on \(ghostCount) ghost trade\(ghostCount == 1 ? "" : "s") so far. This may change as you log more.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(hex: "#8A8A96"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#5B37D4").opacity(0.08))
        .cornerRadius(12)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - State 3: Filled (7+ ghosts)
// ─────────────────────────────────────────────────────────────────────────────

struct DNAFilledView: View {
    @ObservedObject var viewModel: InvestorDNAViewModel
    @Binding var showRadarDrillDown: Bool
    @Binding var selectedTrait: TraitInfo?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Header
                DNAHeaderView(
                    title: "Investor DNA",
                    subtitle: "Your behavioral profile based on \(viewModel.ghostCount) ghost trades"
                )

                // Tappable radar card
                Button {
                    showRadarDrillDown = true
                } label: {
                    DNARadarFilledCard(viewModel: viewModel)
                }
                .buttonStyle(.plain)

                // Dominant Tendencies section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Dominant Tendencies")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(hex: "#1A1A1F"))

                    ForEach(viewModel.dominantTraits) { trait in
                        Button {
                            selectedTrait = trait
                        } label: {
                            DNADominantTraitCard(trait: trait)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Disclaimer
                Text("Based on patterns in your ghost trades. This is not a prediction or financial assessment.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(hex: "#C5C5CD"))
                    .fixedSize(horizontal: false, vertical: true)

                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }
}

// MARK: Radar Filled Card

private struct DNARadarFilledCard: View {
    @ObservedObject var viewModel: InvestorDNAViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Text("Your Trading Tendencies")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1F"))
                Spacer()
            }

            RadarChartView(
                axes: viewModel.radarAxes,
                values: viewModel.radarValues
            )
            .frame(height: 240)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
}

// MARK: Dominant Trait Card

private struct DNADominantTraitCard: View {
    let trait: TraitInfo

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(trait.levelLabel)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1F"))

                Text(trait.shortDescription)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "#8A8A96"))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "#C5C5CD"))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#F8F8FA"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#F0F0F3"), lineWidth: 1)
        )
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - State 4: Radar Drill-Down Sheet
// ─────────────────────────────────────────────────────────────────────────────

struct DNARadarDrillDownView: View {
    @ObservedObject var viewModel: InvestorDNAViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header
                    DNAHeaderView(
                        title: "Investor DNA",
                        subtitle: "Your behavioral profile based on \(viewModel.ghostCount) ghost trades"
                    )

                    // Archetype Banner
                    DNAArchetypeBanner(archetype: viewModel.archetype)

                    // Trait Spectrums
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Tendencies")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(hex: "#1A1A1F"))

                        ForEach(viewModel.allTraits) { trait in
                            NavigationLink {
                                DNATraitDetailView(viewModel: viewModel, trait: trait)
                            } label: {
                                DNATraitSpectrumRow(trait: trait)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Disclaimer
                    Text("Based on patterns in your ghost trades. This is not a prediction or financial assessment.")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color(hex: "#C5C5CD"))
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .background(Color(hex: "#F8F8FA"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#8A8A96"))
                    }
                }
            }
        }
    }
}

// MARK: Archetype Banner

private struct DNAArchetypeBanner: View {
    let archetype: InvestorArchetype

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("YOUR ARCHETYPE")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "#9B82EA"))
                .tracking(1.5)

            Text(archetype.rawValue)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "#3D2494"))
                .multilineTextAlignment(.center)

            Text(archetype.description)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(hex: "#8A8A96"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#5B37D4").opacity(0.08))
        .cornerRadius(16)
    }
}

// MARK: Trait Spectrum Row

private struct DNATraitSpectrumRow: View {
    let trait: TraitInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top row: name + chevron
            HStack {
                Text(trait.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1F"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#C5C5CD"))
            }

            // Description text
            Text(trait.shortDescription)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(hex: "#8A8A96"))
                .fixedSize(horizontal: false, vertical: true)

            // Spectrum bar
            DNASpectrumBar(fraction: trait.spectrumFraction)
                .frame(height: 6)

            // Pole labels
            HStack {
                Text(trait.lowLabel)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(hex: "#C5C5CD"))
                Spacer()
                Text(trait.highLabel)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(hex: "#C5C5CD"))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#F8F8FA"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#F0F0F3"), lineWidth: 1)
        )
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - State 5: Trait Detail Screen
// ─────────────────────────────────────────────────────────────────────────────

struct DNATraitDetailView: View {
    @ObservedObject var viewModel: InvestorDNAViewModel
    let trait: TraitInfo
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // WHERE YOU FALL card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("WHERE YOU FALL")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: "#8A8A96"))
                            .tracking(1.0)

                        DNASpectrumBar(fraction: trait.spectrumFraction)
                            .frame(height: 20)

                        HStack {
                            Text(trait.lowLabel)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(Color(hex: "#C5C5CD"))
                            Spacer()
                            Text(trait.youLabel)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "#3D2494"))
                            Spacer()
                            Text(trait.highLabel)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(Color(hex: "#C5C5CD"))
                        }
                    }
                    .padding(20)
                    .background(Color(hex: "#F8F8FA"))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "#F0F0F3"), lineWidth: 1)
                    )

                    // What this means card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("What this means")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(hex: "#5B37D4"))

                        Text(trait.meaning)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(hex: "#1A1A1F"))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "#5B37D4").opacity(0.08))
                    .cornerRadius(16)

                    // In your ghosts section
                    let recentGhosts = viewModel.recentGhosts(for: trait)
                    if !recentGhosts.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("In your ghosts")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color(hex: "#1A1A1F"))

                            VStack(spacing: 0) {
                                ForEach(recentGhosts) { ghost in
                                    DNAGhostRow(ghost: ghost)
                                        .background(Color(hex: "#F8F8FA"))

                                    if ghost.ghostId != recentGhosts.last?.ghostId {
                                        Divider()
                                            .padding(.leading, 58)
                                    }
                                }
                            }
                            .background(Color(hex: "#F8F8FA"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "#F0F0F3"), lineWidth: 1)
                            )
                        }
                    }

                    // What to keep in mind card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What to keep in mind")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "#1A1A1F"))

                        Text(trait.tip)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(hex: "#8A8A96"))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "#F8F8FA"))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "#F0F0F3"), lineWidth: 1)
                    )

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color(hex: "#F8F8FA"))
            .navigationTitle(trait.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#8A8A96"))
                    }
                }
            }
        }
    }
}

// MARK: Ghost Row for Trait Detail

private struct DNAGhostRow: View {
    let ghost: Ghost

    private var directionText: String {
        ghost.direction.capitalized
    }

    private var dateText: String {
        ghostDateFormatter.string(from: ghost.createdDate)
    }

    private var notePreview: String {
        if let note = ghost.noteText, !note.isEmpty {
            return note.count > 60 ? String(note.prefix(60)) + "…" : note
        }
        return "No notes"
    }

    var body: some View {
        HStack(spacing: 14) {
            // Ticker circle
            ZStack {
                Circle()
                    .fill(Color.phantomPurple.opacity(0.12))
                    .frame(width: 40, height: 40)
                Text(String(ghost.ticker.prefix(2)))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.phantomPurple)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("\(ghost.ticker) · \(directionText)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1F"))

                Text("\(dateText) — \(notePreview)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "#8A8A96"))
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Shared Sub-Components
// ─────────────────────────────────────────────────────────────────────────────

// MARK: DNA Header View

private struct DNAHeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "#1A1A1F"))

            Text(subtitle)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(hex: "#8A8A96"))
        }
    }
}

// MARK: Spectrum Bar

/// A filled progress bar: light track + purple fill up to the position + white circle marker.
/// Matches the Figma Iteration 2 spectrum design (DDD4F9 track, 5B37D4 fill, white marker).
struct DNASpectrumBar: View {
    /// 0.0 (left/low end) to 1.0 (right/high end)
    let fraction: Double

    var body: some View {
        GeometryReader { geo in
            let clampedFraction = max(0.0, min(1.0, fraction))
            let markerSize: CGFloat = 14
            // The marker travels across (width - markerSize) so it never clips the edges
            let travelWidth = max(0, geo.size.width - markerSize)
            let markerOffset = travelWidth * clampedFraction
            // The fill rect ends at the center of the marker
            let fillWidth = markerOffset + markerSize / 2

            ZStack(alignment: .leading) {
                // Background track — full width, light purple
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: "#DDD4F9"))
                    .frame(height: 6)
                    .frame(maxHeight: .infinity, alignment: .center)

                // Filled segment — 0 → marker center, solid purple
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: "#5B37D4"))
                    .frame(width: max(0, fillWidth), height: 6)
                    .frame(maxHeight: .infinity, alignment: .center)

                // Marker circle — white fill, purple border
                Circle()
                    .fill(Color.white)
                    .frame(width: markerSize, height: markerSize)
                    .shadow(color: Color.black.opacity(0.18), radius: 2, x: 0, y: 1)
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "#5B37D4"), lineWidth: 2)
                    )
                    .offset(x: markerOffset)
                    .frame(maxHeight: .infinity, alignment: .center)
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Radar Chart View (updated to use Double 0.0–1.0)
// ─────────────────────────────────────────────────────────────────────────────

struct RadarChartView: View {
    let axes: [String]
    let values: [Double]   // 0.0 to 1.0 per axis (pass viewModel.radarValues)

    var body: some View {
        GeometryReader { geo in
            RadarChartCanvas(
                axes: axes,
                values: values,
                size: geo.size
            )
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Radar Chart Canvas
// ─────────────────────────────────────────────────────────────────────────────

private struct RadarChartCanvas: View {
    let axes: [String]
    let values: [Double]
    let size: CGSize

    private var center: CGPoint { CGPoint(x: size.width / 2, y: size.height / 2) }
    private var radius: Double  { min(size.width, size.height) / 2 - 32 }
    private let ringCount = 5   // 5 rings for a 0–5 scale

    private let gridColor   = Color(hex: "#DBDEE4")
    private let axisColor   = Color(hex: "#CFD2D7")
    private let fillColor   = Color(hex: "#3803B1").opacity(0.25)
    private let strokeColor = Color(hex: "#3803B1")
    private let labelColor  = Color(hex: "#54555A")

    var body: some View {
        ZStack {
            gridRings
            axisLines
            dataFill
            dataStroke
            centerDot
            axisLabels
        }
    }

    // MARK: Sub-Shapes

    private var gridRings: some View {
        ForEach(1...ringCount, id: \.self) { ring in
            let fraction = Double(ring) / Double(ringCount)
            hexagonPath(center: center, radius: radius * fraction, sides: axes.count)
                .stroke(gridColor, lineWidth: 1)
        }
    }

    private var axisLines: some View {
        ForEach(0..<axes.count, id: \.self) { i in
            axisLinePath(index: i)
                .stroke(axisColor, lineWidth: 1)
        }
    }

    private var dataFill: some View {
        dataPolygonPath(center: center, radius: radius)
            .fill(fillColor)
    }

    private var dataStroke: some View {
        dataPolygonPath(center: center, radius: radius)
            .stroke(strokeColor, lineWidth: 2)
    }

    private var centerDot: some View {
        Circle()
            .fill(strokeColor)
            .frame(width: 8, height: 8)
            .position(center)
    }

    private var axisLabels: some View {
        ForEach(0..<axes.count, id: \.self) { i in
            axisLabel(index: i)
        }
    }

    // MARK: Geometry Helpers

    private func angle(index: Int) -> Double {
        let degrees = -90.0 + Double(index) * (360.0 / Double(axes.count))
        return degrees * .pi / 180.0
    }

    private func axisLinePath(index i: Int) -> Path {
        let a = angle(index: i)
        let tip = CGPoint(x: center.x + cos(a) * radius,
                          y: center.y + sin(a) * radius)
        return Path { path in
            path.move(to: center)
            path.addLine(to: tip)
        }
    }

    private func hexagonPath(center: CGPoint, radius: Double, sides: Int) -> Path {
        Path { path in
            for i in 0..<sides {
                let a = -90.0 + Double(i) * (360.0 / Double(sides))
                let rad = a * .pi / 180.0
                let pt = CGPoint(x: center.x + cos(rad) * radius,
                                 y: center.y + sin(rad) * radius)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()
        }
    }

    private func dataPolygonPath(center: CGPoint, radius: Double) -> Path {
        Path { path in
            for i in 0..<axes.count {
                let a = angle(index: i)
                let v = i < values.count ? values[i] : 0.0
                let pt = CGPoint(x: center.x + cos(a) * radius * v,
                                 y: center.y + sin(a) * radius * v)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()
        }
    }

    private func axisLabel(index i: Int) -> some View {
        let a = angle(index: i)
        let labelRadius = radius + 22
        let pos = CGPoint(x: center.x + cos(a) * labelRadius,
                          y: center.y + sin(a) * labelRadius)
        return Text(axes[i])
            .font(.system(size: 10, weight: .regular))
            .foregroundColor(labelColor)
            .multilineTextAlignment(.center)
            .fixedSize()
            .position(pos)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Preview
// ─────────────────────────────────────────────────────────────────────────────

#Preview {
    InvestorDNAView()
}
