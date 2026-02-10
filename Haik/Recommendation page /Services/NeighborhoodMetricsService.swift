//
//  NeighborhoodMetricsService.swift
//  Haik
//
//  Created by Bayan Alshehri on 22/08/1447 AH.
//

import Foundation
import CoreLocation

@MainActor
final class NeighborhoodMetricsService {

    private let placesService: PlacesSearching

    init(placesService: PlacesSearching = AppleMapsPlacesService()) {
        self.placesService = placesService
    }

    func fetchCount(
        category: ServiceCategory,
        neighborhoodNameArabic: String,
        coordinate: CLLocationCoordinate2D,
        regionSpanMeters: CLLocationDistance = 3500,
        limit: Int = 40
    ) async -> Int {

        do {
            let results = try await placesService.searchPlaces(
                query: category.rawValue,
                center: coordinate,
                regionSpanMeters: regionSpanMeters,
                limit: limit,
                neighborhoodNameArabic: neighborhoodNameArabic
            )
            return results.count
        } catch {
            return 0
        }
    }
}
