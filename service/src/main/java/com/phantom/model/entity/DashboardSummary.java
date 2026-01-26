package com.phantom.model.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardSummary {
    private String pk;
    private String sk;
    private String entityType;
    private Integer ghostCountTotal;
    private Integer ghostCount30d;
    private Long lastGhostAtEpochMs;
    private Integer streakDays;
    private List<Map<String, Object>> topHesitationTags30d;
}
