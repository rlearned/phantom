package com.phantom.controller;

import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.phantom.model.entity.Ghost;
import com.phantom.service.GhostService;
import com.phantom.util.ResponseBuilder;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
public class GhostController {
    
    private static final ObjectMapper objectMapper = new ObjectMapper();
    
    private final GhostService ghostService;
    
    public GhostController(GhostService ghostService) {
        this.ghostService = ghostService;
    }
    
    public APIGatewayV2HTTPResponse listGhosts(APIGatewayV2HTTPEvent event, String userId) {
        try {
            Integer limit = 50;
            if (event.getQueryStringParameters() != null && event.getQueryStringParameters().containsKey("limit")) {
                limit = Integer.parseInt(event.getQueryStringParameters().get("limit"));
            }
            
            List<Ghost> ghosts = ghostService.listGhosts(userId, limit);
            
            List<Map<String, Object>> ghostResponses = new ArrayList<>();
            for (Ghost ghost : ghosts) {
                ghostResponses.add(mapGhostToResponse(ghost));
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("ghosts", ghostResponses);
            
            return ResponseBuilder.ok(response);
        } catch (Exception e) {
            log.error("Error listing ghosts", e);
            return ResponseBuilder.internalServerError("Failed to list ghosts");
        }
    }
    
    public APIGatewayV2HTTPResponse createGhost(APIGatewayV2HTTPEvent event, String userId) {
        try {
            String body = event.getBody();
            JsonNode json = objectMapper.readTree(body);
            
            String ticker = json.get("ticker").asText();
            String direction = json.get("direction").asText();
            Double intendedPrice = json.get("intendedPrice").asDouble();
            Double intendedSize = json.get("intendedSize").asDouble();
            
            List<String> hesitationTags = null;
            if (json.has("hesitationTags")) {
                hesitationTags = objectMapper.convertValue(json.get("hesitationTags"), List.class);
            }
            
            String noteText = json.has("noteText") ? json.get("noteText").asText() : null;
            String voiceKey = json.has("voiceKey") ? json.get("voiceKey").asText() : null;
            
            Ghost ghost = ghostService.createGhost(userId, ticker, direction, intendedPrice, 
                    intendedSize, hesitationTags, noteText, voiceKey);
            
            return ResponseBuilder.created(mapGhostToResponse(ghost));
        } catch (Exception e) {
            log.error("Error creating ghost", e);
            return ResponseBuilder.internalServerError("Failed to create ghost");
        }
    }
    
    public APIGatewayV2HTTPResponse getGhost(APIGatewayV2HTTPEvent event, String userId) {
        try {
            String ghostId = event.getPathParameters().get("ghostId");
            
            List<Ghost> ghosts = ghostService.listGhosts(userId, 100);
            Ghost ghost = null;
            for (Ghost g : ghosts) {
                if (g.getGhostId().equals(ghostId)) {
                    ghost = g;
                    break;
                }
            }
            
            if (ghost == null) {
                return ResponseBuilder.notFound("Ghost not found");
            }
            
            return ResponseBuilder.ok(mapGhostToResponse(ghost));
        } catch (Exception e) {
            log.error("Error retrieving ghost", e);
            return ResponseBuilder.internalServerError("Failed to retrieve ghost");
        }
    }
    
    public APIGatewayV2HTTPResponse updateGhost(APIGatewayV2HTTPEvent event, String userId) {
        try {
            String ghostId = event.getPathParameters().get("ghostId");
            String body = event.getBody();
            JsonNode json = objectMapper.readTree(body);
            
            List<Ghost> ghosts = ghostService.listGhosts(userId, 100);
            String sk = null;
            for (Ghost g : ghosts) {
                if (g.getGhostId().equals(ghostId)) {
                    sk = g.getSk();
                    break;
                }
            }
            
            if (sk == null) {
                return ResponseBuilder.notFound("Ghost not found");
            }
            
            String status = json.has("status") ? json.get("status").asText() : null;
            String noteText = json.has("noteText") ? json.get("noteText").asText() : null;
            
            Ghost ghost = ghostService.updateGhost(userId, sk, status, noteText);
            
            return ResponseBuilder.ok(mapGhostToResponse(ghost));
        } catch (Exception e) {
            log.error("Error updating ghost", e);
            return ResponseBuilder.internalServerError("Failed to update ghost");
        }
    }
    
    private Map<String, Object> mapGhostToResponse(Ghost ghost) {
        Map<String, Object> response = new HashMap<>();
        response.put("ghostId", ghost.getGhostId());
        response.put("userId", ghost.getUserId());
        response.put("createdAtEpochMs", ghost.getCreatedAtEpochMs());
        response.put("ticker", ghost.getTicker());
        response.put("direction", ghost.getDirection());
        response.put("intendedPrice", ghost.getIntendedPrice());
        response.put("intendedSize", ghost.getIntendedSize());
        response.put("hesitationTags", ghost.getHesitationTags());
        response.put("noteText", ghost.getNoteText());
        response.put("voiceKey", ghost.getVoiceKey());
        response.put("status", ghost.getStatus());
        response.put("loggedQuote", ghost.getLoggedQuote());
        return response;
    }
}
