package com.phantom.model.entity;

import java.util.Map;

public class CacheItem {
    
    private String pk;
    private String sk;
    private Map<String, Object> payload;
    private String fetchedAt;
    private Long expiresAt;
    private String source;
    
    public CacheItem() {
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
    
    public Map<String, Object> getPayload() {
        return payload;
    }
    
    public void setPayload(Map<String, Object> payload) {
        this.payload = payload;
    }
    
    public String getFetchedAt() {
        return fetchedAt;
    }
    
    public void setFetchedAt(String fetchedAt) {
        this.fetchedAt = fetchedAt;
    }
    
    public Long getExpiresAt() {
        return expiresAt;
    }
    
    public void setExpiresAt(Long expiresAt) {
        this.expiresAt = expiresAt;
    }
    
    public String getSource() {
        return source;
    }
    
    public void setSource(String source) {
        this.source = source;
    }
}
