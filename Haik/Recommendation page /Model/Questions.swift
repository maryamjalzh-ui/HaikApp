//
//  Questions.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/8/26.
//

import Foundation

enum SelectionMode: Hashable {
    case single
    case multi(max: Int)
}

struct Questions: Identifiable, Hashable {
    let id: String
    let title: String
    let options: [RecommendationOption]
    let selectionMode: SelectionMode
}

struct RecommendationOption: Identifiable, Hashable {
    let id: String
    let title: String
    let icon: HaikIcon
    let showsNeighborhoodPicker: Bool
}

enum HaikIcon: String, Hashable {
    case calm = "leaf"
    case active = "fireworks"
    case fullServices = "cart"

    case nearWork = "briefcase"
    case nearFamily = "house"
    case services = "basket"
    case schools = "pencil.and.ruler"
    case universities = "graduationcap"
    case entertainment = "popcorn"

    case metroPrimary = "tram"
    case metroSometimes = "tram.card"
    case car = "car"

    var systemName: String { rawValue }
}
