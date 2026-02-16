package com.phantom.service;

import com.phantom.model.entity.DashboardSummary;
import com.phantom.model.entity.Ghost;
import com.phantom.repository.AppRepository;
import com.phantom.util.Constants;
import lombok.extern.slf4j.Slf4j;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Slf4j
public class GhostService {

    private static final String NO_PROVIDER_TS = "";

    private final AppRepository appRepository;
    private final MarketDataService marketDataService;

    public GhostService(AppRepository appRepository, MarketDataService marketDataService) {
        this.appRepository = appRepository;
        this.marketDataService = marketDataService;
    }
    
    public Ghost createGhost(String userId, String ticker, String direction, String priceSource,
                            Double intendedPrice, Long consideredAtEpochMs, String quantityType,
                            Double intendedSize, List<String> hesitationTags, String noteText, String voiceKey) {
        log.info("Creating ghost for userId: {}, ticker: {}, priceSource: {}", userId, ticker, priceSource);
        
        String normalizedTicker = ticker.trim().toUpperCase();
        long createdAtEpochMs = System.currentTimeMillis();
        String ghostId = UUID.randomUUID().toString();
        
        Map<String, Object> loggedQuote;
        double actualPrice;
        long effectiveConsideredAt;
        
        try {
            if (Constants.PRICE_SOURCE_MARKET_CURRENT.equals(priceSource)) {
                loggedQuote = marketDataService.getRealTimeQuote(normalizedTicker);
                actualPrice = (Double) loggedQuote.get(Constants.QUOTE_KEY_PRICE);
                effectiveConsideredAt = createdAtEpochMs;
                
            } else if (Constants.PRICE_SOURCE_MARKET_HISTORICAL.equals(priceSource)) {
                if (consideredAtEpochMs == null) {
                    throw new IllegalArgumentException("consideredAtEpochMs required for MARKET_HISTORICAL");
                }
                loggedQuote = marketDataService.getHistoricalQuote(normalizedTicker, consideredAtEpochMs);
                actualPrice = (Double) loggedQuote.get(Constants.QUOTE_KEY_PRICE);
                effectiveConsideredAt = consideredAtEpochMs;
                
            } else if (Constants.PRICE_SOURCE_MANUAL.equals(priceSource)) {
                if (intendedPrice == null) {
                    throw new IllegalArgumentException("intendedPrice required for MANUAL price source");
                }
                actualPrice = intendedPrice;
                effectiveConsideredAt = consideredAtEpochMs != null ? consideredAtEpochMs : createdAtEpochMs;
                loggedQuote = createManualQuote(actualPrice, effectiveConsideredAt);
                
            } else {
                throw new IllegalArgumentException("Invalid priceSource: " + priceSource);
            }
        } catch (Exception e) {
            log.error("Error fetching market data for {}", normalizedTicker, e);
            throw new RuntimeException("Failed to fetch market data: " + e.getMessage(), e);
        }
        
        double shares;
        double dollars;
        
        if (Constants.QUANTITY_TYPE_SHARES.equals(quantityType)) {
            shares = intendedSize;
            dollars = shares * actualPrice;
        } else if (Constants.QUANTITY_TYPE_DOLLARS.equals(quantityType)) {
            dollars = intendedSize;
            shares = dollars / actualPrice;
        } else {
            throw new IllegalArgumentException("Invalid quantityType: " + quantityType);
        }
        
        Ghost ghost = new Ghost();
        ghost.setPk(Constants.PK_USER_PREFIX + userId);
        ghost.setSk(Constants.SK_GHOST_PREFIX + createdAtEpochMs + "#" + ghostId);
        ghost.setEntityType(Constants.ENTITY_TYPE_GHOST);
        ghost.setGhostId(ghostId);
        ghost.setUserId(userId);
        ghost.setCreatedAtEpochMs(createdAtEpochMs);
        ghost.setTicker(normalizedTicker);
        ghost.setDirection(direction);
        ghost.setPriceSource(priceSource);
        ghost.setQuantityType(quantityType);
        ghost.setIntendedPrice(actualPrice);
        ghost.setIntendedShares(shares);
        ghost.setIntendedDollars(dollars);
        ghost.setConsideredAtEpochMs(effectiveConsideredAt);
        ghost.setHesitationTags(hesitationTags);
        ghost.setNoteText(noteText);
        ghost.setVoiceKey(voiceKey);
        ghost.setStatus(Constants.STATUS_OPEN);
        ghost.setLoggedQuote(loggedQuote);
        
        appRepository.saveGhost(ghost);
        
        updateDashboardOnGhostCreate(userId, createdAtEpochMs, hesitationTags);
        
        return ghost;
    }
    
    public Ghost getGhost(String userId, String sk) {
        log.info("Retrieving ghost for userId: {}, sk: {}", userId, sk);
        
        Ghost ghost = appRepository.getGhost(userId, sk);
        
        if (ghost == null) {
            throw new RuntimeException("Ghost not found");
        }
        
        return ghost;
    }
    
    public List<Ghost> listGhosts(String userId, Integer limit) {
        log.info("Listing ghosts for userId: {}", userId);
        
        int effectiveLimit = limit != null ? limit : 50;
        
        return appRepository.listGhosts(userId, effectiveLimit);
    }
    
    public Ghost updateGhost(String userId, String sk, String status, String noteText) {
        log.info("Updating ghost for userId: {}, sk: {}", userId, sk);
        
        Ghost ghost = appRepository.getGhost(userId, sk);
        
        if (ghost == null) {
            throw new RuntimeException("Ghost not found");
        }
        
        if (status != null) {
            ghost.setStatus(status);
        }
        
        if (noteText != null) {
            ghost.setNoteText(noteText);
        }
        
        appRepository.saveGhost(ghost);
        
        return ghost;
    }
    
    private Map<String, Object> createManualQuote(double price, long capturedAtEpochMs) {
        Map<String, Object> quote = new HashMap<>();
        quote.put(Constants.QUOTE_KEY_PRICE, price);
        quote.put(Constants.QUOTE_KEY_PROVIDER_TS, NO_PROVIDER_TS);
        quote.put(Constants.QUOTE_KEY_CAPTURED_AT, capturedAtEpochMs);
        quote.put(Constants.QUOTE_KEY_SOURCE, Constants.SOURCE_MANUAL);
        return quote;
    }
    
    private void updateDashboardOnGhostCreate(String userId, long createdAtEpochMs, List<String> hesitationTags) {
        DashboardSummary summary = appRepository.getDashboardSummary(userId);
        
        if (summary == null) {
            summary = new DashboardSummary();
            summary.setPk(Constants.PK_USER_PREFIX + userId);
            summary.setSk(Constants.SK_DASHBOARD_SUMMARY);
            summary.setEntityType(Constants.ENTITY_TYPE_DASH_SUMMARY);
            summary.setGhostCountTotal(0);
            summary.setGhostCount30d(0);
        }
        
        summary.setGhostCountTotal(summary.getGhostCountTotal() + 1);
        summary.setGhostCount30d(summary.getGhostCount30d() + 1);
        summary.setLastGhostAtEpochMs(createdAtEpochMs);
        
        appRepository.saveDashboardSummary(summary);
    }
}
