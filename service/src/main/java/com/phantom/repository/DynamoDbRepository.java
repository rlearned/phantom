package com.phantom.repository;

import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public abstract class DynamoDbRepository {
    
    protected final DynamoDbClient dynamoDbClient;
    protected final String tableName;
    
    protected DynamoDbRepository(DynamoDbClient dynamoDbClient, String tableName) {
        this.dynamoDbClient = dynamoDbClient;
        this.tableName = tableName;
    }
    
    protected Map<String, AttributeValue> getItem(String pk, String sk) {
        Map<String, AttributeValue> key = new HashMap<>();
        key.put("pk", AttributeValue.builder().s(pk).build());
        key.put("sk", AttributeValue.builder().s(sk).build());
        
        GetItemRequest request = GetItemRequest.builder()
                .tableName(tableName)
                .key(key)
                .build();
        
        GetItemResponse response = dynamoDbClient.getItem(request);
        return response.hasItem() ? response.item() : null;
    }
    
    protected void putItem(Map<String, AttributeValue> item) {
        PutItemRequest request = PutItemRequest.builder()
                .tableName(tableName)
                .item(item)
                .build();
        
        dynamoDbClient.putItem(request);
    }
    
    protected void updateItem(String pk, String sk, Map<String, String> updates) {
        Map<String, AttributeValue> key = new HashMap<>();
        key.put("pk", AttributeValue.builder().s(pk).build());
        key.put("sk", AttributeValue.builder().s(sk).build());
        
        StringBuilder updateExpression = new StringBuilder("SET ");
        Map<String, AttributeValue> expressionValues = new HashMap<>();
        Map<String, String> expressionNames = new HashMap<>();
        
        int i = 0;
        for (Map.Entry<String, String> entry : updates.entrySet()) {
            String placeholder = "#attr" + i;
            String valuePlaceholder = ":val" + i;
            
            if (i > 0) {
                updateExpression.append(", ");
            }
            updateExpression.append(placeholder).append(" = ").append(valuePlaceholder);
            
            expressionNames.put(placeholder, entry.getKey());
            expressionValues.put(valuePlaceholder, AttributeValue.builder().s(entry.getValue()).build());
            i++;
        }
        
        UpdateItemRequest request = UpdateItemRequest.builder()
                .tableName(tableName)
                .key(key)
                .updateExpression(updateExpression.toString())
                .expressionAttributeNames(expressionNames)
                .expressionAttributeValues(expressionValues)
                .build();
        
        dynamoDbClient.updateItem(request);
    }
    
    protected void deleteItem(String pk, String sk) {
        Map<String, AttributeValue> key = new HashMap<>();
        key.put("pk", AttributeValue.builder().s(pk).build());
        key.put("sk", AttributeValue.builder().s(sk).build());
        
        DeleteItemRequest request = DeleteItemRequest.builder()
                .tableName(tableName)
                .key(key)
                .build();
        
        dynamoDbClient.deleteItem(request);
    }
    
    protected List<Map<String, AttributeValue>> query(String pk, String skPrefix) {
        Map<String, AttributeValue> expressionValues = new HashMap<>();
        expressionValues.put(":pk", AttributeValue.builder().s(pk).build());
        
        String keyConditionExpression = "pk = :pk";
        
        if (skPrefix != null && !skPrefix.isEmpty()) {
            keyConditionExpression += " AND begins_with(sk, :sk)";
            expressionValues.put(":sk", AttributeValue.builder().s(skPrefix).build());
        }
        
        QueryRequest request = QueryRequest.builder()
                .tableName(tableName)
                .keyConditionExpression(keyConditionExpression)
                .expressionAttributeValues(expressionValues)
                .scanIndexForward(false)
                .build();
        
        QueryResponse response = dynamoDbClient.query(request);
        return response.items();
    }
    
    protected String getStringAttribute(Map<String, AttributeValue> item, String attributeName) {
        AttributeValue value = item.get(attributeName);
        return value != null && value.s() != null ? value.s() : null;
    }
    
    protected Long getLongAttribute(Map<String, AttributeValue> item, String attributeName) {
        AttributeValue value = item.get(attributeName);
        return value != null && value.n() != null ? Long.parseLong(value.n()) : null;
    }
    
    protected Integer getIntegerAttribute(Map<String, AttributeValue> item, String attributeName) {
        AttributeValue value = item.get(attributeName);
        return value != null && value.n() != null ? Integer.parseInt(value.n()) : null;
    }
    
    protected Double getDoubleAttribute(Map<String, AttributeValue> item, String attributeName) {
        AttributeValue value = item.get(attributeName);
        return value != null && value.n() != null ? Double.parseDouble(value.n()) : null;
    }
    
    protected List<String> getStringListAttribute(Map<String, AttributeValue> item, String attributeName) {
        AttributeValue value = item.get(attributeName);
        if (value != null && value.hasL()) {
            return value.l().stream()
                    .map(AttributeValue::s)
                    .collect(Collectors.toList());
        }
        return null;
    }
    
    protected Map<String, Object> getMapAttribute(Map<String, AttributeValue> item, String attributeName) {
        AttributeValue value = item.get(attributeName);
        if (value != null && value.hasM()) {
            return convertAttributeValueMapToMap(value.m());
        }
        return null;
    }
    
    private Map<String, Object> convertAttributeValueMapToMap(Map<String, AttributeValue> attributeMap) {
        Map<String, Object> result = new HashMap<>();
        for (Map.Entry<String, AttributeValue> entry : attributeMap.entrySet()) {
            AttributeValue val = entry.getValue();
            if (val.s() != null) {
                result.put(entry.getKey(), val.s());
            } else if (val.n() != null) {
                result.put(entry.getKey(), Double.parseDouble(val.n()));
            } else if (val.bool() != null) {
                result.put(entry.getKey(), val.bool());
            }
        }
        return result;
    }
}
