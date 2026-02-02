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
    
    public static final String STATUS_OPEN = "OPEN";
    public static final String STATUS_CLOSED = "CLOSED";
    
    public static final String PLAN_FREE = "FREE";
    
    public static final String SOURCE_TWELVE_DATA = "twelve_data";
    
    public static final int CACHE_TTL_PRICE_SECONDS = 15;
    public static final int CACHE_TTL_TIMESERIES_SECONDS = 21600;
    public static final int CACHE_TTL_SEARCH_SECONDS = 86400;
}
