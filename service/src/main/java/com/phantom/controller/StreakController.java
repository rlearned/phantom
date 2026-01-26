package com.phantom.controller;

import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;
import com.phantom.util.ResponseBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

public class StreakController {
    
    private static final Logger logger = LoggerFactory.getLogger(StreakController.class);
    
    public APIGatewayV2HTTPResponse getStreaks(APIGatewayV2HTTPEvent event, String userId) {
        try {
            Map<String, Object> response = new HashMap<>();
            response.put("currentStreak", 0);
            response.put("longestStreak", 0);
            
            return ResponseBuilder.ok(response);
        } catch (Exception e) {
            logger.error("Error retrieving streaks", e);
            return ResponseBuilder.internalServerError("Failed to retrieve streaks");
        }
    }
}
