////
////  RecommendedNeighborhood.swift
////  Haik
////
////  Created by Bayan Alshehri on 22/08/1447 AH.
////
//
//import Foundation
//import CoreLocation
//
//struct RecommendedNeighborhood: Identifiable {
//    let id = UUID()
//    let name: String
//    let coordinate: CLLocationCoordinate2D
//    let compatibilityScore: Double
//    let lifestyleScore: Double
//    let priorityScore: Double
//    let transportScore: Double
//}
//

//import Foundation
//import CoreLocation
//
//struct RecommendedNeighborhood: Identifiable, Hashable {
//    let id = UUID()
//    let neighborhood: Neighborhood
//
//    // final 0–100
//    let compatibilityScore: Double
//
//    // sub scores 0–1
//    let lifestyleScore: Double
//    let priorityScore: Double
//    let transportScore: Double
//
//    var name: String { neighborhood.name }
//    var coordinate: CLLocationCoordinate2D { neighborhood.coordinate }
//}

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

    static func == (lhs: RecommendedNeighborhood, rhs: RecommendedNeighborhood) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
