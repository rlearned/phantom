//
//  InvestorDNAViewModel.swift
//  Phantom
//
//  ViewModel for the Investor DNA feature.
//  The 6 metric scores are separate @Published vars so you can manually
//  set test values before the real API is connected.
//

import Foundation
import SwiftUI
import Combine

// MARK: - View State

enum DNAViewState {
    case empty       // 0 ghosts
    case inProgress  // 1–6 ghosts
    case filled      // 7+ ghosts
}

// MARK: - ViewModel

@MainActor
class InvestorDNAViewModel: ObservableObject {

    // MARK: - DNA Metric Scores (0–5)
    // TODO: Replace manual values below with API response once GET /v1/investor-dna is ready.
    // These are kept as separate @Published vars so you can manually test any combination
    // before the backend endpoint exists.
    @Published var intensityScore: Int    = 4
    @Published var momentumScore: Int     = 3
    @Published var convictionScore: Int   = 2
    @Published var cautionScore: Int      = 5
    @Published var deliberationScore: Int = 4
    @Published var sensitivityScore: Int  = 3

    // MARK: - Ghost Data
    @Published var ghosts: [Ghost] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - API Client
    private let apiClient = APIClient.shared

    // MARK: - Computed: View State
    var viewState: DNAViewState {
        switch ghosts.count {
        case 0:        return .empty
        case 1..<7:    return .inProgress
        default:       return .filled
        }
    }

    var ghostCount: Int { ghosts.count }

    /// Number of ghosts still needed to unlock the full profile (threshold = 7).
    var ghostsUntilUnlock: Int {
        max(0, 7 - ghosts.count)
    }

    // MARK: - Computed: Traits

    /// All 6 traits with scores and metadata, in display order.
    var allTraits: [TraitInfo] {
        TraitInfo.allTraits(
            intensity:    intensityScore,
            momentum:     momentumScore,
            conviction:   convictionScore,
            caution:      cautionScore,
            deliberation: deliberationScore,
            sensitivity:  sensitityScore
        )
    }

    // Convenience alias for typo-proof internal access
    private var sensitityScore: Int { sensitivityScore }

    /// Top 3 traits sorted by score (descending), used for "Your Dominant Tendencies".
    var dominantTraits: [TraitInfo] {
        allTraits
            .sorted { $0.score > $1.score }
            .prefix(3)
            .map { $0 }
    }

    /// The first / highest-scoring trait, used for the Early Signal banner.
    var earlySignalTrait: TraitInfo? {
        allTraits.max(by: { $0.score < $1.score })
    }

    // MARK: - Computed: Archetype
    var archetype: InvestorArchetype {
        InvestorArchetype.derive(
            intensity:    intensityScore,
            momentum:     momentumScore,
            conviction:   convictionScore,
            caution:      cautionScore,
            deliberation: deliberationScore,
            sensitivity:  sensitivityScore
        )
    }

    // MARK: - Radar Chart Values (Double 0.0–1.0 for drawing)
    /// Returns values in the order: Intensity, Momentum, Conviction, Caution, Deliberation, Sensitivity
    var radarValues: [Double] {
        [
            Double(intensityScore)    / 5.0,
            Double(momentumScore)     / 5.0,
            Double(convictionScore)   / 5.0,
            Double(cautionScore)      / 5.0,
            Double(deliberationScore) / 5.0,
            Double(sensitivityScore)  / 5.0
        ]
    }

    /// Radar axis labels in display order (matches radarValues index).
    let radarAxes = ["Intensity", "Momentum", "Conviction", "Caution", "Deliberation", "Sensitivity"]

    // MARK: - Recent Ghosts for a Trait
    /// Returns up to 3 recent ghosts that are associated with a given trait.
    /// Currently returns the 3 most recent ghosts as a general proxy.
    /// TODO: Filter by hesitation tags related to the trait once tag taxonomy is finalized.
    func recentGhosts(for trait: TraitInfo) -> [Ghost] {
        Array(
            ghosts
                .sorted { $0.createdAtEpochMs > $1.createdAtEpochMs }
                .prefix(3)
        )
    }

    // MARK: - Load Data
    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            // TODO: Replace with a parallel call to GET /v1/investor-dna once the endpoint is ready.
            // That response should contain the 6 scores and write directly into the @Published vars:
            //   intensityScore    = response.intensity
            //   momentumScore     = response.momentum
            //   convictionScore   = response.conviction
            //   cautionScore      = response.caution
            //   deliberationScore = response.deliberation
            //   sensitivityScore  = response.sensitivity

            let response = try await apiClient.listGhosts(limit: 100)
            ghosts = response.ghosts

            // NOTE: Score values are currently driven by the hardcoded @Published defaults above.
            // When GET /v1/investor-dna is ready, replace those defaults with the API response here.
            // computeMetricsLocally(from: ghosts) is available below as a local fallback if needed.

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Local Metric Computation
    /// Computes 6 trait scores from ghost data using heuristics on hesitation tags and directions.
    /// This is a local fallback — replace with API scores when GET /v1/investor-dna is available.
    private func computeMetricsLocally(from ghosts: [Ghost]) {
        guard !ghosts.isEmpty else { return }

        let total = Double(ghosts.count)
        let allTags = ghosts.compactMap { $0.hesitationTags }.flatMap { $0 }.map { $0.lowercased() }

        // Helper: count tags containing any keyword
        func tagRate(keywords: [String]) -> Double {
            let matches = allTags.filter { tag in keywords.contains(where: { tag.contains($0) }) }
            return Double(matches.count) / max(Double(allTags.count), 1)
        }

        // Intensity — emotional/reactive tags
        let intensityRate = tagRate(keywords: ["fear", "fomo", "panic", "anxi", "stress", "emotion", "react"])
        intensityScore = scoreFrom(rate: intensityRate, multiplier: 3.0)

        // Momentum — ratio of LONG trades (trend-follower bias)
        let longCount = Double(ghosts.filter { $0.direction.lowercased() == "long" }.count)
        let momentumRate = longCount / total
        momentumScore = scoreFrom(rate: momentumRate, multiplier: 1.5)

        // Conviction — self-doubt tags
        let convictionRate = tagRate(keywords: ["doubt", "second_guess", "unsure", "no_thesis", "unclear", "uncertain"])
        // Low conviction = high doubt rate → invert
        let convictionRaw = 1.0 - convictionRate
        convictionScore = scoreFrom(rate: convictionRaw, multiplier: 2.0)

        // Caution — risk-averse tags
        let cautionRate = tagRate(keywords: ["risk", "caution", "position", "too_risky", "capital", "loss", "safe"])
        cautionScore = scoreFrom(rate: cautionRate, multiplier: 3.0)

        // Deliberation — over-analysis tags
        let deliberationRate = tagRate(keywords: ["over", "wait", "research", "analyz", "info", "confirm", "more_data"])
        deliberationScore = scoreFrom(rate: deliberationRate, multiplier: 3.5)

        // Sensitivity — external/sentiment tags
        let sensitivityRate = tagRate(keywords: ["news", "sentiment", "macro", "market_move", "earning", "fed", "event"])
        sensitivityScore = scoreFrom(rate: sensitivityRate, multiplier: 3.0)
    }

    /// Maps a 0.0–1.0 rate to a 0–5 integer score using the given multiplier.
    private func scoreFrom(rate: Double, multiplier: Double) -> Int {
        min(5, max(0, Int((rate * multiplier * 5).rounded())))
    }
}
