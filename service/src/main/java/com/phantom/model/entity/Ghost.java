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
public class Ghost {
    private String pk;
    private String sk;
    private String entityType;
    private String ghostId;
    private String userId;
    private Long createdAtEpochMs;
    private String ticker;
    private String direction;
    private String priceSource;
    private String quantityType;
    private Double intendedPrice;
    private Double intendedShares;
    private Double intendedDollars;
    private Long consideredAtEpochMs;
    private List<String> hesitationTags;
    private String noteText;
    private String voiceKey;
    private String status;
    private Map<String, Object> loggedQuote;
}
