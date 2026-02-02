package com.phantom.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.phantom.repository.CacheRepository;
import com.phantom.util.Constants;
import lombok.extern.slf4j.Slf4j;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@Slf4j
public class MarketDataService {
    
    private static final String TWELVE_DATA_BASE_URL = "https://api.twelvedata.com";
    private static final String MOCK_SOURCE = "MOCK";
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final ZoneId MARKET_TIMEZONE = ZoneId.of("America/New_York");
    private static final ObjectMapper objectMapper = new ObjectMapper();

    private final CacheRepository cacheRepository;
    private final HttpClient httpClient;
    
    public MarketDataService(CacheRepository cacheRepository) {
        this.cacheRepository = cacheRepository;
        this.httpClient = HttpClient.newHttpClient();
    }
    
    public Map<String, Object> getRealTimeQuote(String symbol) throws IOException, InterruptedException {
        log.info("Fetching real-time quote for symbol: {}", symbol);
        
        String normalizedSymbol = symbol.trim().toUpperCase();
        String apiKey = Constants.TWELVE_DATA_API_KEY;
        
        if (apiKey == null || apiKey.isEmpty()) {
            log.warn("TWELVE_DATA_API_KEY not configured, returning mock data");
            return createMockQuote(normalizedSymbol, 0.0);
        }
        
        String url = String.format("%s/price?symbol=%s&apikey=%s", 
                TWELVE_DATA_BASE_URL, normalizedSymbol, apiKey);
        
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .GET()
                .build();
        
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        
        if (response.statusCode() != 200) {
            log.error("Failed to fetch quote for {}: HTTP {}", normalizedSymbol, response.statusCode());
            throw new RuntimeException("Failed to fetch market data: HTTP " + response.statusCode());
        }
        
        JsonNode jsonResponse = objectMapper.readTree(response.body());
        
        if (jsonResponse.has("code") && jsonResponse.get("code").asInt() != 200) {
            String message = jsonResponse.has("message") ? jsonResponse.get("message").asText() : "Unknown error";
            log.error("Twelve Data API error for {}: {}", normalizedSymbol, message);
            throw new RuntimeException("Market data error: " + message);
        }
        
        double price = jsonResponse.get(Constants.QUOTE_KEY_PRICE).asDouble();
        
        Map<String, Object> quote = new HashMap<>();
        quote.put(Constants.QUOTE_KEY_SYMBOL, normalizedSymbol);
        quote.put(Constants.QUOTE_KEY_PRICE, price);
        quote.put(Constants.QUOTE_KEY_PROVIDER_TS, Instant.now().toString());
        quote.put(Constants.QUOTE_KEY_CAPTURED_AT, System.currentTimeMillis());
        quote.put(Constants.QUOTE_KEY_SOURCE, Constants.SOURCE_TWELVE_DATA);
        
        return quote;
    }
    
    public Map<String, Object> getHistoricalQuote(String symbol, long epochMs) throws IOException, InterruptedException {
        log.info("Fetching historical quote for symbol: {} at {}", symbol, epochMs);
        
        String normalizedSymbol = symbol.trim().toUpperCase();
        String apiKey = Constants.TWELVE_DATA_API_KEY;
        
        if (apiKey == null || apiKey.isEmpty()) {
            log.warn("TWELVE_DATA_API_KEY not configured, returning mock data");
            return createMockQuote(normalizedSymbol, 0.0);
        }
        
        LocalDate requestedDate = Instant.ofEpochMilli(epochMs)
                .atZone(MARKET_TIMEZONE)
                .toLocalDate();
        
        LocalDate maxHistoricalDate = LocalDate.now().minusDays(365);
        if (requestedDate.isBefore(maxHistoricalDate)) {
            throw new IllegalArgumentException("Historical data limited to 365 days");
        }
        
        String dateStr = requestedDate.format(DATE_FORMATTER);
        String url = String.format("%s/eod?symbol=%s&date=%s&apikey=%s", 
                TWELVE_DATA_BASE_URL, normalizedSymbol, dateStr, apiKey);
        
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .GET()
                .build();
        
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        
        if (response.statusCode() != 200) {
            log.error("Failed to fetch historical quote for {}: HTTP {}", normalizedSymbol, response.statusCode());
            throw new RuntimeException("Failed to fetch historical market data: HTTP " + response.statusCode());
        }
        
        JsonNode jsonResponse = objectMapper.readTree(response.body());
        
        if (jsonResponse.has("code") && jsonResponse.get("code").asInt() != 200) {
            String message = jsonResponse.has("message") ? jsonResponse.get("message").asText() : "Unknown error";
            log.error("Twelve Data API error for {}: {}", normalizedSymbol, message);
            throw new RuntimeException("Market data error: " + message);
        }
        
        double price = jsonResponse.get("close").asDouble();
        String datetime = jsonResponse.get("datetime").asText();
        
        Map<String, Object> quote = new HashMap<>();
        quote.put(Constants.QUOTE_KEY_SYMBOL, normalizedSymbol);
        quote.put(Constants.QUOTE_KEY_PRICE, price);
        quote.put(Constants.QUOTE_KEY_PROVIDER_TS, datetime);
        quote.put(Constants.QUOTE_KEY_CAPTURED_AT, System.currentTimeMillis());
        quote.put(Constants.QUOTE_KEY_SOURCE, Constants.SOURCE_TWELVE_DATA);
        
        return quote;
    }
    
    public Map<String, Object> getMarketQuote(String symbol) {
        log.info("Retrieving market quote for symbol: {}", symbol);
        
        String normalizedSymbol = symbol.trim().toUpperCase();
        
        try {
            return getRealTimeQuote(normalizedSymbol);
        } catch (Exception e) {
            log.error("Error fetching market quote for {}", normalizedSymbol, e);
            return createMockQuote(normalizedSymbol, 0.0);
        }
    }
    
    public Map<String, Object> getMarketCandlesStub(String symbol, String interval, String range) {
        log.warn("getMarketCandlesStub called");
        
        String normalizedSymbol = symbol.trim().toUpperCase();
        String effectiveInterval = interval != null ? interval : "1day";
        
        Map<String, Object> response = new HashMap<>();
        response.put(Constants.QUOTE_KEY_SYMBOL, normalizedSymbol);
        response.put("interval", effectiveInterval);
        response.put("candles", new java.util.ArrayList<>());
        response.put("fetchedAt", Instant.now().toString());
        
        return response;
    }
    
    private Map<String, Object> createMockQuote(String symbol, double price) {
        Map<String, Object> quote = new HashMap<>();
        quote.put(Constants.QUOTE_KEY_SYMBOL, symbol);
        quote.put(Constants.QUOTE_KEY_PRICE, price);
        quote.put(Constants.QUOTE_KEY_PROVIDER_TS, Instant.now().toString());
        quote.put(Constants.QUOTE_KEY_CAPTURED_AT, System.currentTimeMillis());
        quote.put(Constants.QUOTE_KEY_SOURCE, MOCK_SOURCE);
        return quote;
    }
}
