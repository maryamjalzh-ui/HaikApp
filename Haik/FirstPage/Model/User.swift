//
//  User.swift
//  Haik
//
//  Created by lamess on 12/02/2026.
//
import Foundation

struct UserProfile: Codable {
    var id: String
    var name: String
    var email: String
    var rating: Double
    var comment: String
    var favoriteDistricts: [String]
}
