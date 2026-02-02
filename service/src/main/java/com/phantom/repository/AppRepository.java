package com.phantom.repository;

import com.phantom.model.entity.DashboardSummary;
import com.phantom.model.entity.Ghost;
import com.phantom.model.entity.UserProfile;
import com.phantom.util.Constants;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;

import java.util.*;
import java.util.stream.Collectors;

public class AppRepository extends DynamoDbRepository {
    
    public AppRepository(DynamoDbClient dynamoDbClient) {
        super(dynamoDbClient, Constants.APP_TABLE_NAME);
    }
    
    public UserProfile getUserProfile(String userId) {
        String pk = Constants.PK_USER_PREFIX + userId;
        String sk = Constants.SK_PROFILE;
        
        Map<String, AttributeValue> item = getItem(pk, sk);
        if (item == null) {
            return null;
        }
        
        return mapToUserProfile(item);
    }
    
    public void saveUserProfile(UserProfile profile) {
        Map<String, AttributeValue> item = new HashMap<>();
        item.put("pk", AttributeValue.builder().s(profile.getPk()).build());
        item.put("sk", AttributeValue.builder().s(profile.getSk()).build());
        item.put("entityType", AttributeValue.builder().s(profile.getEntityType()).build());
        item.put("userId", AttributeValue.builder().s(profile.getUserId()).build());
        item.put("createdAt", AttributeValue.builder().s(profile.getCreatedAt()).build());
        item.put("plan", AttributeValue.builder().s(profile.getPlan()).build());
        
        if (profile.getTimezone() != null) {
            item.put("timezone", AttributeValue.builder().s(profile.getTimezone()).build());
        }
        
        if (profile.getSettings() != null) {
            item.put("settings", convertMapToAttributeValue(profile.getSettings()));
        }
        
        putItem(item);
    }
    
    public void deleteUserProfile(String userId) {
        String pk = Constants.PK_USER_PREFIX + userId;
        String sk = Constants.SK_PROFILE;
        deleteItem(pk, sk);
    }
    
    public Ghost getGhost(String userId, String sk) {
        String pk = Constants.PK_USER_PREFIX + userId;
        
        Map<String, AttributeValue> item = getItem(pk, sk);
        if (item == null) {
            return null;
        }
        
        return mapToGhost(item);
    }
    
    public void saveGhost(Ghost ghost) {
        Map<String, AttributeValue> item = new HashMap<>();
        item.put(Constants.ATTR_PK, AttributeValue.builder().s(ghost.getPk()).build());
        item.put(Constants.ATTR_SK, AttributeValue.builder().s(ghost.getSk()).build());
        item.put(Constants.ATTR_ENTITY_TYPE, AttributeValue.builder().s(ghost.getEntityType()).build());
        item.put(Constants.ATTR_GHOST_ID, AttributeValue.builder().s(ghost.getGhostId()).build());
        item.put(Constants.ATTR_USER_ID, AttributeValue.builder().s(ghost.getUserId()).build());
        item.put(Constants.ATTR_CREATED_AT_EPOCH_MS, AttributeValue.builder().n(ghost.getCreatedAtEpochMs().toString()).build());
        item.put(Constants.ATTR_TICKER, AttributeValue.builder().s(ghost.getTicker()).build());
        item.put(Constants.ATTR_DIRECTION, AttributeValue.builder().s(ghost.getDirection()).build());
        item.put(Constants.ATTR_PRICE_SOURCE, AttributeValue.builder().s(ghost.getPriceSource()).build());
        item.put(Constants.ATTR_QUANTITY_TYPE, AttributeValue.builder().s(ghost.getQuantityType()).build());
        item.put(Constants.ATTR_INTENDED_PRICE, AttributeValue.builder().n(ghost.getIntendedPrice().toString()).build());
        item.put(Constants.ATTR_INTENDED_SHARES, AttributeValue.builder().n(ghost.getIntendedShares().toString()).build());
        item.put(Constants.ATTR_INTENDED_DOLLARS, AttributeValue.builder().n(ghost.getIntendedDollars().toString()).build());
        item.put(Constants.ATTR_CONSIDERED_AT, AttributeValue.builder().n(ghost.getConsideredAtEpochMs().toString()).build());
        item.put(Constants.ATTR_STATUS, AttributeValue.builder().s(ghost.getStatus()).build());
        item.put(Constants.ATTR_LOGGED_QUOTE, convertMapToAttributeValue(ghost.getLoggedQuote()));
        
        if (ghost.getHesitationTags() != null && !ghost.getHesitationTags().isEmpty()) {
            List<AttributeValue> tags = ghost.getHesitationTags().stream()
                    .map(tag -> AttributeValue.builder().s(tag).build())
                    .collect(Collectors.toList());
            item.put(Constants.ATTR_HESITATION_TAGS, AttributeValue.builder().l(tags).build());
        }
        
        if (ghost.getNoteText() != null) {
            item.put(Constants.ATTR_NOTE_TEXT, AttributeValue.builder().s(ghost.getNoteText()).build());
        }
        
        if (ghost.getVoiceKey() != null) {
            item.put(Constants.ATTR_VOICE_KEY, AttributeValue.builder().s(ghost.getVoiceKey()).build());
        }
        
        putItem(item);
    }
    
    public List<Ghost> listGhosts(String userId, int limit) {
        String pk = Constants.PK_USER_PREFIX + userId;
        
        List<Map<String, AttributeValue>> items = query(pk, Constants.SK_GHOST_PREFIX);
        
        return items.stream()
                .limit(limit)
                .map(this::mapToGhost)
                .collect(Collectors.toList());
    }
    
    public DashboardSummary getDashboardSummary(String userId) {
        String pk = Constants.PK_USER_PREFIX + userId;
        String sk = Constants.SK_DASHBOARD_SUMMARY;
        
        Map<String, AttributeValue> item = getItem(pk, sk);
        if (item == null) {
            return null;
        }
        
        return mapToDashboardSummary(item);
    }
    
    public void saveDashboardSummary(DashboardSummary summary) {
        Map<String, AttributeValue> item = new HashMap<>();
        item.put("pk", AttributeValue.builder().s(summary.getPk()).build());
        item.put("sk", AttributeValue.builder().s(summary.getSk()).build());
        item.put("entityType", AttributeValue.builder().s(summary.getEntityType()).build());
        item.put("ghostCountTotal", AttributeValue.builder().n(summary.getGhostCountTotal().toString()).build());
        item.put("ghostCount30d", AttributeValue.builder().n(summary.getGhostCount30d().toString()).build());
        
        if (summary.getLastGhostAtEpochMs() != null) {
            item.put("lastGhostAtEpochMs", AttributeValue.builder().n(summary.getLastGhostAtEpochMs().toString()).build());
        }
        
        if (summary.getStreakDays() != null) {
            item.put("streakDays", AttributeValue.builder().n(summary.getStreakDays().toString()).build());
        }
        
        if (summary.getTopHesitationTags30d() != null && !summary.getTopHesitationTags30d().isEmpty()) {
            List<AttributeValue> tags = summary.getTopHesitationTags30d().stream()
                    .map(this::convertMapToAttributeValue)
                    .collect(Collectors.toList());
            item.put("topHesitationTags30d", AttributeValue.builder().l(tags).build());
        }
        
        putItem(item);
    }
    
    private UserProfile mapToUserProfile(Map<String, AttributeValue> item) {
        UserProfile profile = new UserProfile();
        profile.setPk(getStringAttribute(item, "pk"));
        profile.setSk(getStringAttribute(item, "sk"));
        profile.setEntityType(getStringAttribute(item, "entityType"));
        profile.setUserId(getStringAttribute(item, "userId"));
        profile.setCreatedAt(getStringAttribute(item, "createdAt"));
        profile.setTimezone(getStringAttribute(item, "timezone"));
        profile.setPlan(getStringAttribute(item, "plan"));
        profile.setSettings(getMapAttribute(item, "settings"));
        return profile;
    }
    
    private Ghost mapToGhost(Map<String, AttributeValue> item) {
        Ghost ghost = new Ghost();
        ghost.setPk(getStringAttribute(item, Constants.ATTR_PK));
        ghost.setSk(getStringAttribute(item, Constants.ATTR_SK));
        ghost.setEntityType(getStringAttribute(item, Constants.ATTR_ENTITY_TYPE));
        ghost.setGhostId(getStringAttribute(item, Constants.ATTR_GHOST_ID));
        ghost.setUserId(getStringAttribute(item, Constants.ATTR_USER_ID));
        ghost.setCreatedAtEpochMs(getLongAttribute(item, Constants.ATTR_CREATED_AT_EPOCH_MS));
        ghost.setTicker(getStringAttribute(item, Constants.ATTR_TICKER));
        ghost.setDirection(getStringAttribute(item, Constants.ATTR_DIRECTION));
        ghost.setPriceSource(getStringAttribute(item, Constants.ATTR_PRICE_SOURCE));
        ghost.setQuantityType(getStringAttribute(item, Constants.ATTR_QUANTITY_TYPE));
        ghost.setIntendedPrice(getDoubleAttribute(item, Constants.ATTR_INTENDED_PRICE));
        ghost.setIntendedShares(getDoubleAttribute(item, Constants.ATTR_INTENDED_SHARES));
        ghost.setIntendedDollars(getDoubleAttribute(item, Constants.ATTR_INTENDED_DOLLARS));
        ghost.setConsideredAtEpochMs(getLongAttribute(item, Constants.ATTR_CONSIDERED_AT));
        ghost.setHesitationTags(getStringListAttribute(item, Constants.ATTR_HESITATION_TAGS));
        ghost.setNoteText(getStringAttribute(item, Constants.ATTR_NOTE_TEXT));
        ghost.setVoiceKey(getStringAttribute(item, Constants.ATTR_VOICE_KEY));
        ghost.setStatus(getStringAttribute(item, Constants.ATTR_STATUS));
        ghost.setLoggedQuote(getMapAttribute(item, Constants.ATTR_LOGGED_QUOTE));
        return ghost;
    }
    
    private DashboardSummary mapToDashboardSummary(Map<String, AttributeValue> item) {
        DashboardSummary summary = new DashboardSummary();
        summary.setPk(getStringAttribute(item, "pk"));
        summary.setSk(getStringAttribute(item, "sk"));
        summary.setEntityType(getStringAttribute(item, "entityType"));
        summary.setGhostCountTotal(getIntegerAttribute(item, "ghostCountTotal"));
        summary.setGhostCount30d(getIntegerAttribute(item, "ghostCount30d"));
        summary.setLastGhostAtEpochMs(getLongAttribute(item, "lastGhostAtEpochMs"));
        summary.setStreakDays(getIntegerAttribute(item, "streakDays"));
        
        AttributeValue tagsValue = item.get("topHesitationTags30d");
        if (tagsValue != null && tagsValue.hasL()) {
            List<Map<String, Object>> tags = tagsValue.l().stream()
                    .filter(AttributeValue::hasM)
                    .map(av -> {
                        Map<String, Object> tagMap = new HashMap<>();
                        Map<String, AttributeValue> m = av.m();
                        if (m.containsKey("tag")) {
                            tagMap.put("tag", m.get("tag").s());
                        }
                        if (m.containsKey("count")) {
                            tagMap.put("count", Integer.parseInt(m.get("count").n()));
                        }
                        return tagMap;
                    })
                    .collect(Collectors.toList());
            summary.setTopHesitationTags30d(tags);
        }
        
        return summary;
    }
    
    private AttributeValue convertMapToAttributeValue(Map<String, Object> map) {
        Map<String, AttributeValue> attributeMap = new HashMap<>();
        
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            Object value = entry.getValue();
            if (value instanceof String) {
                attributeMap.put(entry.getKey(), AttributeValue.builder().s((String) value).build());
            } else if (value instanceof Number) {
                attributeMap.put(entry.getKey(), AttributeValue.builder().n(value.toString()).build());
            } else if (value instanceof Boolean) {
                attributeMap.put(entry.getKey(), AttributeValue.builder().bool((Boolean) value).build());
            }
        }
        
        return AttributeValue.builder().m(attributeMap).build();
    }
}
