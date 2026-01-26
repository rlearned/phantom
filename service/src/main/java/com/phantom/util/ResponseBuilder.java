package com.phantom.util;

import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import java.util.HashMap;
import java.util.Map;

public class ResponseBuilder {
    
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper()
            .registerModule(new JavaTimeModule())
            .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
    
    public static APIGatewayV2HTTPResponse ok(Object body) {
        return buildResponse(200, body);
    }
    
    public static APIGatewayV2HTTPResponse created(Object body) {
        return buildResponse(201, body);
    }
    
    public static APIGatewayV2HTTPResponse noContent() {
        return buildResponse(204, null);
    }
    
    public static APIGatewayV2HTTPResponse badRequest(String message) {
        return buildErrorResponse(400, message);
    }
    
    public static APIGatewayV2HTTPResponse notFound(String message) {
        return buildErrorResponse(404, message);
    }
    
    public static APIGatewayV2HTTPResponse internalServerError(String message) {
        return buildErrorResponse(500, message);
    }
    
    private static APIGatewayV2HTTPResponse buildResponse(int statusCode, Object body) {
        Map<String, String> headers = new HashMap<>();
        headers.put("Content-Type", "application/json");
        headers.put("Access-Control-Allow-Origin", "*");
        
        String jsonBody = null;
        if (body != null) {
            try {
                jsonBody = OBJECT_MAPPER.writeValueAsString(body);
            } catch (JsonProcessingException e) {
                return internalServerError("Failed to serialize response");
            }
        }
        
        return APIGatewayV2HTTPResponse.builder()
                .withStatusCode(statusCode)
                .withHeaders(headers)
                .withBody(jsonBody)
                .build();
    }
    
    private static APIGatewayV2HTTPResponse buildErrorResponse(int statusCode, String message) {
        Map<String, String> errorBody = new HashMap<>();
        errorBody.put("error", message);
        return buildResponse(statusCode, errorBody);
    }
    
    public static <T> T parseRequestBody(String body, Class<T> clazz) throws JsonProcessingException {
        return OBJECT_MAPPER.readValue(body, clazz);
    }
}
