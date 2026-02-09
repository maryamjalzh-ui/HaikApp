//
//  ServiceEnums.swift
//  Haik
//
//  Created by layan Alturki on 09/02/2026.
//
import Foundation
import SwiftUI

enum ServiceCategory: String, CaseIterable, Identifiable {
    case hospitals = "مستشفيات"
    case groceries = "تموينات"
    case schools = "مدارس"
    case gasStations = "محطات بنزين"
    case cinema = "السينما"
    case cafes = "مقاهي"
    case restaurants = "المطاعم"
    case supermarkets = "سوبرماركت"
    case universities = "جامعات"
    case parks = "الحدائق"
    case libraries = "المكتبات"
    case metro = "مترو"

    var id: String { rawValue }

    var mapsQuery: String {
        switch self {
        case .groceries: return "بقالة"
        case .supermarkets: return "سوبرماركت"
        case .restaurants: return "مطعم"
        case .cafes: return "مقهى"
        case .hospitals: return "مستشفى"
        case .schools: return "مدرسة"
        case .universities: return "جامعة"
        case .parks: return "حديقة"
        case .libraries: return "مكتبة"
        case .cinema: return "سينما"
        case .gasStations: return "محطة وقود"
        case .metro: return "محطة مترو"
        }
    }

    var icon: HaikIcon {
        switch self {
        case .parks: return .calm
        case .cinema: return .entertainment
        case .schools: return .schools
        case .universities: return .universities
        case .metro: return .metroPrimary
        case .groceries, .supermarkets: return .fullServices
        default: return .services
        }
    }

    var iconHexColor: String {
        switch self {
        case .restaurants, .cinema, .schools: return "E7CB62"
        case .cafes, .universities, .supermarkets: return "673AB7"
        case .metro, .hospitals: return "57AFDD"
        case .parks, .libraries, .gasStations, .groceries: return "0D896E"
        }
    }

    var fallbackSystemSymbol: String? {
        switch self {
        case .gasStations:
            return "fuelpump"
        default:
            return nil
        }
    }

    var systemIconName: String {
        if let fallbackSystemSymbol { return fallbackSystemSymbol }
        return "mappin.and.ellipse"
    }

    func iconColor() -> Color {
        Color(hex: iconHexColor)
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}
