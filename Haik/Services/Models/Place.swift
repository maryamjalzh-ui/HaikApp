//
//  Place.swift
//  Haik
//
//  Created by layan Alturki on 09/02/2026.
//

import Foundation

struct Place: Identifiable, Hashable {
    let id: UUID
    let name: String
    let rating: Int
    let isOpen: Bool

    init(id: UUID = UUID(), name: String, rating: Int, isOpen: Bool) {
        self.id = id
        self.name = name
        self.rating = rating
        self.isOpen = isOpen
    }
}
