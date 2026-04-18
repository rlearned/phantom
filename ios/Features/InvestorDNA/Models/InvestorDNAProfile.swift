//
//  InvestorDNAProfile.swift
//  Phantom
//
//  Data models for the Investor DNA feature.
//

import Foundation

// MARK: - Investor Archetype

enum InvestorArchetype: String {
    case cautiousAnalyst       = "The Cautious Analyst"
    case momentumChaser        = "The Momentum Chaser"
    case deliberateStrategist  = "The Deliberate Strategist"
    case reactiveTrader        = "The Reactive Trader"
    case steadyHand            = "The Steady Hand"
    case sensitiveObserver     = "The Sensitive Observer"

    var description: String {
        switch self {
        case .cautiousAnalyst:
            return "You analyze deeply and prefer certainty over speed. Your hesitation often protects you, but sometimes holds you back."
        case .momentumChaser:
            return "You thrive on market momentum and tend to follow trends. Your instincts are sharp, but patience can be a challenge."
        case .deliberateStrategist:
            return "You take your time and think several steps ahead. Your thorough approach reduces impulsive mistakes."
        case .reactiveTrader:
            return "You respond quickly to market signals. High energy and adaptability are your strengths — but so is over-trading."
        case .steadyHand:
            return "You stay composed under pressure and rarely let emotions drive your decisions. Consistency is your edge."
        case .sensitiveObserver:
            return "You are highly attuned to market sentiment and external signals. Your awareness is a strength when channeled well."
        }
    }
}

// MARK: - Trait Info

/// Represents a single behavioral trait with all display metadata.
struct TraitInfo: Identifiable {
    let id: String           // e.g. "deliberation"
    let name: String         // e.g. "Deliberation"
    let score: Int           // 0–5
    let lowLabel: String     // e.g. "Impulsive"
    let highLabel: String    // e.g. "Methodical"
    let subtitle: String     // e.g. "How much you analyze before acting"
    let meaning: String      // Full explanation paragraph(s)
    let tip: String          // Actionable advice for "What to keep in mind"

    /// Human-readable level label derived from score, e.g. "High Deliberation"
    var levelLabel: String {
        switch score {
        case 0...1: return "Low \(name)"
        case 2...3: return "Moderate \(name)"
        case 4...5: return "High \(name)"
        default:    return name
        }
    }

    /// Short one-line description for the dominant traits card.
    var shortDescription: String {
        switch id {
        case "intensity":
            return score >= 4
                ? "Most of your ghost trades happen during high-stress market moments."
                : "You tend to stay composed even during volatile market conditions."
        case "momentum":
            return score >= 4
                ? "You lean heavily toward following prevailing market trends."
                : "You split between following and fading trends."
        case "conviction":
            return score <= 2
                ? "You frequently second-guess your analysis even when signals align."
                : "You tend to act decisively once your thesis is clear."
        case "caution":
            return score >= 4
                ? "You tend to protect capital over chasing gains."
                : "You balance risk-taking with reasonable caution."
        case "deliberation":
            return score >= 4
                ? "You tend to overthink before acting, often missing windows of opportunity."
                : "You find a reasonable balance between analysis and action."
        case "sensitivity":
            return score >= 4
                ? "You are strongly influenced by market sentiment and external signals."
                : "You are moderately influenced by market sentiment."
        default:
            return ""
        }
    }

    /// Where the user falls on the spectrum as a 0.0–1.0 fraction (for bar drawing).
    var spectrumFraction: Double {
        Double(score) / 5.0
    }

    /// Label shown near the position marker, e.g. "You: Methodical"
    var youLabel: String {
        "You: \(score >= 3 ? highLabel : lowLabel)"
    }
}

// MARK: - Trait Definitions Factory

extension TraitInfo {
    /// Builds the full TraitInfo for each metric given a raw 0–5 score.
    static func allTraits(
        intensity: Int,
        momentum: Int,
        conviction: Int,
        caution: Int,
        deliberation: Int,
        sensitivity: Int
    ) -> [TraitInfo] {
        [
            TraitInfo(
                id: "intensity",
                name: "Intensity",
                score: intensity,
                lowLabel: "Calm",
                highLabel: "Reactive",
                subtitle: "How emotionally charged your trading decisions tend to be",
                meaning: """
                    High market volatility activates emotional decision-making. When markets move fast, \
                    your brain prioritizes speed over analysis. You're wired to react quickly, which means \
                    you hesitate when things spike to avoid making mistakes in chaos.

                    This is common in Momentum Chasers who wait for confirmation before acting.

                    What this means for you: You're not indecisive — you're cautious in uncertainty. The \
                    challenge is distinguishing between healthy caution and overcorrection.
                    """,
                tip: "Try setting a pre-market volatility threshold. If VIX exceeds your limit, reduce position size by half automatically — before emotions kick in."
            ),
            TraitInfo(
                id: "momentum",
                name: "Momentum",
                score: momentum,
                lowLabel: "Contrarian",
                highLabel: "Trend-follower",
                subtitle: "How much you align with prevailing market trends",
                meaning: """
                    Momentum traders perform best when trends are clear and sustained. Your tendency to \
                    follow market direction means you capture the bulk of strong moves — but you may \
                    enter late and get caught in reversals.

                    High momentum scores often correlate with FOMO-driven entries and holding too long \
                    after a trend peaks.
                    """,
                tip: "Use a trailing stop to lock in gains while still riding the trend. Define an exit rule before you enter so momentum bias doesn't hold you in past the peak."
            ),
            TraitInfo(
                id: "conviction",
                name: "Conviction",
                score: conviction,
                lowLabel: "Uncertain",
                highLabel: "Decisive",
                subtitle: "How confident you are in your own trading thesis",
                meaning: """
                    Conviction measures how much you trust your analysis when it's time to act. Low \
                    conviction doesn't mean poor research — it often means you hold yourself to an \
                    impossibly high standard before committing.

                    Most of your ghost trades likely reflect second-guessing after solid initial analysis, \
                    not a lack of preparation.
                    """,
                tip: "Write your thesis in one sentence before every trade. If you can't articulate it clearly, that's a signal to wait. If you can, commit to it."
            ),
            TraitInfo(
                id: "caution",
                name: "Caution",
                score: caution,
                lowLabel: "Risk-taker",
                highLabel: "Conservative",
                subtitle: "How much you prioritize capital protection over opportunity",
                meaning: """
                    Caution is a double-edged trait. It protects you from catastrophic losses and \
                    preserves capital during downturns. However, excessive caution leads to missed \
                    opportunities and a portfolio that never grows.

                    Your ghost trades suggest you often ghost on good setups out of risk aversion \
                    rather than poor thesis quality.
                    """,
                tip: "Define your maximum acceptable loss per trade as a fixed dollar amount, not a percentage. Knowing your hard floor reduces anxiety-driven ghosting."
            ),
            TraitInfo(
                id: "deliberation",
                name: "Deliberation",
                score: deliberation,
                lowLabel: "Impulsive",
                highLabel: "Methodical",
                subtitle: "How much you analyze before acting",
                meaning: """
                    Deliberation measures how much you analyze before acting. High deliberation means \
                    you tend to research extensively — which can protect you from bad trades, but may \
                    also cause you to miss opportunities when speed matters.

                    You're not indecisive — you're thorough. The challenge is knowing when "good enough" \
                    data is sufficient to act, rather than waiting for perfect certainty that never arrives.
                    """,
                tip: "Try setting a decision deadline. Give yourself 5 minutes of analysis, then commit. This can help you act on your research without overthinking."
            ),
            TraitInfo(
                id: "sensitivity",
                name: "Sensitivity",
                score: sensitivity,
                lowLabel: "Detached",
                highLabel: "Emotional",
                subtitle: "How much external market signals influence your decisions",
                meaning: """
                    Market sensitivity reflects how much news, social sentiment, and macro signals \
                    shape your trading behavior. High sensitivity traders are often first to react to \
                    meaningful shifts — but also first to overreact to noise.

                    Your ghost trades may cluster around high-news events, earnings, or macro data \
                    releases, suggesting you absorb external signals deeply before acting.
                    """,
                tip: "Create a news blackout window: stop reading market commentary 30 minutes before you plan to execute a trade. Trade the chart, not the headline."
            )
        ]
    }
}

// MARK: - Archetype Derivation

extension InvestorArchetype {
    /// Derives an archetype from the six raw scores.
    static func derive(
        intensity: Int,
        momentum: Int,
        conviction: Int,
        caution: Int,
        deliberation: Int,
        sensitivity: Int
    ) -> InvestorArchetype {
        // Score each archetype based on trait pattern
        if caution >= 4 && deliberation >= 4 && conviction <= 2 {
            return .cautiousAnalyst
        } else if momentum >= 4 && intensity >= 3 {
            return .momentumChaser
        } else if deliberation >= 4 && conviction >= 3 {
            return .deliberateStrategist
        } else if intensity >= 4 && sensitivity >= 4 {
            return .reactiveTrader
        } else if caution <= 2 && conviction >= 4 && intensity <= 2 {
            return .steadyHand
        } else if sensitivity >= 4 {
            return .sensitiveObserver
        } else {
            return .cautiousAnalyst // default
        }
    }
}
