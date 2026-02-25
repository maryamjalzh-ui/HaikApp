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
    
    // MARK: - المحرك الذكي للبحث (Efficient Search)
    var filteredNeighborhoods: [Neighborhood] {
        let query = searchText.normalizedArabic()
        
        if query.isEmpty { return [] }
        
        return neighborhoods.filter { neighborhood in
            neighborhood.name.normalizedArabic().contains(query)
        }
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
    
    func updateNeighborhoodRatings() {
        db.collection("neighborhood_reviews").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else { return }
            
            var ratingsMap: [String: [Int]] = [:]
            for doc in documents {
                let data = doc.data()
                if let name = data["neighborhoodName"] as? String,
                   let rating = data["rating"] as? Int {
                    ratingsMap[name, default: []].append(rating)
                }
            }
            
            DispatchQueue.main.async {
                self.neighborhoods = NeighborhoodData.all.map { neighborhood in
                    var updated = neighborhood
                    if let ratings = ratingsMap[neighborhood.name], !ratings.isEmpty {
                        let avg = Double(ratings.reduce(0, +)) / Double(ratings.count)
                        updated.rating = String(format: "%.1f", avg)
                        updated.reviewCount = "\(ratings.count)"
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
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { _ in true }
            .assign(to: \.isKeyboardVisible, on: self)
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in false }
            .assign(to: \.isKeyboardVisible, on: self)
            .store(in: &cancellables)
            
        updateNeighborhoodRatings()
    }
}

// MARK: - Arabic Normalization Extension
extension String {
    func normalizedArabic() -> String {
        var text = self.lowercased()
        
        // استبدال كل أشكال الألف بألف عادية
        text = text.replacingOccurrences(of: "[أإآٱ]", with: "ا", options: .regularExpression)
        
        // استبدال التاء المربوطة بالهاء
        text = text.replacingOccurrences(of: "ة", with: "ه")
        
        // استبدال الألف المقصورة بالياء
        text = text.replacingOccurrences(of: "ى", with: "ي")
        
        // حذف المسافات الزائدة
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
