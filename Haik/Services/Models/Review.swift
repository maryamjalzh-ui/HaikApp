//
//  Review.swift
//  Haik
//
//  Created by layan Alturki on 09/02/2026.
//
import Foundation
//
//enum ReviewCategory: String, CaseIterable, Identifiable {
//    case electricity = "الكهرباء"
//    case water = "المياه"
//    case internet = "الانترنت"
//    case safety = "الأمان"
//    case quiet = "الهدوء"
//    case culture = "ثقافة الناس"

enum ReviewCategory: String, CaseIterable, Identifiable {
    case general = "general"
    case electricity = "electricity"
    case water = "water"
    case internet = "internet"
    case quiet = "quiet"
    case culture = "culture"

  
    var id: String { rawValue }
}

struct NeighborhoodReview: Identifiable, Hashable {
    let id: String                 // Firestore documentId
    let category: ReviewCategory
    let rating: Int
    let comment: String
    let createdAt: Date
    let userId: String?
    let userName: String?

    init(
        id: String,
        category: ReviewCategory,
        rating: Int,
        comment: String,
        createdAt: Date,
        userId: String? = nil,
        userName: String? = nil
    ) {
        self.id = id
        self.category = category
        self.rating = rating
        self.comment = comment
        self.createdAt = createdAt
        self.userId = userId
        self.userName = userName
    }
}
