////
////  RecommendedNeighborhood.swift
////  Haik
////
////  Created by Bayan Alshehri on 22/08/1447 AH.
////

import Foundation
import CoreLocation

struct RecommendedNeighborhood: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let compatibilityScore: Double
    let lifestyleScore: Double
    let priorityScore: Double
    let transportScore: Double
    let rating: Double

    static func == (lhs: RecommendedNeighborhood, rhs: RecommendedNeighborhood) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
