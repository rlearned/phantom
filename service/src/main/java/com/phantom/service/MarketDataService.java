package com.phantom.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.phantom.model.entity.CacheItem;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
public class MarketDataService {

    private static final String ALPACA_DATA_BASE_URL = "https://data.alpaca.markets";
    private static final String ALPACA_TRADING_BASE_URL = "https://api.alpaca.markets";
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

    MarketDataService(CacheRepository cacheRepository, HttpClient httpClient) {
        this.cacheRepository = cacheRepository;
        this.httpClient = httpClient;
    }

    public Map<String, Object> validateTicker(String symbol) throws IOException, InterruptedException {
        log.info("Validating ticker symbol: {}", symbol);

        String normalizedSymbol = symbol.trim().toUpperCase();

        if (!isAlpacaConfigured()) {
            log.warn("Alpaca API keys not configured, returning mock validation");
            Map<String, Object> mock = new HashMap<>();
            mock.put("valid", true);
            mock.put(Constants.QUOTE_KEY_SYMBOL, normalizedSymbol);
            mock.put("name", "Mock Asset");
            mock.put("exchange", "MOCK");
            mock.put("tradable", true);
            return mock;
        }

        String url = String.format("%s/v2/assets/%s", ALPACA_TRADING_BASE_URL, normalizedSymbol);

        HttpRequest request = buildAlpacaRequest(url);
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() == 404) {
            Map<String, Object> result = new HashMap<>();
            result.put("valid", false);
            result.put(Constants.QUOTE_KEY_SYMBOL, normalizedSymbol);
            return result;
        }

        if (response.statusCode() != 200) {
            log.error("Failed to validate ticker {}: HTTP {} - {}", normalizedSymbol, response.statusCode(), response.body());
            throw new RuntimeException("Failed to validate ticker: HTTP " + response.statusCode());
        }

        JsonNode jsonResponse = objectMapper.readTree(response.body());

        Map<String, Object> result = new HashMap<>();
        result.put("valid", true);
        result.put(Constants.QUOTE_KEY_SYMBOL, jsonResponse.has("symbol") ? jsonResponse.get("symbol").asText() : normalizedSymbol);
        result.put("name", jsonResponse.has("name") ? jsonResponse.get("name").asText() : "");
        result.put("exchange", jsonResponse.has("exchange") ? jsonResponse.get("exchange").asText() : "");
        result.put("tradable", jsonResponse.has("tradable") && jsonResponse.get("tradable").asBoolean());
        return result;
    }

    public Map<String, Object> getRealTimeQuote(String symbol) throws IOException, InterruptedException {
        log.info("Fetching real-time quote for symbol: {}", symbol);

        String normalizedSymbol = symbol.trim().toUpperCase();

        if (!isAlpacaConfigured()) {
            log.error("Alpaca API keys not configured, returning mock data");
            return createMockQuote(normalizedSymbol, 0.0);
        }

        // Check cache first
        CacheItem cached = cacheRepository.getLatestPrice(normalizedSymbol);
        if (cached != null && cached.getExpiresAt() != null && cached.getExpiresAt() > System.currentTimeMillis() / 1000) {
            log.info("Cache hit for {}", normalizedSymbol);
            return cached.getPayload();
        }

        String url = String.format("%s/v2/stocks/%s/snapshot", ALPACA_DATA_BASE_URL, normalizedSymbol);

        HttpRequest request = buildAlpacaRequest(url);
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() == 404 || response.statusCode() == 422) {
            throw new IllegalArgumentException("Invalid ticker symbol: " + normalizedSymbol);
        }

        if (response.statusCode() != 200) {
            log.error("Failed to fetch quote for {}: HTTP {} - {}", normalizedSymbol, response.statusCode(), response.body());
            throw new RuntimeException("Failed to fetch market data: HTTP " + response.statusCode());
        }

        JsonNode jsonResponse = objectMapper.readTree(response.body());

        JsonNode latestTrade = jsonResponse.get("latestTrade");
        if (latestTrade == null || !latestTrade.has("p")) {
            log.error("Missing latestTrade data in Alpaca snapshot for {}", normalizedSymbol);
            throw new RuntimeException("Invalid snapshot response from Alpaca for " + normalizedSymbol);
        }

        double price = latestTrade.get("p").asDouble();
        String providerTs = latestTrade.has("t") ? latestTrade.get("t").asText() : Instant.now().toString();

        Map<String, Object> quote = new HashMap<>();
        quote.put(Constants.QUOTE_KEY_SYMBOL, normalizedSymbol);
        quote.put(Constants.QUOTE_KEY_PRICE, price);
        quote.put(Constants.QUOTE_KEY_PROVIDER_TS, providerTs);
        quote.put(Constants.QUOTE_KEY_CAPTURED_AT, System.currentTimeMillis());
        quote.put(Constants.QUOTE_KEY_SOURCE, Constants.SOURCE_ALPACA);

        // Cache the result
        long nowEpochSeconds = System.currentTimeMillis() / 1000;
        CacheItem cacheItem = CacheItem.builder()
                .pk(Constants.PK_MARKET_DATA_PREFIX + normalizedSymbol)
                .sk(Constants.SK_PRICE_LATEST)
                .payload(quote)
                .fetchedAt(Instant.now().toString())
                .expiresAt(nowEpochSeconds + Constants.CACHE_TTL_PRICE_SECONDS)
                .source(Constants.SOURCE_ALPACA)
                .build();
        cacheRepository.saveCacheItem(cacheItem);

        return quote;
    }

    public Map<String, Object> getHistoricalQuote(String symbol, long epochMs) throws IOException, InterruptedException {
        log.info("Fetching historical quote for symbol: {} at {}", symbol, epochMs);

        String normalizedSymbol = symbol.trim().toUpperCase();

        if (!isAlpacaConfigured()) {
            log.error("Alpaca API keys not configured, returning mock data");
            return createMockQuote(normalizedSymbol, 0.0);
        }

        LocalDate requestedDate = Instant.ofEpochMilli(epochMs)
                .atZone(MARKET_TIMEZONE)
                .toLocalDate();

        LocalDate maxHistoricalDate = LocalDate.now().minusDays(365);
        if (requestedDate.isBefore(maxHistoricalDate)) {
            throw new IllegalArgumentException("Historical data limited to 365 days");
        }

        String startDate = requestedDate.format(DATE_FORMATTER) + "T00:00:00Z";
        String endDate = requestedDate.plusDays(1).format(DATE_FORMATTER) + "T00:00:00Z";

        String url = String.format("%s/v2/stocks/%s/bars?timeframe=1Day&start=%s&end=%s&limit=1",
                ALPACA_DATA_BASE_URL, normalizedSymbol, startDate, endDate);

        HttpRequest request = buildAlpacaRequest(url);
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() == 404 || response.statusCode() == 422) {
            throw new IllegalArgumentException("Invalid ticker symbol: " + normalizedSymbol);
        }

        if (response.statusCode() != 200) {
            log.error("Failed to fetch historical quote for {}: HTTP {} - {}", normalizedSymbol, response.statusCode(), response.body());
            throw new RuntimeException("Failed to fetch historical market data: HTTP " + response.statusCode());
        }

        JsonNode jsonResponse = objectMapper.readTree(response.body());
        JsonNode bars = jsonResponse.get("bars");

        if (bars == null || !bars.isArray() || bars.isEmpty()) {
            throw new RuntimeException("No market data available for " + requestedDate.format(DATE_FORMATTER)
                    + " — market may have been closed");
        }

        JsonNode bar = bars.get(0);
        double price = bar.get("c").asDouble();
        String providerTs = bar.has("t") ? bar.get("t").asText() : requestedDate.format(DATE_FORMATTER);

        Map<String, Object> quote = new HashMap<>();
        quote.put(Constants.QUOTE_KEY_SYMBOL, normalizedSymbol);
        quote.put(Constants.QUOTE_KEY_PRICE, price);
        quote.put(Constants.QUOTE_KEY_PROVIDER_TS, providerTs);
        quote.put(Constants.QUOTE_KEY_CAPTURED_AT, System.currentTimeMillis());
        quote.put(Constants.QUOTE_KEY_SOURCE, Constants.SOURCE_ALPACA);

        return quote;
    }

    public Map<String, Object> getMarketQuote(String symbol) {
        log.info("Retrieving market quote for symbol: {}", symbol);

        String normalizedSymbol = symbol.trim().toUpperCase();

        try {
            return getRealTimeQuote(normalizedSymbol);
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            log.error("Error fetching market quote for {}", normalizedSymbol, e);
            return createMockQuote(normalizedSymbol, 0.0);
        }
    }

    public Map<String, Object> getMarketCandles(String symbol, String interval, String range) throws IOException, InterruptedException {
        log.info("Fetching market candles for symbol: {}, interval: {}, range: {}", symbol, interval, range);

        String normalizedSymbol = symbol.trim().toUpperCase();
        String effectiveInterval = interval != null ? interval : "1day";
        String effectiveRange = range != null ? range : "1m";

        if (!isAlpacaConfigured()) {
            log.error("Alpaca API keys not configured, returning empty candles");
            return buildCandlesResponse(normalizedSymbol, effectiveInterval, new ArrayList<>());
        }

        // Check cache first
        CacheItem cached = cacheRepository.getTimeSeries(normalizedSymbol, effectiveInterval, effectiveRange);
        if (cached != null && cached.getExpiresAt() != null && cached.getExpiresAt() > System.currentTimeMillis() / 1000) {
            log.info("Cache hit for candles {}/{}/{}", normalizedSymbol, effectiveInterval, effectiveRange);
            return cached.getPayload();
        }

        String timeframe = mapIntervalToTimeframe(effectiveInterval);
        String startDate = mapRangeToStartDate(effectiveRange);
        String endDate = Instant.now().toString();

        String url = String.format("%s/v2/stocks/%s/bars?timeframe=%s&start=%s&end=%s&limit=1000",
                ALPACA_DATA_BASE_URL, normalizedSymbol, timeframe, startDate, endDate);

        HttpRequest request = buildAlpacaRequest(url);
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() == 404 || response.statusCode() == 422) {
            throw new IllegalArgumentException("Invalid ticker symbol: " + normalizedSymbol);
        }

        if (response.statusCode() != 200) {
            log.error("Failed to fetch candles for {}: HTTP {} - {}", normalizedSymbol, response.statusCode(), response.body());
            throw new RuntimeException("Failed to fetch market candles: HTTP " + response.statusCode());
        }

        JsonNode jsonResponse = objectMapper.readTree(response.body());
        JsonNode bars = jsonResponse.get("bars");

        List<Map<String, Object>> candles = new ArrayList<>();
        if (bars != null && bars.isArray()) {
            for (JsonNode bar : bars) {
                Map<String, Object> candle = new HashMap<>();
                candle.put(Constants.CANDLE_KEY_DATETIME, bar.get("t").asText());
                candle.put(Constants.CANDLE_KEY_OPEN, bar.get("o").asDouble());
                candle.put(Constants.CANDLE_KEY_HIGH, bar.get("h").asDouble());
                candle.put(Constants.CANDLE_KEY_LOW, bar.get("l").asDouble());
                candle.put(Constants.CANDLE_KEY_CLOSE, bar.get("c").asDouble());
                candle.put(Constants.CANDLE_KEY_VOLUME, bar.get("v").asLong());
                candles.add(candle);
            }
        }

        Map<String, Object> result = buildCandlesResponse(normalizedSymbol, effectiveInterval, candles);

        // Cache the result
        long nowEpochSeconds = System.currentTimeMillis() / 1000;
        CacheItem cacheItem = CacheItem.builder()
                .pk(Constants.PK_MARKET_DATA_PREFIX + normalizedSymbol)
                .sk(Constants.SK_TIMESERIES_PREFIX + effectiveInterval + "#" + effectiveRange)
                .payload(result)
                .fetchedAt(Instant.now().toString())
                .expiresAt(nowEpochSeconds + Constants.CACHE_TTL_TIMESERIES_SECONDS)
                .source(Constants.SOURCE_ALPACA)
                .build();
        cacheRepository.saveCacheItem(cacheItem);

        return result;
    }

    private Map<String, Object> buildCandlesResponse(String symbol, String interval, List<Map<String, Object>> candles) {
        Map<String, Object> response = new HashMap<>();
        response.put(Constants.QUOTE_KEY_SYMBOL, symbol);
        response.put(Constants.CANDLE_KEY_INTERVAL, interval);
        response.put(Constants.CANDLE_KEY_CANDLES, candles);
        response.put(Constants.QUOTE_KEY_FETCHED_AT, Instant.now().toString());
        return response;
    }

    private String mapIntervalToTimeframe(String interval) {
        switch (interval.toLowerCase()) {
            case "5min": return "5Min";
            case "15min": return "15Min";
            case "1hour": return "1Hour";
            case "1day": return "1Day";
            case "1week": return "1Week";
            default: return "1Day";
        }
    }

    private String mapRangeToStartDate(String range) {
        LocalDate now = LocalDate.now();
        LocalDate start;
        switch (range.toLowerCase()) {
            case "1m": start = now.minusMonths(1); break;
            case "3m": start = now.minusMonths(3); break;
            case "6m": start = now.minusMonths(6); break;
            case "1y": start = now.minusYears(1); break;
            case "ytd": start = LocalDate.of(now.getYear(), 1, 1); break;
            default: start = now.minusMonths(1); break;
        }
        return start.format(DATE_FORMATTER) + "T00:00:00Z";
    }

    private HttpRequest buildAlpacaRequest(String url) {
        return HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("APCA-API-KEY-ID", Constants.ALPACA_API_KEY_ID)
                .header("APCA-API-SECRET-KEY", Constants.ALPACA_API_SECRET_KEY)
                .GET()
                .build();
    }

    private boolean isAlpacaConfigured() {
        return Constants.ALPACA_API_KEY_ID != null && !Constants.ALPACA_API_KEY_ID.isEmpty()
                && Constants.ALPACA_API_SECRET_KEY != null && !Constants.ALPACA_API_SECRET_KEY.isEmpty();
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
