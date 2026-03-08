//
//  HaikAIService.swift
//  Haik
//
//  Created by Shahad Alharbi on 3/6/26.
//

import Foundation

enum HaikAIServiceError: Error {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError
}

final class HaikAIService {
    static let shared = HaikAIService()
    private init() {}

    var baseURLString: String = "https://neighborhood-recommender--aakerplunk.replit.app"

    func recommend(request: AIRecommendRequest) async throws -> AIRecommendationResponse {
        guard let url = URL(string: baseURLString + "/api/recommend") else {
            throw HaikAIServiceError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let http = response as? HTTPURLResponse else {
            throw HaikAIServiceError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw HaikAIServiceError.serverError(http.statusCode)
        }

        guard let decoded = try? JSONDecoder().decode(AIRecommendationResponse.self, from: data) else {
            throw HaikAIServiceError.decodingError
        }

        return decoded
    }
}
