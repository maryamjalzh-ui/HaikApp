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
    let nameAr: String
    let nameEn: String
    let region: String
    let coordinate: CLLocationCoordinate2D
    var rating: String = "0.0"
    var reviewCount: String = "0"
    var additionalAliases: [String] = [] // نغير اسم القديم لنتجنب الخلط

    // هذا هو السر: ندمج الاسم العربي مع أي أسماء إضافية لضمان وصوله للخدمة
    var aliases: [String] {
        return [nameAr, nameEn] + additionalAliases
    }

    var name: String {
        let currentLang = Locale.current.language.languageCode?.identifier ?? "ar"
        return currentLang == "en" ? nameEn : nameAr
    }
}

struct NeighborhoodData {
    static let all: [Neighborhood] = [
        // --- أحياء مشهورة ---
        Neighborhood(nameAr: "حطين", nameEn: "Hittin", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7649, longitude: 46.5983)),
        Neighborhood(nameAr: "الملقا", nameEn: "Al Malqa", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8246, longitude: 46.6099)),
        Neighborhood(nameAr: "الياسمين", nameEn: "Al Yasmin", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8329, longitude: 46.6462)),
        Neighborhood(nameAr: "النرجس", nameEn: "An Narjis", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8626, longitude: 46.6756)),
        Neighborhood(nameAr: "العليا", nameEn: "Al Olaya", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.6959, longitude: 46.6821)),
        Neighborhood(nameAr: "الصحافة", nameEn: "As Sahafah", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8124, longitude: 46.6327)),
        Neighborhood(nameAr: "العقيق", nameEn: "Al Aqiq", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7739, longitude: 46.6189)),
        Neighborhood(nameAr: "الغدير", nameEn: "Al Ghadir", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7762, longitude: 46.6547)),
        Neighborhood(nameAr: "النخيل", nameEn: "An Nakheel", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7488, longitude: 46.6316)),
        Neighborhood(nameAr: "السفارات", nameEn: "Diplomatic Quarter", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.6764, longitude: 46.6251)),

        // --- أحياء خدمية قوية ---
        Neighborhood(nameAr: "الملز", nameEn: "Al Malaz", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.6676, longitude: 46.7377)),
        Neighborhood(nameAr: "السليمانية", nameEn: "As Sulimaniyah", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.7076, longitude: 46.6947)),
        Neighborhood(nameAr: "الورود", nameEn: "Al Wurud", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.7237, longitude: 46.6734)),
        Neighborhood(nameAr: "الفلاح", nameEn: "Al Falah", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.7901, longitude: 46.7034)),
        Neighborhood(nameAr: "الملك سلمان", nameEn: "King Salman", region: "وسط", coordinate: CLLocationCoordinate2D(latitude: 24.7533, longitude: 46.7107), additionalAliases: ["الواحة"]),
        Neighborhood(nameAr: "قرطبة", nameEn: "Qurtubah", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.8156, longitude: 46.7346)),
        Neighborhood(nameAr: "المونسية", nameEn: "Al Munsiyah", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.8479, longitude: 46.7829)),
        Neighborhood(nameAr: "الروضة", nameEn: "Ar Rawdah", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.7249, longitude: 46.7532)),
        Neighborhood(nameAr: "النسيم", nameEn: "An Naseem", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.7089, longitude: 46.8341)),
        Neighborhood(nameAr: "المنار", nameEn: "Al Manar", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.7219, longitude: 46.8063)),

        // --- جنوب وغرب ---
        Neighborhood(nameAr: "الشفاء", nameEn: "Ash Shifa", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.5496, longitude: 46.7129)),
        Neighborhood(nameAr: "العزيزية", nameEn: "Al Aziziyah", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.5897, longitude: 46.7564)),
        Neighborhood(nameAr: "الدار البيضاء", nameEn: "Ad Dar Al Baida", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.5318, longitude: 46.8214)),
        Neighborhood(nameAr: "المنصورة", nameEn: "Al Mansurah", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.6124, longitude: 46.7409)),
        Neighborhood(nameAr: "بدر", nameEn: "Badr", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.5071, longitude: 46.6862)),
        Neighborhood(nameAr: "العريجاء", nameEn: "Al Urayja", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.6216, longitude: 46.6094)),
        Neighborhood(nameAr: "طويق", nameEn: "Tuwaiq", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.5924, longitude: 46.5286)),
        Neighborhood(nameAr: "لبن", nameEn: "Laban", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.6374, longitude: 46.5511)),
        Neighborhood(nameAr: "المحمدية", nameEn: "Al Muhammadiyah", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.7326, longitude: 46.6532)),

        // --- أحياء صاعدة ---
        Neighborhood(nameAr: "القيروان", nameEn: "Al Qayrawan", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8732, longitude: 46.5914)),
        Neighborhood(nameAr: "العارض", nameEn: "Al Arid", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8964, longitude: 46.6406)),
        Neighborhood(nameAr: "الرمال", nameEn: "Ar Rimal", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.9128, longitude: 46.7923)),
        Neighborhood(nameAr: "المهدية", nameEn: "Al Mahdiyah", region: "غرب", coordinate: CLLocationCoordinate2D(latitude: 24.7042, longitude: 46.4987)),
        Neighborhood(nameAr: "الندى", nameEn: "An Nada", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.8054, longitude: 46.6631)),
        Neighborhood(nameAr: "التعاون", nameEn: "At Taawun", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7822, longitude: 46.7041)),
        Neighborhood(nameAr: "النفل", nameEn: "An Nafl", region: "شمال", coordinate: CLLocationCoordinate2D(latitude: 24.7671, longitude: 46.6872)),
        Neighborhood(nameAr: "إشبيلية", nameEn: "Ishbiliah", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.7916, longitude: 46.8031)),
        Neighborhood(nameAr: "النهضة", nameEn: "An Nahdah", region: "شرق", coordinate: CLLocationCoordinate2D(latitude: 24.7396, longitude: 46.7794)),
        Neighborhood(nameAr: "المروة", nameEn: "Al Marwah", region: "جنوب", coordinate: CLLocationCoordinate2D(latitude: 24.5642, longitude: 46.7841))
    ]
}
