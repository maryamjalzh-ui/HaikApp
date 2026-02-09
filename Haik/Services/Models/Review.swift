//
//  Review.swift
//  Haik
//
//  Created by layan Alturki on 09/02/2026.
//
import Foundation

enum ReviewCategory: String, CaseIterable, Identifiable {
    case electricity = "الكهرباء"
    case water = "المياه"
    case internet = "الانترنت"
    case safety = "الأمان"
    case quiet = "الهدوء"
    case culture = "ثقافة الناس"

    var id: String { rawValue }
}

struct NeighborhoodReview: Identifiable, Hashable {
    let id: UUID
    let category: ReviewCategory
    let rating: Int
    let comment: String
    let createdAt: Date

    init(id: UUID = UUID(), category: ReviewCategory, rating: Int, comment: String, createdAt: Date = Date()) {
        self.id = id
        self.category = category
        self.rating = rating
        self.comment = comment
        self.createdAt = createdAt
    }
}
