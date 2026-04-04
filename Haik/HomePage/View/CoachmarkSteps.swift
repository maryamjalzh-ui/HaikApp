//
//  CoachmarkSteps.swift
//  
//
//  Created by Bayan Alshehri on 15/10/1447 AH.
//

import SwiftUI

enum CoachmarkShape: Hashable {
    case circle
    case roundedRect(cornerRadius: CGFloat)
}

struct CoachmarkStep: Identifiable, Hashable {
    let id: CoachmarkTargetID
    let title: String
    let message: String
    let shape: CoachmarkShape
}

let coachmarkSteps: [CoachmarkStep] = [
    .init(
        id: .recommendationButton,
        title: String(localized: "coach_recommendation_title"),
        message: String(localized: "coach_recommendation_message"),
        shape: .circle
    ),
    .init(
        id: .pinRating,
        title: String(localized: "coach_rating_title"),
        message: String(localized: "coach_rating_message"),
        shape: .roundedRect(cornerRadius: 12)
    ),
    .init(
        id: .bottomCard,
        title: String(localized: "coach_card_title"),
        message: String(localized: "coach_card_message"),
        shape: .roundedRect(cornerRadius: 22)
    )
]
