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
        let query = searchText.normalizedArabic().lowercased()
        
        if query.isEmpty { return [] }
        
        return neighborhoods.filter { neighborhood in
            let nameArMatch = neighborhood.nameAr.normalizedArabic().contains(query)
            
            // 2. البحث في الاسم الإنجليزي
            let nameEnMatch = neighborhood.nameEn.lowercased().contains(query)
            
            // 3. البحث في الاتجاهات (Keys)
            let regionMatch = isMatch(query: query, region: neighborhood.region)
            
            return nameArMatch || nameEnMatch || regionMatch
        }
    }
    
    private func isMatch(query: String, region: String) -> Bool {
        let mapping: [String: [String]] = [
            "شمال": ["شمال", "north", "shmal"],
            "جنوب": ["جنوب", "south", "janoub"],
            "شرق":  ["شرق", "east", "sharq"],
            "غرب":  ["غرب", "west", "gharb"],
            "وسط":  ["وسط", "center", "central", "wasa"]
        ]
        
        if let keywords = mapping[region] {
            return keywords.contains { $0.contains(query) }
        }
        
        return false
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
                    
                    // التعديل الجوهري هنا:
                    // نقارن الاسم الموجود في Firebase بـ neighborhood.nameAr الثابت
                    // وليس neighborhood.name المتغير حسب اللغة
                    if let ratings = ratingsMap[neighborhood.nameAr], !ratings.isEmpty {
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
