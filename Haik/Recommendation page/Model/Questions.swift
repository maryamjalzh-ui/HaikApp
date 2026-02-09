//
//  Questions.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/8/26.
//

import Foundation

struct Questions: Identifiable, Hashable {
    let id: String
    let title: String
    let options: [RecommendationOption]
}

struct RecommendationOption: Identifiable, Hashable {
    let id: String
    let title: String
    let sfSymbol: String
}
