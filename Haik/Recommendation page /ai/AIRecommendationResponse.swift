//
//  AIRecommendationResponse.swift
//  Haik
//
//  Created by Shahad Alharbi on 3/6/26.
//

import Foundation

struct AIRecommendationResponse: Codable {
    let scoredNeighborhoods: [AIScoredNeighborhood]
}

struct AIScoredNeighborhood: Codable {
    let name: String
    let score: Double
}
