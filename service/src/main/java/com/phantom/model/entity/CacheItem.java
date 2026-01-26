package com.phantom.model.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CacheItem {
    private String pk;
    private String sk;
    private Map<String, Object> payload;
    private String fetchedAt;
    private Long expiresAt;
    private String source;
}
