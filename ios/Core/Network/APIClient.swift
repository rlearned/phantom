//
//  APIClient.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case notFound
    case serverError(String)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .notFound:
            return "Resource not found"
        case .serverError(let message):
            return message
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

class APIClient {
    static let shared = APIClient()
    
    private let baseURL = "https://14afbieyig.execute-api.us-east-1.amazonaws.com"
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Generic Request Method
    
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresAuth: Bool = true,
        isRetry: Bool = false
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            guard let token = AuthManager.shared.getAccessToken() else {
                throw APIError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }
            case 401:
                if !isRetry && requiresAuth {
                    try await AuthManager.shared.refreshTokens()
                    return try await self.request(
                        endpoint: endpoint,
                        method: method,
                        body: body,
                        requiresAuth: requiresAuth,
                        isRetry: true
                    )
                }
                AuthManager.shared.signOut()
                throw APIError.unauthorized
            case 404:
                throw APIError.notFound
            case 400...499:
                if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data),
                   let message = errorMessage["error"] {
                    throw APIError.serverError(message)
                }
                throw APIError.serverError("Client error: \(httpResponse.statusCode)")
            case 500...599:
                throw APIError.serverError("Server error: \(httpResponse.statusCode)")
            default:
                throw APIError.serverError("Unexpected status code: \(httpResponse.statusCode)")
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Ghost Endpoints
    
    func createGhost(_ request: CreateGhostRequest) async throws -> Ghost {
        return try await self.request(
            endpoint: "/v1/ghosts",
            method: "POST",
            body: request
        )
    }
    
    func listGhosts(limit: Int = 50) async throws -> GhostListResponse {
        return try await self.request(endpoint: "/v1/ghosts?limit=\(limit)")
    }
    
    func getGhost(ghostId: String) async throws -> Ghost {
        return try await self.request(endpoint: "/v1/ghosts/\(ghostId)")
    }
    
    func updateGhost(ghostId: String, request: UpdateGhostRequest) async throws -> Ghost {
        return try await self.request(
            endpoint: "/v1/ghosts/\(ghostId)",
            method: "PATCH",
            body: request
        )
    }
    
    // MARK: - User Endpoints
    
    func getUserProfile() async throws -> UserProfile {
        return try await self.request(endpoint: "/v1/me")
    }
    
    func updateUserProfile(_ request: UpdateUserRequest) async throws -> UserProfile {
        return try await self.request(
            endpoint: "/v1/me",
            method: "PATCH",
            body: request
        )
    }
    
    // MARK: - Dashboard Endpoints
    
    func getDashboardSummary() async throws -> DashboardSummary {
        return try await self.request(endpoint: "/v1/dashboard/summary")
    }
    
    func getAchievements() async throws -> AchievementsResponse {
        return try await self.request(endpoint: "/v1/achievements")
    }
    
    func getStreaks() async throws -> StreaksResponse {
        return try await self.request(endpoint: "/v1/streaks")
    }
    
    // MARK: - Market Data Endpoints
    
    func validateTicker(symbol: String) async throws -> TickerValidationResponse {
        return try await self.request(endpoint: "/v1/market/validate?symbol=\(symbol)")
    }

    func getMarketQuote(symbol: String) async throws -> MarketQuoteResponse {
        return try await self.request(endpoint: "/v1/market/quote?symbol=\(symbol)")
    }
    
    // MARK: - Health Check
    
    func healthCheck() async throws -> [String: String] {
        return try await self.request(endpoint: "/v1/health", requiresAuth: false)
    }
    
    // TODO: Need a end point function for v1/market/candles
    
}
