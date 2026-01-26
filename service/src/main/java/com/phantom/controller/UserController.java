package com.phantom.controller;

import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.phantom.model.entity.UserProfile;
import com.phantom.service.UserService;
import com.phantom.util.ResponseBuilder;
import lombok.extern.slf4j.Slf4j;

import java.util.HashMap;
import java.util.Map;

@Slf4j
public class UserController {
    
    private static final ObjectMapper objectMapper = new ObjectMapper();
    
    private final UserService userService;
    
    public UserController(UserService userService) {
        this.userService = userService;
    }
    
    public APIGatewayV2HTTPResponse getUser(APIGatewayV2HTTPEvent event, String userId) {
        try {
            UserProfile profile = userService.getUserProfile(userId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("userId", profile.getUserId());
            response.put("createdAt", profile.getCreatedAt());
            response.put("timezone", profile.getTimezone());
            response.put("plan", profile.getPlan());
            response.put("settings", profile.getSettings());
            
            return ResponseBuilder.ok(response);
        } catch (Exception e) {
            log.error("Error retrieving user profile", e);
            return ResponseBuilder.internalServerError("Failed to retrieve user profile");
        }
    }
    
    public APIGatewayV2HTTPResponse updateUser(APIGatewayV2HTTPEvent event, String userId) {
        try {
            String body = event.getBody();
            JsonNode json = objectMapper.readTree(body);
            
            String timezone = json.has("timezone") ? json.get("timezone").asText() : null;
            Map<String, Object> settings = null;
            if (json.has("settings")) {
                settings = objectMapper.convertValue(json.get("settings"), Map.class);
            }
            
            UserProfile profile = userService.updateUserProfile(userId, timezone, settings);
            
            Map<String, Object> response = new HashMap<>();
            response.put("userId", profile.getUserId());
            response.put("createdAt", profile.getCreatedAt());
            response.put("timezone", profile.getTimezone());
            response.put("plan", profile.getPlan());
            response.put("settings", profile.getSettings());
            
            return ResponseBuilder.ok(response);
        } catch (Exception e) {
            log.error("Error updating user profile", e);
            return ResponseBuilder.internalServerError("Failed to update user profile");
        }
    }
    
    public APIGatewayV2HTTPResponse deleteUser(APIGatewayV2HTTPEvent event, String userId) {
        try {
            userService.deleteUserProfile(userId);
            
            Map<String, String> response = new HashMap<>();
            response.put("message", "User profile deleted successfully");
            
            return ResponseBuilder.ok(response);
        } catch (Exception e) {
            log.error("Error deleting user profile", e);
            return ResponseBuilder.internalServerError("Failed to delete user profile");
        }
    }
}
