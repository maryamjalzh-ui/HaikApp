import Foundation
import Combine

@MainActor
final class NeighborhoodServicesViewModel: ObservableObject {

    let neighborhood: Neighborhood

    let services: [ServiceCategory] = [
        .hospitals,
        .cafes,
        .parks,
        .libraries,
        .supermarkets,
        .restaurants,
        .schools,
        .groceries,
        .universities,
        .metro,
        .gasStations,
        .cinema
    ]

    init(neighborhood: Neighborhood) {
        self.neighborhood = neighborhood
    }
}
