$version: "2.0"

namespace com.phantom.api

service PhantomApi {
    version: "1.0"
    operations: [
        GetUser
        UpdateUser
        DeleteUser
        ListGhosts
        CreateGhost
        GetGhost
        UpdateGhost
        GetDashboardSummary
        GetAchievements
        GetStreaks
        GetMarketCandles
        GetMarketQuote
        GetHealth
    ]
}

@readonly
@http(method: "GET", uri: "/v1/me")
operation GetUser {
    output: UserProfileResponse
    errors: [
        NotFoundError
        InternalServerError
    ]
}

@http(method: "PATCH", uri: "/v1/me")
operation UpdateUser {
    input: UpdateUserRequest
    output: UserProfileResponse
    errors: [
        BadRequestError
        InternalServerError
    ]
}

@http(method: "DELETE", uri: "/v1/me")
@idempotent
operation DeleteUser {
    output: DeleteUserResponse
    errors: [
        InternalServerError
    ]
}

@readonly
@http(method: "GET", uri: "/v1/ghosts")
operation ListGhosts {
    input: ListGhostsRequest
    output: ListGhostsResponse
    errors: [
        BadRequestError
        InternalServerError
    ]
}

@http(method: "POST", uri: "/v1/ghosts")
operation CreateGhost {
    input: CreateGhostRequest
    output: GhostResponse
    errors: [
        BadRequestError
        InternalServerError
    ]
}

@readonly
@http(method: "GET", uri: "/v1/ghosts/{ghostId}")
operation GetGhost {
    input: GetGhostRequest
    output: GhostResponse
    errors: [
        NotFoundError
        InternalServerError
    ]
}

@http(method: "PATCH", uri: "/v1/ghosts/{ghostId}")
operation UpdateGhost {
    input: UpdateGhostRequest
    output: GhostResponse
    errors: [
        BadRequestError
        NotFoundError
        InternalServerError
    ]
}

@readonly
@http(method: "GET", uri: "/v1/dashboard/summary")
operation GetDashboardSummary {
    output: DashboardSummaryResponse
    errors: [
        InternalServerError
    ]
}

@readonly
@http(method: "GET", uri: "/v1/achievements")
operation GetAchievements {
    output: AchievementsResponse
    errors: [
        InternalServerError
    ]
}

@readonly
@http(method: "GET", uri: "/v1/streaks")
operation GetStreaks {
    output: StreaksResponse
    errors: [
        InternalServerError
    ]
}

@readonly
@http(method: "GET", uri: "/v1/market/candles")
operation GetMarketCandles {
    input: GetMarketCandlesRequest
    output: MarketCandlesResponse
    errors: [
        BadRequestError
        InternalServerError
    ]
}

@readonly
@http(method: "GET", uri: "/v1/market/quote")
operation GetMarketQuote {
    input: GetMarketQuoteRequest
    output: MarketQuoteResponse
    errors: [
        BadRequestError
        InternalServerError
    ]
}

@readonly
@http(method: "GET", uri: "/v1/health")
operation GetHealth {
    output: HealthResponse
}

structure UserProfileResponse {
    @required
    userId: String

    @required
    createdAt: String

    timezone: String

    @required
    plan: String

    settings: Document
}

structure UpdateUserRequest {
    timezone: String
    settings: Document
}

structure DeleteUserResponse {
    @required
    message: String
}

structure ListGhostsRequest {
    @httpQuery("limit")
    limit: Integer

    @httpQuery("lastEvaluatedKey")
    lastEvaluatedKey: String
}

structure ListGhostsResponse {
    @required
    ghosts: GhostList

    lastEvaluatedKey: String
}

structure CreateGhostRequest {
    @required
    ticker: String

    @required
    direction: String

    @required
    priceSource: String

    intendedPrice: Double

    consideredAtEpochMs: Long

    @required
    quantityType: String

    @required
    intendedSize: Double

    hesitationTags: StringList

    noteText: String

    voiceKey: String
}

structure GhostResponse {
    @required
    ghostId: String

    @required
    userId: String

    @required
    createdAtEpochMs: Long

    @required
    ticker: String

    @required
    direction: String

    @required
    intendedPrice: Double

    @required
    intendedSize: Double

    hesitationTags: StringList

    noteText: String

    voiceKey: String

    @required
    status: String

    @required
    loggedQuote: QuoteData
}

structure GetGhostRequest {
    @required
    @httpLabel
    ghostId: String
}

structure UpdateGhostRequest {
    @required
    @httpLabel
    ghostId: String

    status: String

    noteText: String
}

structure QuoteData {
    @required
    price: Double

    @required
    providerTs: String

    @required
    capturedAtEpochMs: Long

    @required
    source: String
}

structure DashboardSummaryResponse {
    @required
    ghostCountTotal: Integer

    @required
    ghostCount30d: Integer

    lastGhostAtEpochMs: Long

    streakDays: Integer

    topHesitationTags30d: HesitationTagList
}

structure HesitationTag {
    @required
    tag: String

    @required
    count: Integer
}

structure AchievementsResponse {
    achievements: AchievementList
}

structure Achievement {
    @required
    id: String

    @required
    name: String

    @required
    unlocked: Boolean
}

structure StreaksResponse {
    @required
    currentStreak: Integer

    @required
    longestStreak: Integer
}

structure GetMarketCandlesRequest {
    @required
    @httpQuery("symbol")
    symbol: String

    @httpQuery("interval")
    interval: String

    @httpQuery("range")
    range: String
}

structure MarketCandlesResponse {
    @required
    symbol: String

    @required
    interval: String

    @required
    candles: CandleList

    @required
    fetchedAt: String
}

structure Candle {
    @required
    datetime: String

    @required
    open: Double

    @required
    high: Double

    @required
    low: Double

    @required
    close: Double

    volume: Long
}

structure GetMarketQuoteRequest {
    @required
    @httpQuery("symbol")
    symbol: String
}

structure MarketQuoteResponse {
    @required
    symbol: String

    @required
    price: Double

    @required
    providerTs: String

    @required
    fetchedAt: String
}

structure HealthResponse {
    @required
    status: String

    @required
    timestamp: String
}

@error("client")
structure BadRequestError {
    @required
    message: String
}

@error("client")
structure NotFoundError {
    @required
    message: String
}

@error("server")
structure InternalServerError {
    @required
    message: String
}

list GhostList {
    member: GhostResponse
}

list StringList {
    member: String
}

list HesitationTagList {
    member: HesitationTag
}

list AchievementList {
    member: Achievement
}

list CandleList {
    member: Candle
}
