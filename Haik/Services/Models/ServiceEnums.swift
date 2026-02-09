//
//  ServiceEnums.swift
//  Haik
//
//  Created by layan Alturki on 09/02/2026.
//

import Foundation

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
        case .restaurants: return "E7CB62"
        case .cinema: return "E7CB62"
        case .cafes: return "673AB7"
        case .universities: return "673AB7"
        case .metro: return "57AFDD"
        case .hospitals: return "57AFDD"
        case .parks: return "0D896E"
        case .libraries: return "0D896E"
        case .schools: return "E7CB62"
        case .gasStations: return "0D896E"
        case .groceries: return "0D896E"
        case .supermarkets: return "673AB7"
        }
    }

    var fallbackSystemSymbol: String? {
        switch self {
        case .gasStations: return "fuelpump"
        default: return nil
        }
    }
}
