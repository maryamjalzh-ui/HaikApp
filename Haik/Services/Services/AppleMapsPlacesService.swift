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
    ) async throws -> [Place]
}

final class AppleMapsPlacesService: PlacesSearching {

    private let geocoder = CLGeocoder()

    func searchPlaces(
        query: String,
        center: CLLocationCoordinate2D,
        regionSpanMeters: CLLocationDistance,
        limit: Int,
        neighborhoodNameArabic: String
    ) async throws -> [Place] {

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

        let rawPlaces: [Place] = items.compactMap { item in
            guard let name = item.name else { return nil }
            let addr = item.placemark.title ?? ""
            return Place(
                name: name,
                address: addr,
                coordinate: item.placemark.coordinate
            )
        }

        let normalizedNeighborhood = normalize(neighborhoodNameArabic)

        let firstPass = rawPlaces.filter { p in
            let a = normalize(p.address)
            return a.contains(normalizedNeighborhood) || a.contains(normalize("حي \(neighborhoodNameArabic)"))
        }

        let candidates = firstPass.isEmpty ? Array(rawPlaces.prefix(25)) : Array(firstPass.prefix(25))

        var final: [Place] = []
        final.reserveCapacity(candidates.count)

        for p in candidates {
            do {
                let loc = CLLocation(latitude: p.coordinate.latitude, longitude: p.coordinate.longitude)
                let placemarks = try await geocoder.reverseGeocodeLocation(loc, preferredLocale: Locale(identifier: "ar"))
                guard let pm = placemarks.first else { continue }

                let subLocality = normalize(pm.subLocality ?? "")
                let locality = normalize(pm.locality ?? "")
                let full = normalize(pm.name ?? "") + normalize(pm.thoroughfare ?? "") + normalize(pm.subLocality ?? "")

                let matches = subLocality.contains(normalizedNeighborhood)
                    || (locality.contains(normalize("الرياض")) && full.contains(normalizedNeighborhood))

                if matches { final.append(p) }
            } catch {
                continue
            }
        }

        return Array(Set(final))
    }

    private func normalize(_ s: String) -> String {
        s.lowercased()
            .replacingOccurrences(of: "أ", with: "ا")
            .replacingOccurrences(of: "إ", with: "ا")
            .replacingOccurrences(of: "آ", with: "ا")
            .replacingOccurrences(of: "ة", with: "ه")
            .replacingOccurrences(of: "ى", with: "ي")
            .replacingOccurrences(of: "ـ", with: "")
            .replacingOccurrences(of: " ", with: "")
    }
}
