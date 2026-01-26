package com.phantom.controller;

import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;
import com.phantom.model.entity.DashboardSummary;
import com.phantom.service.DashboardService;
import com.phantom.util.ResponseBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

public class DashboardController {
    
    private static final Logger logger = LoggerFactory.getLogger(DashboardController.class);
    
    private final DashboardService dashboardService;
    
    public DashboardController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }
    
    public APIGatewayV2HTTPResponse getDashboardSummary(APIGatewayV2HTTPEvent event, String userId) {
        try {
            DashboardSummary summary = dashboardService.getDashboardSummary(userId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("ghostCountTotal", summary.getGhostCountTotal());
            response.put("ghostCount30d", summary.getGhostCount30d());
            response.put("lastGhostAtEpochMs", summary.getLastGhostAtEpochMs());
            response.put("streakDays", summary.getStreakDays());
            response.put("topHesitationTags30d", summary.getTopHesitationTags30d());
            
            return ResponseBuilder.ok(response);
        } catch (Exception e) {
            logger.error("Error retrieving dashboard summary", e);
            return ResponseBuilder.internalServerError("Failed to retrieve dashboard summary");
        }
    }
}
