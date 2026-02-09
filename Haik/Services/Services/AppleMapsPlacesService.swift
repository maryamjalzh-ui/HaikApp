//
//  AppleMapsPlacesService.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/9/26.
//
import Foundation
import MapKit
import CoreLocation

protocol PlacesSearching {
    func searchPlaces(
        query: String,
        center: CLLocationCoordinate2D,
        regionSpanMeters: CLLocationDistance,
        limit: Int,
        neighborhoodNameArabic: String
    ) async throws -> [MapPlace]
}

final class AppleMapsPlacesService: PlacesSearching {

    private let geocoder = CLGeocoder()

    func searchPlaces(
        query: String,
        center: CLLocationCoordinate2D,
        regionSpanMeters: CLLocationDistance,
        limit: Int,
        neighborhoodNameArabic: String
    ) async throws -> [MapPlace] {

        let region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: regionSpanMeters,
            longitudinalMeters: regionSpanMeters
        )

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        request.resultTypes = [.pointOfInterest]

        let response = try await MKLocalSearch(request: request).start()
        let items = Array(response.mapItems.prefix(limit))

        let rawPlaces: [MapPlace] = items.compactMap { item in
            guard let name = item.name else { return nil }
            let addr = item.placemark.title ?? ""
            return MapPlace(
                name: name,
                address: addr,
                coordinate: item.placemark.coordinate
            )
        }

        func addressContainsNeighborhood(_ address: String) -> Bool {
            address.contains(neighborhoodNameArabic) || address.contains("حي \(neighborhoodNameArabic)")
        }

        let firstPass = rawPlaces.filter { addressContainsNeighborhood($0.address) }
        let candidates = firstPass.isEmpty ? Array(rawPlaces.prefix(25)) : Array(firstPass.prefix(25))

        if firstPass.isEmpty {
            return Array(Set(candidates))
        }

        var final: [MapPlace] = []
        final.reserveCapacity(candidates.count)

        for p in candidates {
            if addressContainsNeighborhood(p.address) {
                final.append(p)
                continue
            }

            do {
                let loc = CLLocation(latitude: p.coordinate.latitude, longitude: p.coordinate.longitude)
                let placemarks = try await geocoder.reverseGeocodeLocation(loc, preferredLocale: Locale(identifier: "ar"))
                guard let pm = placemarks.first else { continue }

                let subLocality = pm.subLocality ?? ""
                let thoroughfare = pm.thoroughfare ?? ""
                let name = pm.name ?? ""

                let combined = (name + " " + thoroughfare + " " + subLocality)
                if combined.contains(neighborhoodNameArabic) {
                    final.append(p)
                }
            } catch { }
        }

        return Array(Set(final))
    }
}
