//
//  AIRecommendRequest.swift
//  Haik
//
//  Created by Shahad Alharbi on 3/6/26.
//

import Foundation

struct AIRecommendRequest: Codable {
    let appLocale: String
    let userAnswers: [String: [String]]
    let pickedNeighborhoodByOptionID: [String: String]
    let questions: [AIQuestionDTO]
    let candidates: [AICandidateDTO]
    let maxResults: Int
}

struct AIQuestionDTO: Codable {
    let id: String
    let title: String
    let options: [AIOptionDTO]
}

struct AIOptionDTO: Codable {
    let id: String
    let title: String
}

struct AICandidateDTO: Codable {
    let name: String
    let region: String?
    let avgPricePerMeter: Double?
    let metroCount: Int
    let servicesCount: Int
    let entertainmentCount: Int
    let schoolsCount: Int
    let distanceFromAnchorMeters: Double?
    let lifestyleMatchScore: Double
    let priorityMatchScore: Double
    let transportMatchScore: Double
    let priceMatchScore: Double
    let baseCompatibilityScore: Double
}
