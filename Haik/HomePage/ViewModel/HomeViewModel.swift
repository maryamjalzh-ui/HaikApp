//
//  HomeViewModel.swift
//  Haik
//
//  Created by lamess on 10/02/2026.
//

import SwiftUI
import MapKit
import Combine

class HomeViewModel: ObservableObject {
    @Published var neighborhoods: [Neighborhood] = NeighborhoodData.all
    @Published var searchText: String = ""
    @Published var selectedNeighborhood: Neighborhood? = nil
    @Published var showServices = false
    @Published var neighborhoodForServices: Neighborhood? = nil
    
    @Published var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    )
    
    var filteredNeighborhoods: [Neighborhood] {
        if searchText.isEmpty { return [] }
        return neighborhoods.filter { $0.name.contains(searchText) }
    }
    
    func selectNeighborhood(_ neighborhood: Neighborhood) {
        withAnimation(.spring()) {
            selectedNeighborhood = neighborhood
            searchText = ""
            position = .region(MKCoordinateRegion(
                center: neighborhood.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
    // MARK: - التعديل في الـ ViewModel
    @Published var isKeyboardVisible: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        // مراقبة ظهور الكيبورد
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { _ in true }
            .assign(to: \.isKeyboardVisible, on: self)
            .store(in: &cancellables)

        // مراقبة اختفاء الكيبورد
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in false }
            .assign(to: \.isKeyboardVisible, on: self)
            .store(in: &cancellables)
    }
    
}
