package com.phantom.repository;

import com.phantom.model.entity.CacheItem;
import com.phantom.util.Constants;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;

import java.util.HashMap;
import java.util.Map;

public class CacheRepository extends DynamoDbRepository {
    
    public CacheRepository(DynamoDbClient dynamoDbClient) {
        super(dynamoDbClient, Constants.CACHE_TABLE_NAME);
    }
    
    public CacheItem getCacheItem(String pk, String sk) {
        Map<String, AttributeValue> item = getItem(pk, sk);
        if (item == null) {
            return null;
        }
        
        return mapToCacheItem(item);
    }
    
    public void saveCacheItem(CacheItem cacheItem) {
        Map<String, AttributeValue> item = new HashMap<>();
        item.put("pk", AttributeValue.builder().s(cacheItem.getPk()).build());
        item.put("sk", AttributeValue.builder().s(cacheItem.getSk()).build());
        item.put("fetchedAt", AttributeValue.builder().s(cacheItem.getFetchedAt()).build());
        item.put("expiresAt", AttributeValue.builder().n(cacheItem.getExpiresAt().toString()).build());
        item.put("source", AttributeValue.builder().s(cacheItem.getSource()).build());
        
        if (cacheItem.getPayload() != null) {
            item.put("payload", convertMapToAttributeValue(cacheItem.getPayload()));
        }
        
        putItem(item);
    }
    
    public CacheItem getLatestPrice(String symbol) {
        String pk = Constants.PK_MARKET_DATA_PREFIX + symbol.toUpperCase();
        String sk = Constants.SK_PRICE_LATEST;
        
        return getCacheItem(pk, sk);
    }
    
    public CacheItem getTimeSeries(String symbol, String interval, String range) {
        String pk = Constants.PK_MARKET_DATA_PREFIX + symbol.toUpperCase();
        String sk = Constants.SK_TIMESERIES_PREFIX + interval + "#" + range;
        
        return getCacheItem(pk, sk);
    }
    
    public CacheItem getSearchResults(String query) {
        String pk = Constants.PK_SEARCH;
        String sk = Constants.SK_SEARCH_QUERY_PREFIX + query.toLowerCase();
        
        return getCacheItem(pk, sk);
    }
    
    private CacheItem mapToCacheItem(Map<String, AttributeValue> item) {
        CacheItem cacheItem = new CacheItem();
        cacheItem.setPk(getStringAttribute(item, "pk"));
        cacheItem.setSk(getStringAttribute(item, "sk"));
        cacheItem.setFetchedAt(getStringAttribute(item, "fetchedAt"));
        cacheItem.setExpiresAt(getLongAttribute(item, "expiresAt"));
        cacheItem.setSource(getStringAttribute(item, "source"));
        cacheItem.setPayload(getMapAttribute(item, "payload"));
        return cacheItem;
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
