//
//  HomeViewModel.swift
//  Haik
//
//  Created by lamess on 10/02/2026.
//

import SwiftUI
import MapKit

@Observable
class HomeViewModel {
    // البيانات الأساسية
    var allNeighborhoods: [Neighborhood] = NeighborhoodData.all
    
    // حالات الواجهة والبحث
    var searchText: String = ""
    var selectedNeighborhood: Neighborhood? = nil
    var showServices = false
    var neighborhoodForServices: Neighborhood? = nil
    
    var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    )
    
    // منطق فلترة البحث
    var filteredResults: [Neighborhood] {
        if searchText.isEmpty {
            return []
        } else {
            return allNeighborhoods.filter { $0.name.contains(searchText) }
        }
    }
    
    // دالة اختيار الحي من الخريطة أو البحث
    func select(neighborhood: Neighborhood) {
        withAnimation(.spring()) {
            selectedNeighborhood = neighborhood
            searchText = "" // لتصفية قائمة البحث بعد الاختيار
            position = .region(MKCoordinateRegion(
                center: neighborhood.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
}
