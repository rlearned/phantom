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
public class UserProfile {
    private String pk;
    private String sk;
    private String entityType;
    private String userId;
    private String createdAt;
    private String timezone;
    private String plan;
    private Map<String, Object> settings;
}
