package com.phantom.model.entity;

import java.util.List;
import java.util.Map;

public class Ghost {
    
    private String pk;
    private String sk;
    private String entityType;
    private String ghostId;
    private String userId;
    private Long createdAtEpochMs;
    private String ticker;
    private String direction;
    private Double intendedPrice;
    private Double intendedSize;
    private List<String> hesitationTags;
    private String noteText;
    private String voiceKey;
    private String status;
    private Map<String, Object> loggedQuote;
    
    public Ghost() {
    }
    
    public String getPk() {
        return pk;
    }
    
    public void setPk(String pk) {
        this.pk = pk;
    }
    
    public String getSk() {
        return sk;
    }
    
    public void setSk(String sk) {
        this.sk = sk;
    }
    
    public String getEntityType() {
        return entityType;
    }
    
    public void setEntityType(String entityType) {
        this.entityType = entityType;
    }
    
    public String getGhostId() {
        return ghostId;
    }
    
    public void setGhostId(String ghostId) {
        this.ghostId = ghostId;
    }
    
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public Long getCreatedAtEpochMs() {
        return createdAtEpochMs;
    }
    
    public void setCreatedAtEpochMs(Long createdAtEpochMs) {
        this.createdAtEpochMs = createdAtEpochMs;
    }
    
    public String getTicker() {
        return ticker;
    }
    
    public void setTicker(String ticker) {
        this.ticker = ticker;
    }
    
    public String getDirection() {
        return direction;
    }
    
    public void setDirection(String direction) {
        this.direction = direction;
    }
    
    public Double getIntendedPrice() {
        return intendedPrice;
    }
    
    public void setIntendedPrice(Double intendedPrice) {
        this.intendedPrice = intendedPrice;
    }
    
    public Double getIntendedSize() {
        return intendedSize;
    }
    
    public void setIntendedSize(Double intendedSize) {
        this.intendedSize = intendedSize;
    }
    
    public List<String> getHesitationTags() {
        return hesitationTags;
    }
    
    public void setHesitationTags(List<String> hesitationTags) {
        this.hesitationTags = hesitationTags;
    }
    
    public String getNoteText() {
        return noteText;
    }
    
    public void setNoteText(String noteText) {
        this.noteText = noteText;
    }
    
    public String getVoiceKey() {
        return voiceKey;
    }
    
    public void setVoiceKey(String voiceKey) {
        this.voiceKey = voiceKey;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Map<String, Object> getLoggedQuote() {
        return loggedQuote;
    }
    
    public void setLoggedQuote(Map<String, Object> loggedQuote) {
        this.loggedQuote = loggedQuote;
    }
}
