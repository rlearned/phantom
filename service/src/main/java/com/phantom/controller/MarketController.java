package com.phantom.controller;

import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;
import com.phantom.service.MarketDataService;
import com.phantom.util.ResponseBuilder;
import lombok.extern.slf4j.Slf4j;

import java.util.Map;

@Slf4j
public class MarketController {
    
    private final MarketDataService marketDataService;
    
    public MarketController(MarketDataService marketDataService) {
        this.marketDataService = marketDataService;
    }
    
    public APIGatewayV2HTTPResponse getMarketQuote(APIGatewayV2HTTPEvent event) {
        try {
            Map<String, String> queryParams = event.getQueryStringParameters();
            if (queryParams == null || !queryParams.containsKey("symbol")) {
                return ResponseBuilder.badRequest("Missing required parameter: symbol");
            }
            
            String symbol = queryParams.get("symbol");
            Map<String, Object> quote = marketDataService.getMarketQuote(symbol);
            
            return ResponseBuilder.ok(quote);
        } catch (Exception e) {
            log.error("Error retrieving market quote", e);
            return ResponseBuilder.internalServerError("Failed to retrieve market quote");
        }
    }
    
    public APIGatewayV2HTTPResponse getMarketCandles(APIGatewayV2HTTPEvent event) {
        try {
            Map<String, String> queryParams = event.getQueryStringParameters();
            if (queryParams == null || !queryParams.containsKey("symbol")) {
                return ResponseBuilder.badRequest("Missing required parameter: symbol");
            }
            
            String symbol = queryParams.get("symbol");
            String interval = queryParams.get("interval");
            String range = queryParams.get("range");
            
            Map<String, Object> candles = marketDataService.getMarketCandles(symbol, interval, range);
            
            return ResponseBuilder.ok(candles);
        } catch (Exception e) {
            log.error("Error retrieving market candles", e);
            return ResponseBuilder.internalServerError("Failed to retrieve market candles");
        }
    }
}
