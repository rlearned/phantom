package com.phantom.controller;

import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;
import com.phantom.util.ResponseBuilder;
import lombok.extern.slf4j.Slf4j;

import java.util.HashMap;
import java.util.Map;

@Slf4j
public class StreakController {
    
    public APIGatewayV2HTTPResponse getStreaks(APIGatewayV2HTTPEvent event, String userId) {
        try {
            Map<String, Object> response = new HashMap<>();
            response.put("currentStreak", 0);
            response.put("longestStreak", 0);
            
            return ResponseBuilder.ok(response);
        } catch (Exception e) {
            log.error("Error retrieving streaks", e);
            return ResponseBuilder.internalServerError("Failed to retrieve streaks");
        }
    }
}
