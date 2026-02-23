package com.phantom.handler;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;
import com.phantom.controller.*;
import com.phantom.repository.AppRepository;
import com.phantom.repository.CacheRepository;
import com.phantom.service.DashboardService;
import com.phantom.service.GhostService;
import com.phantom.service.MarketDataService;
import com.phantom.service.UserService;
import com.phantom.util.ResponseBuilder;
import lombok.extern.slf4j.Slf4j;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@Slf4j
public class ApiHandler implements RequestHandler<APIGatewayV2HTTPEvent, APIGatewayV2HTTPResponse> {
    
    private final UserController userController;
    private final GhostController ghostController;
    private final DashboardController dashboardController;
    private final MarketController marketController;
    private final AchievementController achievementController;
    private final StreakController streakController;
    
    public ApiHandler() {
        DynamoDbClient dynamoDbClient = DynamoDbClient.create();
        
        AppRepository appRepository = new AppRepository(dynamoDbClient);
        CacheRepository cacheRepository = new CacheRepository(dynamoDbClient);
        
        UserService userService = new UserService(appRepository);
        MarketDataService marketDataService = new MarketDataService(cacheRepository);
        GhostService ghostService = new GhostService(appRepository, marketDataService);
        DashboardService dashboardService = new DashboardService(appRepository);
        
        this.userController = new UserController(userService);
        this.ghostController = new GhostController(ghostService);
        this.dashboardController = new DashboardController(dashboardService);
        this.marketController = new MarketController(marketDataService);
        this.achievementController = new AchievementController();
        this.streakController = new StreakController();
    }
    
    @Override
    public APIGatewayV2HTTPResponse handleRequest(APIGatewayV2HTTPEvent event, Context context) {
        log.info("Received request: {} {}", event.getRequestContext().getHttp().getMethod(), 
                event.getRawPath());
        
        try {
            String userId = extractUserId(event);
            String path = event.getRawPath();
            String method = event.getRequestContext().getHttp().getMethod();
            
            if (path.equals("/v1/health") && method.equals("GET")) {
                return handleHealth();
            }
            
            if (userId == null) {
                return ResponseBuilder.badRequest("Missing user ID in request context");
            }
            
            if (path.equals("/v1/me")) {
                return handleUserRoutes(event, method, userId);
            }
            
            if (path.startsWith("/v1/ghosts")) {
                return handleGhostRoutes(event, method, path, userId);
            }
            
            if (path.equals("/v1/dashboard/summary") && method.equals("GET")) {
                return dashboardController.getDashboardSummary(event, userId);
            }
            
            if (path.equals("/v1/achievements") && method.equals("GET")) {
                return achievementController.getAchievements(event, userId);
            }
            
            if (path.equals("/v1/streaks") && method.equals("GET")) {
                return streakController.getStreaks(event, userId);
            }
            
            if (path.equals("/v1/market/validate") && method.equals("GET")) {
                return marketController.validateTicker(event);
            }

            if (path.equals("/v1/market/quote") && method.equals("GET")) {
                return marketController.getMarketQuote(event);
            }
            
            if (path.equals("/v1/market/candles") && method.equals("GET")) {
                return marketController.getMarketCandles(event);
            }
            
            return ResponseBuilder.notFound("Route not found");
            
        } catch (Exception e) {
            log.error("Error handling request", e);
            return ResponseBuilder.internalServerError("Internal server error");
        }
    }
    
    private APIGatewayV2HTTPResponse handleHealth() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "healthy");
        response.put("timestamp", Instant.now().toString());
        return ResponseBuilder.ok(response);
    }
    
    private APIGatewayV2HTTPResponse handleUserRoutes(APIGatewayV2HTTPEvent event, String method, String userId) {
        switch (method) {
            case "GET":
                return userController.getUser(event, userId);
            case "PATCH":
                return userController.updateUser(event, userId);
            case "DELETE":
                return userController.deleteUser(event, userId);
            default:
                return ResponseBuilder.badRequest("Method not allowed");
        }
    }
    
    private APIGatewayV2HTTPResponse handleGhostRoutes(APIGatewayV2HTTPEvent event, String method, String path, String userId) {
        if (path.equals("/v1/ghosts")) {
            switch (method) {
                case "GET":
                    return ghostController.listGhosts(event, userId);
                case "POST":
                    return ghostController.createGhost(event, userId);
                default:
                    return ResponseBuilder.badRequest("Method not allowed");
            }
        }
        
        if (path.startsWith("/v1/ghosts/")) {
            switch (method) {
                case "GET":
                    return ghostController.getGhost(event, userId);
                case "PATCH":
                    return ghostController.updateGhost(event, userId);
                default:
                    return ResponseBuilder.badRequest("Method not allowed");
            }
        }
        
        return ResponseBuilder.notFound("Route not found");
    }
    
    private String extractUserId(APIGatewayV2HTTPEvent event) {
        if (event.getRequestContext() != null && 
            event.getRequestContext().getAuthorizer() != null &&
            event.getRequestContext().getAuthorizer().getJwt() != null &&
            event.getRequestContext().getAuthorizer().getJwt().getClaims() != null) {
            return event.getRequestContext().getAuthorizer().getJwt().getClaims().get("sub");
        }
        return null;
    }
}
