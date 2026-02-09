//
//  MapPlace.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/9/26.
//


import Foundation
import CoreLocation

struct MapPlace: Identifiable, Hashable {
    let id: UUID
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D

    init(
        id: UUID = UUID(),
        name: String,
        address: String,
        coordinate: CLLocationCoordinate2D
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.coordinate = coordinate
    }

    static func == (lhs: MapPlace, rhs: MapPlace) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
