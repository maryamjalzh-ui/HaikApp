import Foundation
import Combine

@MainActor
final class ServiceListViewModel: ObservableObject {

    let service: ServiceCategory
    let places: [Place]

    @Published var selectedPlace: Place? = nil

    var title: String { service.rawValue }

    init(service: ServiceCategory, places: [Place]) {
        self.service = service
        self.places = places
    }
}
