//
//  HomeViewModel.swift
//  Haik
//
//  Created by lamess on 10/02/2026.
//

import SwiftUI
import MapKit
import Combine
import Firebase

class HomeViewModel: ObservableObject {
    @Published var neighborhoods: [Neighborhood] = NeighborhoodData.all
    @Published var searchText: String = ""
    @Published var selectedNeighborhood: Neighborhood? = nil
    @Published var showServices = false
    @Published var neighborhoodForServices: Neighborhood? = nil
    @Published var isKeyboardVisible: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()

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
   
    // دالة جلب وتحديث التقييمات لكل الأحياء
    func updateNeighborhoodRatings() {
        db.collection("neighborhood_reviews").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else { return }
            
            // 1. تجميع التقييمات حسب اسم الحي
            var ratingsMap: [String: [Int]] = [:]
            for doc in documents {
                let data = doc.data()
                if let name = data["neighborhoodName"] as? String,
                   let rating = data["rating"] as? Int {
                    ratingsMap[name, default: []].append(rating)
                }
            }
            
            // 2. تحديث قائمة الأحياء بالقيم الجديدة
            DispatchQueue.main.async {
                self.neighborhoods = NeighborhoodData.all.map { neighborhood in
                    var updated = neighborhood
                    if let ratings = ratingsMap[neighborhood.name], !ratings.isEmpty {
                        let avg = Double(ratings.reduce(0, +)) / Double(ratings.count)
                        updated.rating = String(format: "%.1f", avg) // تحديث التقييم
                        updated.reviewCount = "\(ratings.count)"    // تحديث العداد
                    } else {
                        updated.rating = "0.0"
                        updated.reviewCount = "0"
                    }
                    return updated
                }
            }
        }
    }
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
