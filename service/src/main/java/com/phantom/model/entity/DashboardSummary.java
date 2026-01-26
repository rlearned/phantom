package com.phantom.model.entity;

import java.util.List;
import java.util.Map;

public class DashboardSummary {
    
    private String pk;
    private String sk;
    private String entityType;
    private Integer ghostCountTotal;
    private Integer ghostCount30d;
    private Long lastGhostAtEpochMs;
    private Integer streakDays;
    private List<Map<String, Object>> topHesitationTags30d;
    
    public DashboardSummary() {
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
    
    public Integer getGhostCountTotal() {
        return ghostCountTotal;
    }
    
    public void setGhostCountTotal(Integer ghostCountTotal) {
        this.ghostCountTotal = ghostCountTotal;
    }
    
    public Integer getGhostCount30d() {
        return ghostCount30d;
    }
    
    public void setGhostCount30d(Integer ghostCount30d) {
        this.ghostCount30d = ghostCount30d;
    }
    
    public Long getLastGhostAtEpochMs() {
        return lastGhostAtEpochMs;
    }
    
    public void setLastGhostAtEpochMs(Long lastGhostAtEpochMs) {
        this.lastGhostAtEpochMs = lastGhostAtEpochMs;
    }
    
    public Integer getStreakDays() {
        return streakDays;
    }
    
    public void setStreakDays(Integer streakDays) {
        this.streakDays = streakDays;
    }
    
    public List<Map<String, Object>> getTopHesitationTags30d() {
        return topHesitationTags30d;
    }
    
    public void setTopHesitationTags30d(List<Map<String, Object>> topHesitationTags30d) {
        this.topHesitationTags30d = topHesitationTags30d;
    }
}
