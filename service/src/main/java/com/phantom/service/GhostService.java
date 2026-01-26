package com.phantom.service;

import com.phantom.model.entity.DashboardSummary;
import com.phantom.model.entity.Ghost;
import com.phantom.repository.AppRepository;
import com.phantom.repository.CacheRepository;
import com.phantom.util.Constants;
import lombok.extern.slf4j.Slf4j;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Slf4j
public class GhostService {
    
    private final AppRepository appRepository;
    private final CacheRepository cacheRepository;
    
    public GhostService(AppRepository appRepository, CacheRepository cacheRepository) {
        this.appRepository = appRepository;
        this.cacheRepository = cacheRepository;
    }
    
    public Ghost createGhost(String userId, String ticker, String direction, Double intendedPrice,
                            Double intendedSize, List<String> hesitationTags, String noteText, String voiceKey) {
        log.info("Creating ghost for userId: {}, ticker: {}", userId, ticker);
        
        String normalizedTicker = ticker.trim().toUpperCase();
        long createdAtEpochMs = System.currentTimeMillis();
        String ghostId = UUID.randomUUID().toString();
        
        Map<String, Object> loggedQuote = fetchCurrentPrice(normalizedTicker, createdAtEpochMs);
        
        Ghost ghost = new Ghost();
        ghost.setPk(Constants.PK_USER_PREFIX + userId);
        ghost.setSk(Constants.SK_GHOST_PREFIX + createdAtEpochMs + "#" + ghostId);
        ghost.setEntityType(Constants.ENTITY_TYPE_GHOST);
        ghost.setGhostId(ghostId);
        ghost.setUserId(userId);
        ghost.setCreatedAtEpochMs(createdAtEpochMs);
        ghost.setTicker(normalizedTicker);
        ghost.setDirection(direction);
        ghost.setIntendedPrice(intendedPrice);
        ghost.setIntendedSize(intendedSize);
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
    
    private Map<String, Object> fetchCurrentPrice(String ticker, long capturedAtEpochMs) {
        Map<String, Object> quote = new HashMap<>();
        quote.put("price", 0.0);
        quote.put("providerTs", "");
        quote.put("capturedAtEpochMs", capturedAtEpochMs);
        quote.put("source", Constants.SOURCE_TWELVE_DATA);
        
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
