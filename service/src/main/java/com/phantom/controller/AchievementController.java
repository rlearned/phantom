package com.phantom.controller;

import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;
import com.phantom.util.ResponseBuilder;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

@Slf4j
public class AchievementController {
    
    public APIGatewayV2HTTPResponse getAchievements(APIGatewayV2HTTPEvent event, String userId) {
        try {
            Map<String, Object> response = new HashMap<>();
            response.put("achievements", new ArrayList<>());
            
            return ResponseBuilder.ok(response);
        } catch (Exception e) {
            log.error("Error retrieving achievements", e);
            return ResponseBuilder.internalServerError("Failed to retrieve achievements");
        }
    }
}
