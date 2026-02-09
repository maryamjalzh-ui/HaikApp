
import Foundation
import Combine
import CoreLocation

@MainActor
final class NeighborhoodServicesViewModel: ObservableObject {

    let neighborhoodName: String
    let neighborhoodCoordinate: CLLocationCoordinate2D

    let services: [ServiceCategory] = ServiceCategory.allCases

    @Published private(set) var reviews: [NeighborhoodReview] = []

    @Published var selectedCategory: ReviewCategory = .electricity
    @Published var newRating: Int = 0
    @Published var newComment: String = ""

    @Published private(set) var placesByService: [ServiceCategory: [Place]] = [:]
    @Published private(set) var isLoadingByService: Set<ServiceCategory> = []

    private let placesService: PlacesSearching

    init(
        neighborhoodName: String,
        coordinate: CLLocationCoordinate2D,
        placesService: PlacesSearching = AppleMapsPlacesService()
    ) {
        self.neighborhoodName = neighborhoodName
        self.neighborhoodCoordinate = coordinate
        self.placesService = placesService

        self.reviews = [
            NeighborhoodReview(category: .electricity, rating: 3, comment: "جيده جدا! لايوجد انقطاعات.", createdAt: Date().addingTimeInterval(-2 * 24 * 3600)),
            NeighborhoodReview(category: .internet, rating: 4, comment: "النت ممتاز أغلب الوقت.", createdAt: Date().addingTimeInterval(-6 * 24 * 3600))
        ]
    }

    func places(for service: ServiceCategory) -> [Place] {
        placesByService[service] ?? []
    }

    func loadPlacesIfNeeded(for service: ServiceCategory) async {
        if placesByService[service] != nil { return }
        if isLoadingByService.contains(service) { return }

        isLoadingByService.insert(service)
        defer { isLoadingByService.remove(service) }

        do {
            let mapPlaces = try await placesService.searchPlaces(
                query: service.rawValue,
                center: neighborhoodCoordinate,
                regionSpanMeters: 3500,
                limit: 40,
                neighborhoodNameArabic: neighborhoodName
            )

            let uiPlaces: [Place] = mapPlaces.map {
                Place(
                    name: $0.name,
                    rating: Int.random(in: 3...5),
                    isOpen: Bool.random(),
                    coordinate: $0.coordinate
                )
            }


            placesByService[service] = uiPlaces
        } catch {
            placesByService[service] = []
        }
    }

    func addReview() {
        let trimmed = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard (1...5).contains(newRating) else { return }

        let review = NeighborhoodReview(category: selectedCategory, rating: newRating, comment: trimmed)
        reviews.insert(review, at: 0)

        newRating = 0
        newComment = ""
        selectedCategory = .electricity
    }
}
