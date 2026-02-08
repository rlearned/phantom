package com.phantom.util;

public final class Constants {
    
    private Constants() {
    }
    
    public static final String APP_TABLE_NAME = System.getenv().getOrDefault("APP_TABLE_NAME", "phantom-app");
    public static final String CACHE_TABLE_NAME = System.getenv().getOrDefault("CACHE_TABLE_NAME", "phantom-cache");
    public static final String TWELVE_DATA_API_KEY = System.getenv().getOrDefault("TWELVE_DATA_API_KEY", "");
    
    public static final String PK_USER_PREFIX = "USER#";
    public static final String SK_PROFILE = "PROFILE";
    public static final String SK_GHOST_PREFIX = "GHOST#";
    public static final String SK_DASHBOARD_SUMMARY = "DASH#SUMMARY";
    
    public static final String PK_MARKET_DATA_PREFIX = "MD#";
    public static final String SK_PRICE_LATEST = "PRICE#latest";
    public static final String SK_TIMESERIES_PREFIX = "TS#";
    
    public static final String PK_SEARCH = "SEARCH";
    public static final String SK_SEARCH_QUERY_PREFIX = "Q#";
    
    public static final String ENTITY_TYPE_USER_PROFILE = "USER_PROFILE";
    public static final String ENTITY_TYPE_GHOST = "GHOST";
    public static final String ENTITY_TYPE_DASH_SUMMARY = "DASH_SUMMARY";
    
    public static final String DIRECTION_BUY = "BUY";
    public static final String DIRECTION_SELL = "SELL";
    
    public static final String PRICE_SOURCE_MARKET_CURRENT = "MARKET_CURRENT";
    public static final String PRICE_SOURCE_MARKET_HISTORICAL = "MARKET_HISTORICAL";
    public static final String PRICE_SOURCE_MANUAL = "MANUAL";
    
    public static final String QUANTITY_TYPE_SHARES = "SHARES";
    public static final String QUANTITY_TYPE_DOLLARS = "DOLLARS";
    
    public static final String STATUS_OPEN = "OPEN";
    public static final String STATUS_CLOSED = "CLOSED";
    
    public static final String PLAN_FREE = "FREE";
    
    public static final String SOURCE_TWELVE_DATA = "twelve_data";
    public static final String SOURCE_MANUAL = "MANUAL";
    
    public static final String QUOTE_KEY_SYMBOL = "symbol";
    public static final String QUOTE_KEY_PRICE = "price";
    public static final String QUOTE_KEY_PROVIDER_TS = "providerTs";
    public static final String QUOTE_KEY_CAPTURED_AT = "capturedAtEpochMs";
    public static final String QUOTE_KEY_SOURCE = "source";
    
    public static final String REQUEST_KEY_TICKER = "ticker";
    public static final String REQUEST_KEY_DIRECTION = "direction";
    public static final String REQUEST_KEY_PRICE_SOURCE = "priceSource";
    public static final String REQUEST_KEY_INTENDED_PRICE = "intendedPrice";
    public static final String REQUEST_KEY_CONSIDERED_AT = "consideredAtEpochMs";
    public static final String REQUEST_KEY_QUANTITY_TYPE = "quantityType";
    public static final String REQUEST_KEY_INTENDED_SHARES = "intendedShares";
    public static final String REQUEST_KEY_INTENDED_DOLLARS = "intendedDollars";
    public static final String REQUEST_KEY_HESITATION_TAGS = "hesitationTags";
    public static final String REQUEST_KEY_NOTE_TEXT = "noteText";
    public static final String REQUEST_KEY_VOICE_KEY = "voiceKey";
    public static final String REQUEST_KEY_STATUS = "status";
    public static final String REQUEST_KEY_LIMIT = "limit";
    
    public static final String RESPONSE_KEY_GHOST_ID = "ghostId";
    public static final String RESPONSE_KEY_USER_ID = "userId";
    public static final String RESPONSE_KEY_CREATED_AT = "createdAtEpochMs";
    public static final String RESPONSE_KEY_PRICE_SOURCE = "priceSource";
    public static final String RESPONSE_KEY_QUANTITY_TYPE = "quantityType";
    public static final String RESPONSE_KEY_INTENDED_SHARES = "intendedShares";
    public static final String RESPONSE_KEY_INTENDED_DOLLARS = "intendedDollars";
    public static final String RESPONSE_KEY_CONSIDERED_AT = "consideredAtEpochMs";
    public static final String RESPONSE_KEY_LOGGED_QUOTE = "loggedQuote";
    public static final String RESPONSE_KEY_GHOSTS = "ghosts";
    
    public static final String ATTR_PK = "pk";
    public static final String ATTR_SK = "sk";
    public static final String ATTR_ENTITY_TYPE = "entityType";
    public static final String ATTR_GHOST_ID = "ghostId";
    public static final String ATTR_USER_ID = "userId";
    public static final String ATTR_CREATED_AT_EPOCH_MS = "createdAtEpochMs";
    public static final String ATTR_TICKER = "ticker";
    public static final String ATTR_DIRECTION = "direction";
    public static final String ATTR_PRICE_SOURCE = "priceSource";
    public static final String ATTR_QUANTITY_TYPE = "quantityType";
    public static final String ATTR_INTENDED_PRICE = "intendedPrice";
    public static final String ATTR_INTENDED_SHARES = "intendedShares";
    public static final String ATTR_INTENDED_DOLLARS = "intendedDollars";
    public static final String ATTR_CONSIDERED_AT = "consideredAtEpochMs";
    public static final String ATTR_HESITATION_TAGS = "hesitationTags";
    public static final String ATTR_NOTE_TEXT = "noteText";
    public static final String ATTR_VOICE_KEY = "voiceKey";
    public static final String ATTR_STATUS = "status";
    public static final String ATTR_LOGGED_QUOTE = "loggedQuote";
    
    public static final int CACHE_TTL_PRICE_SECONDS = 15;
    public static final int CACHE_TTL_TIMESERIES_SECONDS = 21600;
    public static final int CACHE_TTL_SEARCH_SECONDS = 86400;
}
