package com.phantom.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.phantom.model.entity.Ghost;
import com.phantom.repository.AppRepository;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Computes the 6 Investor DNA behavioral scores from a user's ghost trades and
 * generates a personalized insight string for each metric.
 *
 * Scoring is deterministic — derived from hesitation tag frequency, trade
 * direction ratios, and (when available) the user's logged emotional state.
 * The insight strings are LLM-generated when the DeepSeek key is configured,
 * with a deterministic threshold-based fallback so the user-facing experience
 * is always intact.
 */
@Slf4j
public class InvestorDNAService {

    private static final int GHOST_FETCH_LIMIT = 50;
    private static final ObjectMapper objectMapper = new ObjectMapper();

    private static final List<String> METRICS = Arrays.asList(
            "intensity", "momentum", "conviction", "caution", "deliberation", "sensitivity"
    );

    // Tag keyword groups — kept in lockstep with the iOS local fallback in
    // InvestorDNAViewModel.computeMetricsLocally so both sides agree.
    private static final List<String> INTENSITY_KEYWORDS    = Arrays.asList("fear", "fomo", "panic", "anxi", "stress", "emotion", "react");
    private static final List<String> CONVICTION_KEYWORDS   = Arrays.asList("doubt", "second_guess", "unsure", "no_thesis", "unclear", "uncertain");
    private static final List<String> CAUTION_KEYWORDS      = Arrays.asList("risk", "caution", "position", "too_risky", "capital", "loss", "safe");
    private static final List<String> DELIBERATION_KEYWORDS = Arrays.asList("over", "wait", "research", "analyz", "info", "confirm", "more_data");
    private static final List<String> SENSITIVITY_KEYWORDS  = Arrays.asList("news", "sentiment", "macro", "market_move", "earning", "fed", "event");

    // Emotion blending weights — how much the emotion compass contributes vs tags.
    // Only applied to ghosts that actually have emotion logged.
    private static final double EMOTION_BLEND_WEIGHT = 0.5;

    private final AppRepository appRepository;
    private final DeepSeekClient deepSeekClient;

    public InvestorDNAService(AppRepository appRepository, DeepSeekClient deepSeekClient) {
        this.appRepository = appRepository;
        this.deepSeekClient = deepSeekClient;
    }

    public Map<String, Object> generateProfile(String userId) {
        log.info("Generating Investor DNA profile for userId: {}", userId);

        List<Ghost> ghosts = appRepository.listGhosts(userId, GHOST_FETCH_LIMIT);
        int analyzed = ghosts.size();

        EmotionStats emotion = computeEmotionStats(ghosts);
        Map<String, Double> rates = computeRates(ghosts);
        Map<String, Integer> scores = computeScores(rates, emotion);

        Map<String, String> insights = generateInsights(scores, rates, emotion, analyzed);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("scores", scores);
        response.put("insights", insights);
        response.put("ghostsAnalyzed", analyzed);
        return response;
    }

    // ─── Score Computation ─────────────────────────────────────────────────

    Map<String, Integer> computeScores(Map<String, Double> rates, EmotionStats emotion) {
        Map<String, Integer> scores = new LinkedHashMap<>();

        if (rates.isEmpty()) {
            for (String metric : METRICS) scores.put(metric, 0);
            return scores;
        }

        double tagIntensity     = clampUnit(rates.get("intensity") * 3.0);
        double tagCaution       = clampUnit(rates.get("caution") * 3.0);
        double tagDeliberation  = clampUnit(rates.get("deliberation") * 3.5);
        double tagSensitivity   = clampUnit(rates.get("sensitivity") * 3.0);
        double tagConviction    = clampUnit((1.0 - rates.get("conviction")) * 2.0);
        double tagMomentum      = clampUnit(rates.get("momentum") * 1.5);

        // Blend in emotion data when present.
        double intensity     = blendWithEmotion(tagIntensity,    emotion.avgStress(),                       emotion.coverage());
        double caution       = blendWithEmotion(tagCaution,      1.0 - emotion.avgSentiment(),              emotion.coverage()); // fear → caution
        double sensitivity   = blendWithEmotion(tagSensitivity,  emotion.sentimentVariance() * 4.0,         emotion.coverage()); // wide swings → reactive
        double conviction    = blendWithEmotion(tagConviction,   1.0 - panicSignal(emotion),                emotion.coverage()); // high stress + extreme sentiment penalizes
        double deliberation  = tagDeliberation;   // emotion doesn't cleanly map here
        double momentum      = tagMomentum;       // emotion doesn't cleanly map here

        scores.put("intensity",    toScore(intensity));
        scores.put("momentum",     toScore(momentum));
        scores.put("conviction",   toScore(conviction));
        scores.put("caution",      toScore(caution));
        scores.put("deliberation", toScore(deliberation));
        scores.put("sensitivity",  toScore(sensitivity));

        return scores;
    }

    /**
     * Returns the raw 0.0–1.0 frequency rates for each metric so we can both
     * derive scores AND feed real evidence into the LLM prompt.
     */
    Map<String, Double> computeRates(List<Ghost> ghosts) {
        Map<String, Double> rates = new HashMap<>();
        if (ghosts.isEmpty()) return rates;

        List<String> allTags = new ArrayList<>();
        long longCount = 0;
        for (Ghost g : ghosts) {
            if (g.getHesitationTags() != null) {
                for (String t : g.getHesitationTags()) {
                    if (t != null) allTags.add(t.toLowerCase());
                }
            }
            if (g.getDirection() != null && "long".equalsIgnoreCase(g.getDirection())) {
                longCount++;
            }
        }

        rates.put("intensity",    tagRate(allTags, INTENSITY_KEYWORDS));
        rates.put("conviction",   tagRate(allTags, CONVICTION_KEYWORDS));   // raw doubt rate
        rates.put("caution",      tagRate(allTags, CAUTION_KEYWORDS));
        rates.put("deliberation", tagRate(allTags, DELIBERATION_KEYWORDS));
        rates.put("sensitivity",  tagRate(allTags, SENSITIVITY_KEYWORDS));
        rates.put("momentum",     (double) longCount / ghosts.size());
        return rates;
    }

    private double tagRate(List<String> tags, List<String> keywords) {
        if (tags.isEmpty()) return 0.0;
        long matches = tags.stream()
                .filter(tag -> keywords.stream().anyMatch(tag::contains))
                .count();
        return (double) matches / tags.size();
    }

    private double blendWithEmotion(double tagComponent, double emotionComponent, double coverage) {
        if (coverage <= 0) return clampUnit(tagComponent);
        double weight = EMOTION_BLEND_WEIGHT * coverage;
        return clampUnit((1.0 - weight) * tagComponent + weight * clampUnit(emotionComponent));
    }

    /** Scaled 0..1 panic signal: high when both stress and sentiment-extremity are high. */
    private double panicSignal(EmotionStats emotion) {
        if (emotion.coverage() <= 0) return 0.0;
        double sentimentExtremity = Math.abs(emotion.avgSentiment() - 0.5) * 2.0; // 0 at neutral, 1 at fear/greed extreme
        return clampUnit(emotion.avgStress() * sentimentExtremity);
    }

    private double clampUnit(double v) {
        return Math.max(0.0, Math.min(1.0, v));
    }

    private int toScore(double normalized) {
        return Math.min(5, Math.max(0, (int) Math.round(normalized * 5.0)));
    }

    // ─── Emotion Stats ─────────────────────────────────────────────────────

    EmotionStats computeEmotionStats(List<Ghost> ghosts) {
        if (ghosts.isEmpty()) return EmotionStats.empty();

        List<Double> stresses = new ArrayList<>();
        List<Double> sentiments = new ArrayList<>();
        for (Ghost g : ghosts) {
            if (g.getEmotionStress() != null && g.getEmotionSentiment() != null) {
                stresses.add(g.getEmotionStress());
                sentiments.add(g.getEmotionSentiment());
            }
        }

        if (stresses.isEmpty()) return EmotionStats.empty();

        double avgStress = stresses.stream().mapToDouble(Double::doubleValue).average().orElse(0.5);
        double avgSent = sentiments.stream().mapToDouble(Double::doubleValue).average().orElse(0.5);

        double sentMean = avgSent;
        double sentVar = sentiments.stream()
                .mapToDouble(d -> (d - sentMean) * (d - sentMean))
                .average().orElse(0.0);

        double coverage = (double) stresses.size() / ghosts.size();
        return new EmotionStats(avgStress, avgSent, sentVar, coverage, stresses.size());
    }

    /** Aggregate emotion stats across the analyzed ghosts. */
    static final class EmotionStats {
        private final double avgStress;
        private final double avgSentiment;
        private final double sentimentVariance;
        private final double coverage;          // fraction of ghosts that had emotion logged
        private final int    countWithEmotion;

        EmotionStats(double avgStress, double avgSentiment, double sentimentVariance, double coverage, int countWithEmotion) {
            this.avgStress = avgStress;
            this.avgSentiment = avgSentiment;
            this.sentimentVariance = sentimentVariance;
            this.coverage = coverage;
            this.countWithEmotion = countWithEmotion;
        }

        static EmotionStats empty() { return new EmotionStats(0.5, 0.5, 0.0, 0.0, 0); }

        double avgStress() { return avgStress; }
        double avgSentiment() { return avgSentiment; }
        double sentimentVariance() { return sentimentVariance; }
        double coverage() { return coverage; }
        int countWithEmotion() { return countWithEmotion; }
    }

    // ─── Insight Generation ────────────────────────────────────────────────

    Map<String, String> generateInsights(Map<String, Integer> scores, Map<String, Double> rates,
                                         EmotionStats emotion, int analyzed) {
        if (analyzed == 0) {
            return fallbackInsights(scores);
        }

        if (deepSeekClient.isConfigured()) {
            try {
                Map<String, String> llmInsights = callLlm(scores, rates, emotion, analyzed);
                if (llmInsights != null && llmInsights.size() == METRICS.size()) {
                    return llmInsights;
                }
                log.warn("LLM returned incomplete insights, falling back");
            } catch (Exception e) {
                log.error("LLM insight generation failed, using fallback", e);
            }
        } else {
            log.warn("DeepSeek not configured, using fallback insights");
        }

        return fallbackInsights(scores);
    }

    private Map<String, String> callLlm(Map<String, Integer> scores, Map<String, Double> rates,
                                        EmotionStats emotion, int analyzed) throws Exception {

        String systemPrompt =
                "You are the Phantom behavioral analytics engine — an internal scoring model that " +
                "summarizes a trader's hesitation patterns. Respond with insight text written as " +
                "if it came from a proprietary algorithm: confident, observational, second-person. " +
                "Never mention AI, language models, machine learning, or that the text was generated. " +
                "Each insight: one sentence, max 28 words, present tense, no hedging filler like " +
                "'it seems' or 'perhaps'. Output strictly valid JSON with exactly these six keys: " +
                "intensity, momentum, conviction, caution, deliberation, sensitivity.";

        String userPrompt = buildUserPrompt(scores, rates, emotion, analyzed);

        String content = deepSeekClient.complete(systemPrompt, userPrompt);
        JsonNode json = objectMapper.readTree(content);

        Map<String, String> insights = new LinkedHashMap<>();
        for (String metric : METRICS) {
            if (!json.has(metric)) return null;
            insights.put(metric, json.get(metric).asText());
        }
        return insights;
    }

    private String buildUserPrompt(Map<String, Integer> scores, Map<String, Double> rates,
                                   EmotionStats emotion, int analyzed) {
        StringBuilder sb = new StringBuilder();
        sb.append("Trader profile derived from ").append(analyzed).append(" ghost trades ");
        sb.append("(decisions the trader considered but did not execute). ");
        sb.append("Each behavioral score is on a 0–5 scale where 0 is absent and 5 is dominant.\n\n");

        sb.append("Scores:\n");
        sb.append("- intensity (emotional reactivity in volatile moments): ").append(scores.get("intensity")).append("\n");
        sb.append("- momentum (trend-following bias): ").append(scores.get("momentum")).append("\n");
        sb.append("- conviction (self-trust in own analysis): ").append(scores.get("conviction")).append("\n");
        sb.append("- caution (capital-protection orientation): ").append(scores.get("caution")).append("\n");
        sb.append("- deliberation (over-analysis tendency): ").append(scores.get("deliberation")).append("\n");
        sb.append("- sensitivity (reactivity to news/macro signals): ").append(scores.get("sensitivity")).append("\n\n");

        sb.append("Underlying tag frequencies (0.0–1.0 across all hesitation tags):\n");
        sb.append("- emotional/panic tags: ").append(fmt(rates.get("intensity"))).append("\n");
        sb.append("- doubt/second-guess tags: ").append(fmt(rates.get("conviction"))).append("\n");
        sb.append("- risk/capital-loss tags: ").append(fmt(rates.get("caution"))).append("\n");
        sb.append("- analysis/wait tags: ").append(fmt(rates.get("deliberation"))).append("\n");
        sb.append("- news/macro/event tags: ").append(fmt(rates.get("sensitivity"))).append("\n");
        sb.append("- long-direction ratio: ").append(fmt(rates.get("momentum"))).append("\n\n");

        if (emotion.coverage() > 0) {
            sb.append("Logged emotional state across ")
              .append(emotion.countWithEmotion()).append(" of ").append(analyzed)
              .append(" ghosts (compass: x = fear↔greed, y = calm↔stress, normalized 0–1):\n");
            sb.append("- average stress level: ").append(fmt(emotion.avgStress()))
              .append(" (0 = calm, 1 = high stress)\n");
            sb.append("- average sentiment: ").append(fmt(emotion.avgSentiment()))
              .append(" (0 = fear, 0.5 = neutral, 1 = greed)\n");
            sb.append("- sentiment variance: ").append(fmt(emotion.sentimentVariance()))
              .append(" (higher = more emotional swing across ghosts)\n\n");
        } else {
            sb.append("Emotional state: not logged on these ghosts.\n\n");
        }

        sb.append("Generate one insight per metric. Reference the user's actual pattern when notable ");
        sb.append("(e.g. 'Most of your ghosts cluster in the fearful, high-stress quadrant…'). ");
        sb.append("Address the user as 'you'.");
        return sb.toString();
    }

    private String fmt(Double d) {
        if (d == null) return "0";
        return String.format("%.2f", d);
    }

    // ─── Deterministic Fallback (LLM unavailable) ──────────────────────────

    private Map<String, String> fallbackInsights(Map<String, Integer> scores) {
        Map<String, String> out = new LinkedHashMap<>();
        out.put("intensity",    intensityCopy(scores.get("intensity")));
        out.put("momentum",     momentumCopy(scores.get("momentum")));
        out.put("conviction",   convictionCopy(scores.get("conviction")));
        out.put("caution",      cautionCopy(scores.get("caution")));
        out.put("deliberation", deliberationCopy(scores.get("deliberation")));
        out.put("sensitivity",  sensitivityCopy(scores.get("sensitivity")));
        return out;
    }

    private String intensityCopy(int s) {
        if (s >= 4) return "Most of your ghost trades cluster around volatile moments — emotional reactivity is a primary driver of your hesitation.";
        if (s >= 2) return "You hesitate during heightened market activity but generally keep emotion separated from your decision making.";
        return "Your ghosts rarely happen in volatile windows — you stay composed when markets get noisy.";
    }

    private String momentumCopy(int s) {
        if (s >= 4) return "You strongly favor trend-aligned setups and rarely consider counter-trend entries.";
        if (s >= 2) return "You move with momentum on some setups and fade it on others — your stance shifts with the chart.";
        return "You lean contrarian, often considering trades that cut against the prevailing direction.";
    }

    private String convictionCopy(int s) {
        if (s >= 4) return "You commit to your thesis once it forms — your ghosts are rarely about doubting your own read.";
        if (s >= 2) return "You hold a working thesis but second-guess it when the entry window arrives.";
        return "You frequently second-guess your setups even when your signals align — self-trust is your bottleneck.";
    }

    private String cautionCopy(int s) {
        if (s >= 4) return "Most of your ghosts revolve around position sizing and capital protection — you are a natural risk manager.";
        if (s >= 2) return "You weigh downside but don't let it dominate every decision.";
        return "Risk concerns rarely show up in your hesitation — you are comfortable taking exposure.";
    }

    private String deliberationCopy(int s) {
        if (s >= 4) return "You over-analyze before acting, often re-checking your thesis multiple times and missing entry windows.";
        if (s >= 2) return "You deliberate when the setup is ambiguous but act decisively when conditions are clear.";
        return "You act quickly once a setup looks viable — extended analysis is not your hesitation pattern.";
    }

    private String sensitivityCopy(int s) {
        if (s >= 4) return "News, earnings, and macro shifts heavily influence your decisions — you absorb external signal deeply.";
        if (s >= 2) return "You factor in market sentiment but it doesn't fully drive your decisions.";
        return "External noise rarely shapes your hesitation — you trade the chart, not the headline.";
    }
}
