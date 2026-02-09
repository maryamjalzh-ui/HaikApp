//
//  NeighborhoodData.swift
//  Haik
//
//  Created by lamess on 08/02/2026.
//
import Foundation
import CoreLocation

struct Neighborhood: Identifiable {
    let id = UUID()
    let name: String
    let region: String
    let coordinate: CLLocationCoordinate2D
    let rating: String
    let reviewCount: String = "29"
}

struct NeighborhoodData {
    static let all: [Neighborhood] = [

        // --- أحياء مشهورة ---
        Neighborhood(name: "حطين", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7649, longitude: 46.5983), rating: "4.9"),
        Neighborhood(name: "الملقا", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8246, longitude: 46.6099), rating: "4.8"),
        Neighborhood(name: "الياسمين", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8329, longitude: 46.6462), rating: "4.7"),
        Neighborhood(name: "النرجس", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8626, longitude: 46.6756), rating: "4.6"),
        Neighborhood(name: "العليا", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.6959, longitude: 46.6821), rating: "4.9"),
        Neighborhood(name: "الصحافة", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8124, longitude: 46.6327), rating: "4.7"),
        Neighborhood(name: "العقيق", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7739, longitude: 46.6189), rating: "4.8"),
        Neighborhood(name: "الغدير", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7762, longitude: 46.6547), rating: "4.8"),
        Neighborhood(name: "النخيل", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7488, longitude: 46.6316), rating: "4.9"),
        Neighborhood(name: "حي السفارات", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.6764, longitude: 46.6251), rating: "5.0"),

        // --- أحياء خدمية قوية ---
        Neighborhood(name: "الملز", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.6676, longitude: 46.7377), rating: "4.5"),
        Neighborhood(name: "السليمانية", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.7076, longitude: 46.6947), rating: "4.7"),
        Neighborhood(name: "الورود", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.7237, longitude: 46.6734), rating: "4.6"),
        Neighborhood(name: "الفلاح", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.7901, longitude: 46.7034), rating: "4.6"),
        Neighborhood(name: "الواحة", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.7533, longitude: 46.7107), rating: "4.8"),
        Neighborhood(name: "قرطبة", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.8156, longitude: 46.7346), rating: "4.5"),
        Neighborhood(name: "المونسية", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.8479, longitude: 46.7829), rating: "4.6"),
        Neighborhood(name: "الروضة", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.7249, longitude: 46.7532), rating: "4.4"),
        Neighborhood(name: "النسيم", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.7089, longitude: 46.8341), rating: "4.1"),
        Neighborhood(name: "المنار", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.7219, longitude: 46.8063), rating: "4.2"),

        // --- جنوب وغرب (خدمات عالية) ---
        Neighborhood(name: "الشفاء", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.5496, longitude: 46.7129), rating: "4.0"),
        Neighborhood(name: "العزيزية", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.5897, longitude: 46.7564), rating: "3.7"),
        Neighborhood(name: "الدار البيضاء", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.5318, longitude: 46.8214), rating: "3.8"),
        Neighborhood(name: "المنصورة", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.6124, longitude: 46.7409), rating: "4.1"),
        Neighborhood(name: "بدر", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.5071, longitude: 46.6862), rating: "3.9"),
        Neighborhood(name: "العريجاء", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.6216, longitude: 46.6094), rating: "4.1"),
        Neighborhood(name: "طويق", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.5924, longitude: 46.5286), rating: "4.2"),
        Neighborhood(name: "ظهرة لبن", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.6491, longitude: 46.5387), rating: "4.0"),
        Neighborhood(name: "لبن", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.6374, longitude: 46.5511), rating: "3.9"),
        Neighborhood(name: "المحمدية", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.7326, longitude: 46.6532), rating: "4.8"),

        // --- أحياء صاعدة / اكتشاف ---
        Neighborhood(name: "القيروان", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8732, longitude: 46.5914), rating: "4.5"),
        Neighborhood(name: "العارض", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8964, longitude: 46.6406), rating: "4.2"),
        Neighborhood(name: "الرمال", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.9128, longitude: 46.7923), rating: "4.3"),
        Neighborhood(name: "المهدية", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.7042, longitude: 46.4987), rating: "4.1"),
        Neighborhood(name: "الندى", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8054, longitude: 46.6631), rating: "4.4"),
        Neighborhood(name: "التعاون", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7822, longitude: 46.7041), rating: "4.3"),
        Neighborhood(name: "النفل", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7671, longitude: 46.6872), rating: "4.4"),
        Neighborhood(name: "إشبيلية", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.7916, longitude: 46.8031), rating: "4.2"),
        Neighborhood(name: "النهضة", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.7396, longitude: 46.7794), rating: "4.3"),
        Neighborhood(name: "المروة", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.5642, longitude: 46.7841), rating: "3.8")
    ]
}


