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
    let address: String
    let coordinate: CLLocationCoordinate2D
    let rating: Int
    let isOpen: Bool

    init(
        id: UUID = UUID(),
        name: String,
        address: String,
        coordinate: CLLocationCoordinate2D,
        rating: Int = 0,
        isOpen: Bool = true
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.rating = rating
        self.isOpen = isOpen
    }

    static func == (lhs: Place, rhs: Place) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
