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

    // MARK: - Process-wide Cache
    private static var cachedResponse: InvestorDNAResponse?
    private static var cachedGhosts: [Ghost]?
    private static var isDirty: Bool = true

    static func markDirty() {
        isDirty = true
    }

    // MARK: - DNA Metric Scores (0–5)
    @Published var intensityScore: Int    = 0
    @Published var momentumScore: Int     = 0
    @Published var convictionScore: Int   = 0
    @Published var cautionScore: Int      = 0
    @Published var deliberationScore: Int = 0
    @Published var sensitivityScore: Int  = 0

    // MARK: - Backend Insights
    @Published var personalizedInsights: [String: String] = [:]

    // MARK: - Ghost Data
    @Published var ghosts: [Ghost] = []
    @Published var ghostsAnalyzed: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Loading Progress
    @Published var loadingProgress: Double = 0.0
    @Published var loadingPhase: Int = 0

    // MARK: - API Client
    private let apiClient = APIClient.shared

    // MARK: - Computed: View State
    var viewState: DNAViewState {
        switch ghostCount {
        case 0:        return .empty
        case 1..<7:    return .inProgress
        default:       return .filled
        }
    }

    var ghostCount: Int {
        ghostsAnalyzed > 0 ? ghostsAnalyzed : ghosts.count
    }

    var ghostsUntilUnlock: Int {
        max(0, 7 - ghosts.count)
    }

    // MARK: - Computed: Traits

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

    private var sensitityScore: Int { sensitivityScore }

    var dominantTraits: [TraitInfo] {
        allTraits
            .sorted { $0.score > $1.score }
            .prefix(3)
            .map { $0 }
    }

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

    // MARK: - Radar Chart Values

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

    let radarAxes = ["Intensity", "Momentum", "Conviction", "Caution", "Deliberation", "Sensitivity"]

    // MARK: - Recent Ghosts

    func recentGhosts(for trait: TraitInfo) -> [Ghost] {
        Array(
            ghosts
                .sorted { $0.createdAtEpochMs > $1.createdAtEpochMs }
                .prefix(3)
        )
    }

    func meaning(for trait: TraitInfo) -> String {
        personalizedInsights[trait.id] ?? trait.meaning
    }

    // MARK: - Load Data

    func loadData(force: Bool = false) async {
        if !force, !Self.isDirty, let cached = Self.cachedResponse {
            applyResponse(cached)
            if let cachedGhosts = Self.cachedGhosts {
                ghosts = cachedGhosts
            }
            errorMessage = nil
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil
        loadingProgress = 0.0
        loadingPhase = 0

        let animator = Task { await runProgressAnimation() }

        do {
            async let dnaTask: InvestorDNAResponse = apiClient.getInvestorDNA()
            async let ghostsTask: GhostListResponse = apiClient.listGhosts(limit: 100)

            let (dna, ghostList) = try await (dnaTask, ghostsTask)

            applyResponse(dna)
            ghosts = ghostList.ghosts

            Self.cachedResponse = dna
            Self.cachedGhosts = ghostList.ghosts
            Self.isDirty = false
        } catch {
            errorMessage = error.localizedDescription
        }

        animator.cancel()
        loadingProgress = 1.0
        try? await Task.sleep(nanoseconds: 250_000_000)

        isLoading = false
    }

    private func applyResponse(_ response: InvestorDNAResponse) {
        intensityScore    = response.scores.intensity
        momentumScore     = response.scores.momentum
        convictionScore   = response.scores.conviction
        cautionScore      = response.scores.caution
        deliberationScore = response.scores.deliberation
        sensitivityScore  = response.scores.sensitivity

        personalizedInsights = [
            "intensity":    response.insights.intensity,
            "momentum":     response.insights.momentum,
            "conviction":   response.insights.conviction,
            "caution":      response.insights.caution,
            "deliberation": response.insights.deliberation,
            "sensitivity":  response.insights.sensitivity
        ]
        ghostsAnalyzed = response.ghostsAnalyzed
    }

    private func runProgressAnimation() async {
        let start = Date()
        let phaseDurationSeconds: Double = 1.6
        let totalPhases = 6

        while !Task.isCancelled {
            let elapsed = Date().timeIntervalSince(start)
            let target = 0.95 * (1.0 - exp(-elapsed / 6.0))
            await MainActor.run {
                if target > self.loadingProgress { self.loadingProgress = target }
                self.loadingPhase = min(totalPhases - 1, Int(elapsed / phaseDurationSeconds))
            }
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    // MARK: - Local Metric Computation

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
