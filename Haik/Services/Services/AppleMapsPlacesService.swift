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

    private let localeAR = Locale(identifier: "ar")
    private let maxGeocodeCandidates = 25
    private let maxConcurrentGeocodes = 6

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

        if rawPlaces.isEmpty { return [] }

        let target = normalizeArabic(neighborhoodNameArabic)

        let maxDistanceMeters: CLLocationDistance = min(regionSpanMeters * 0.55, 2200)
        let centerLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)

        let distanceFiltered = rawPlaces.filter { p in
            let loc = CLLocation(latitude: p.coordinate.latitude, longitude: p.coordinate.longitude)
            return loc.distance(from: centerLoc) <= maxDistanceMeters
        }

        if distanceFiltered.isEmpty { return [] }

        var scored: [(place: MapPlace, score: Int)] = distanceFiltered.map { p in
            (p, scoreMatch(text: p.address, target: target))
        }

        scored.sort { $0.score > $1.score }
        let top = Array(scored.prefix(maxGeocodeCandidates))

        let needGeocodeAnyway = (top.first?.score ?? 0) < 2

        let refined: [(MapPlace, Int)] = try await withThrowingTaskGroup(of: (MapPlace, Int).self) { group in
            let localeAR = self.localeAR

            func run(_ p: MapPlace, _ baseScore: Int) async -> (MapPlace, Int) {
                if baseScore >= 6 && !needGeocodeAnyway {
                    return (p, baseScore + 3)
                }

                do {
                    let loc = CLLocation(latitude: p.coordinate.latitude, longitude: p.coordinate.longitude)
                    let geocoder = CLGeocoder()
                    let placemarks = try await geocoder.reverseGeocodeLocation(loc, preferredLocale: localeAR)
                    guard let pm = placemarks.first else { return (p, baseScore) }

                    let subLocality = pm.subLocality ?? ""
                    let subScore = scoreMatch(text: subLocality, target: target)
                    if subScore == 0 { return (p, baseScore) }

                    let fields: [String] = [
                        pm.name,
                        pm.thoroughfare,
                        pm.locality,
                        pm.subAdministrativeArea,
                        pm.administrativeArea
                    ].compactMap { $0 }

                    let aoi = pm.areasOfInterest ?? []
                    let combined = (fields + aoi).joined(separator: " ")

                    let geoScore = scoreMatch(text: combined, target: target)
                    return (p, baseScore + geoScore + 3)
                } catch {
                    return (p, baseScore)
                }
            }

            var iterator = top.makeIterator()
            var running = 0
            let maxConcurrent = maxConcurrentGeocodes

            while running < maxConcurrent, let next = iterator.next() {
                running += 1
                group.addTask { await run(next.place, next.score) }
            }

            var out: [(MapPlace, Int)] = []
            out.reserveCapacity(top.count)

            while let result = try await group.next() {
                out.append(result)
                running -= 1

                if let next = iterator.next() {
                    running += 1
                    group.addTask { await run(next.place, next.score) }
                }
            }

            return out
        }

        let threshold = 5
        var accepted = refined
            .filter { $0.1 >= threshold }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }

        accepted = uniquePreservingOrder(accepted)

        if accepted.isEmpty {
            let fallback = refined
                .sorted { $0.1 > $1.1 }
                .prefix(12)
                .map { $0.0 }
            return uniquePreservingOrder(Array(fallback))
        }

        return accepted
    }
}

private let _localeAR = Locale(identifier: "ar")

private func normalizeArabic(_ input: String) -> String {
    var s = input.trimmingCharacters(in: .whitespacesAndNewlines)

    s = s.replacingOccurrences(of: "أ", with: "ا")
    s = s.replacingOccurrences(of: "إ", with: "ا")
    s = s.replacingOccurrences(of: "آ", with: "ا")
    s = s.replacingOccurrences(of: "ى", with: "ي")
    s = s.replacingOccurrences(of: "ة", with: "ه")

    s = s.folding(options: .diacriticInsensitive, locale: _localeAR)

    s = s.replacingOccurrences(of: "حي ", with: "")
    s = s.replacingOccurrences(of: "حي", with: "")
    s = s.replacingOccurrences(of: "ال", with: "")

    s = s.components(separatedBy: .whitespacesAndNewlines)
        .filter { !$0.isEmpty }
        .joined(separator: " ")

    return s
}

private func scoreMatch(text: String, target: String) -> Int {
    let t = normalizeArabic(text)
    let trg = target

    if trg.isEmpty { return 0 }
    if t.contains(trg) { return 6 }

    let parts = trg.split(separator: " ").map(String.init)
    if parts.count >= 2 {
        let hits = parts.reduce(0) { $0 + (t.contains($1) ? 1 : 0) }
        if hits == parts.count { return 5 }
        if hits >= max(1, parts.count - 1) { return 3 }
        return 0
    } else {
        if let p = parts.first, t.contains(p) { return 3 }
        return 0
    }
}

private func uniquePreservingOrder(_ places: [MapPlace]) -> [MapPlace] {
    var seen = Set<MapPlace>()
    var out: [MapPlace] = []
    out.reserveCapacity(places.count)
    for p in places {
        if !seen.contains(p) {
            seen.insert(p)
            out.append(p)
        }
    }
    return out
}
