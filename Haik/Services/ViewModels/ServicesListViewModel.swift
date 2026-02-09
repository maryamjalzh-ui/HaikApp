import Foundation
import Combine
import CoreLocation

@MainActor
final class ServicesListViewModel: ObservableObject {

    let neighborhood: Neighborhood
    let service: ServiceCategory

    @Published var places: [Place] = []
    @Published var selectedPlace: Place? = nil
    @Published var isLoading: Bool = false

    private let placesService: PlacesSearching

    var title: String { service.rawValue }

    init(
        neighborhood: Neighborhood,
        service: ServiceCategory,
        placesService: PlacesSearching = AppleMapsPlacesService()
    ) {
        self.neighborhood = neighborhood
        self.service = service
        self.placesService = placesService
    }

    func load() async {
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await placesService.searchPlaces(
                query: service.mapsQuery,
                center: neighborhood.coordinate,
                regionSpanMeters: 3500,
                limit: 30,
                neighborhoodNameArabic: neighborhood.name
            )
            places = result.sorted { $0.name < $1.name }
        } catch {
            places = []
        }
    }
}
