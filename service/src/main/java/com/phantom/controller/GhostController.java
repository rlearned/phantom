package com.phantom.controller;

import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.phantom.model.entity.Ghost;
import com.phantom.service.GhostService;
import com.phantom.util.Constants;
import com.phantom.util.ResponseBuilder;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
public class GhostController {
    
    private static final ObjectMapper objectMapper = new ObjectMapper();
    private static final int DEFAULT_LIMIT = 50;
    private static final int MAX_SEARCH_LIMIT = 100;
    
    private final GhostService ghostService;
    
    public GhostController(GhostService ghostService) {
        this.ghostService = ghostService;
    }
    
    public APIGatewayV2HTTPResponse listGhosts(APIGatewayV2HTTPEvent event, String userId) {
        try {
            Integer limit = DEFAULT_LIMIT;
            if (event.getQueryStringParameters() != null && 
                    event.getQueryStringParameters().containsKey(Constants.REQUEST_KEY_LIMIT)) {
                limit = Integer.parseInt(event.getQueryStringParameters().get(Constants.REQUEST_KEY_LIMIT));
            }
            
            List<Ghost> ghosts = ghostService.listGhosts(userId, limit);
            
            List<Map<String, Object>> ghostResponses = new ArrayList<>();
            for (Ghost ghost : ghosts) {
                ghostResponses.add(mapGhostToResponse(ghost));
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put(Constants.RESPONSE_KEY_GHOSTS, ghostResponses);
            
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
            
            String ticker = json.get(Constants.REQUEST_KEY_TICKER).asText();
            String direction = json.get(Constants.REQUEST_KEY_DIRECTION).asText();
            String priceSource = json.get(Constants.REQUEST_KEY_PRICE_SOURCE).asText();
            String quantityType = json.get(Constants.REQUEST_KEY_QUANTITY_TYPE).asText();
            Double intendedSize = json.get(Constants.REQUEST_KEY_INTENDED_SIZE).asDouble();
            
            Double intendedPrice = json.has(Constants.REQUEST_KEY_INTENDED_PRICE) ? 
                    json.get(Constants.REQUEST_KEY_INTENDED_PRICE).asDouble() : null;
            Long consideredAtEpochMs = json.has(Constants.REQUEST_KEY_CONSIDERED_AT) ? 
                    json.get(Constants.REQUEST_KEY_CONSIDERED_AT).asLong() : null;
            
            List<String> hesitationTags = null;
            if (json.has(Constants.REQUEST_KEY_HESITATION_TAGS)) {
                hesitationTags = objectMapper.convertValue(
                        json.get(Constants.REQUEST_KEY_HESITATION_TAGS), List.class);
            }
            
            String noteText = json.has(Constants.REQUEST_KEY_NOTE_TEXT) ? 
                    json.get(Constants.REQUEST_KEY_NOTE_TEXT).asText() : null;
            String voiceKey = json.has(Constants.REQUEST_KEY_VOICE_KEY) ? 
                    json.get(Constants.REQUEST_KEY_VOICE_KEY).asText() : null;
            
            Ghost ghost = ghostService.createGhost(userId, ticker, direction, priceSource, 
                    intendedPrice, consideredAtEpochMs, quantityType, intendedSize, 
                    hesitationTags, noteText, voiceKey);
            
            return ResponseBuilder.created(mapGhostToResponse(ghost));
        } catch (IllegalArgumentException e) {
            log.error("Invalid request for creating ghost", e);
            return ResponseBuilder.badRequest(e.getMessage());
        } catch (Exception e) {
            log.error("Error creating ghost", e);
            return ResponseBuilder.internalServerError("Failed to create ghost");
        }
    }
    
    public APIGatewayV2HTTPResponse getGhost(APIGatewayV2HTTPEvent event, String userId) {
        try {
            String ghostId = event.getPathParameters().get(Constants.RESPONSE_KEY_GHOST_ID);
            
            List<Ghost> ghosts = ghostService.listGhosts(userId, MAX_SEARCH_LIMIT);
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
            String ghostId = event.getPathParameters().get(Constants.RESPONSE_KEY_GHOST_ID);
            String body = event.getBody();
            JsonNode json = objectMapper.readTree(body);
            
            List<Ghost> ghosts = ghostService.listGhosts(userId, MAX_SEARCH_LIMIT);
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
            
            String status = json.has(Constants.REQUEST_KEY_STATUS) ? 
                    json.get(Constants.REQUEST_KEY_STATUS).asText() : null;
            String noteText = json.has(Constants.REQUEST_KEY_NOTE_TEXT) ? 
                    json.get(Constants.REQUEST_KEY_NOTE_TEXT).asText() : null;
            
            Ghost ghost = ghostService.updateGhost(userId, sk, status, noteText);
            
            return ResponseBuilder.ok(mapGhostToResponse(ghost));
        } catch (Exception e) {
            log.error("Error updating ghost", e);
            return ResponseBuilder.internalServerError("Failed to update ghost");
        }
    }
    
    private Map<String, Object> mapGhostToResponse(Ghost ghost) {
        Map<String, Object> response = new HashMap<>();
        response.put(Constants.RESPONSE_KEY_GHOST_ID, ghost.getGhostId());
        response.put(Constants.RESPONSE_KEY_USER_ID, ghost.getUserId());
        response.put(Constants.RESPONSE_KEY_CREATED_AT, ghost.getCreatedAtEpochMs());
        response.put(Constants.REQUEST_KEY_TICKER, ghost.getTicker());
        response.put(Constants.REQUEST_KEY_DIRECTION, ghost.getDirection());
        response.put(Constants.REQUEST_KEY_INTENDED_PRICE, ghost.getIntendedPrice());
        response.put(Constants.REQUEST_KEY_INTENDED_SIZE, ghost.getIntendedShares());
        response.put(Constants.REQUEST_KEY_HESITATION_TAGS, ghost.getHesitationTags());
        response.put(Constants.REQUEST_KEY_NOTE_TEXT, ghost.getNoteText());
        response.put(Constants.REQUEST_KEY_VOICE_KEY, ghost.getVoiceKey());
        response.put(Constants.REQUEST_KEY_STATUS, ghost.getStatus());
        response.put(Constants.RESPONSE_KEY_LOGGED_QUOTE, ghost.getLoggedQuote());
        return response;
    }
}
