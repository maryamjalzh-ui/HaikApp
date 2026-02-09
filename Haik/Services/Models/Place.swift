//
//  Place.swift
//  Haik
//
//  Created by layan Alturki on 09/02/2026.
//

import Foundation
import CoreLocation

struct Place: Identifiable, Hashable {

    let id: UUID
    let name: String
    let rating: Int
    let isOpen: Bool
    let coordinate: CLLocationCoordinate2D

    init(
        id: UUID = UUID(),
        name: String,
        rating: Int,
        isOpen: Bool,
        coordinate: CLLocationCoordinate2D
    ) {
        self.id = id
        self.name = name
        self.rating = rating
        self.isOpen = isOpen
        self.coordinate = coordinate
    }

    static func == (lhs: Place, rhs: Place) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
