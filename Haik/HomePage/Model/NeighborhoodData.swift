//
//  NeighborhoodData.swift
//  Haik
//
//  Created by lamess on 08/02/2026.
//
import Foundation
import CoreLocation

// MARK: - Neighborhood Model
struct Neighborhood: Identifiable {
    let id = UUID()
    let name: String
    let region: String
    let coordinate: CLLocationCoordinate2D
    var rating: String = "0.0"
    var reviewCount: String = "0"
}

// MARK: - Neighborhood Data Storage
struct NeighborhoodData {
    static let all: [Neighborhood] = [

        // --- أحياء مشهورة ---
        Neighborhood(name: "حطين", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7649, longitude: 46.5983)),
        Neighborhood(name: "الملقا", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8246, longitude: 46.6099)),
        Neighborhood(name: "الياسمين", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8329, longitude: 46.6462)),
        Neighborhood(name: "النرجس", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8626, longitude: 46.6756)),
        Neighborhood(name: "العليا", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.6959, longitude: 46.6821)),
        Neighborhood(name: "الصحافة", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8124, longitude: 46.6327)),
        Neighborhood(name: "العقيق", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7739, longitude: 46.6189)),
        Neighborhood(name: "الغدير", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7762, longitude: 46.6547)),
        Neighborhood(name: "النخيل", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7488, longitude: 46.6316)),
        Neighborhood(name: "حي السفارات", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.6764, longitude: 46.6251)),

        // --- أحياء خدمية قوية ---
        Neighborhood(name: "الملز", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.6676, longitude: 46.7377)),
        Neighborhood(name: "السليمانية", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.7076, longitude: 46.6947)),
        Neighborhood(name: "الورود", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.7237, longitude: 46.6734)),
        Neighborhood(name: "الفلاح", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.7901, longitude: 46.7034)),
        Neighborhood(name: "الواحة", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.7533, longitude: 46.7107)),
        Neighborhood(name: "قرطبة", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.8156, longitude: 46.7346)),
        Neighborhood(name: "المونسية", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.8479, longitude: 46.7829)),
        Neighborhood(name: "الروضة", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.7249, longitude: 46.7532)),
        Neighborhood(name: "النسيم", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.7089, longitude: 46.8341)),
        Neighborhood(name: "المنار", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.7219, longitude: 46.8063)),

        // --- جنوب وغرب ---
        Neighborhood(name: "الشفاء", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.5496, longitude: 46.7129)),
        Neighborhood(name: "العزيزية", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.5897, longitude: 46.7564)),
        Neighborhood(name: "الدار البيضاء", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.5318, longitude: 46.8214)),
        Neighborhood(name: "المنصورة", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.6124, longitude: 46.7409)),
        Neighborhood(name: "بدر", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.5071, longitude: 46.6862)),
        Neighborhood(name: "العريجاء", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.6216, longitude: 46.6094)),
        Neighborhood(name: "طويق", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.5924, longitude: 46.5286)),
        Neighborhood(name: "ظهرة لبن", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.6491, longitude: 46.5387)),
        Neighborhood(name: "لبن", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.6374, longitude: 46.5511)),
        Neighborhood(name: "المحمدية", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.7326, longitude: 46.6532)),

        // --- أحياء صاعدة ---
        Neighborhood(name: "القيروان", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8732, longitude: 46.5914)),
        Neighborhood(name: "العارض", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8964, longitude: 46.6406)),
        Neighborhood(name: "الرمال", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.9128, longitude: 46.7923)),
        Neighborhood(name: "المهدية", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.7042, longitude: 46.4987)),
        Neighborhood(name: "الندى", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8054, longitude: 46.6631)),
        Neighborhood(name: "التعاون", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7822, longitude: 46.7041)),
        Neighborhood(name: "النفل", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7671, longitude: 46.6872)),
        Neighborhood(name: "إشبيلية", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.7916, longitude: 46.8031)),
        Neighborhood(name: "النهضة", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.7396, longitude: 46.7794)),
        Neighborhood(name: "المروة", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.5642, longitude: 46.7841))
    ]
}
