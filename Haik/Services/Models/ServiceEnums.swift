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
    case mall = "مركز تجاري"
    case parks = "الحدائق"
    case libraries = "المكتبات"
    case metro = "مترو"

    var id: String { rawValue }

    var icon: HaikIcon {
        switch self {
        case .parks: return .calm
        case .cinema: return .entertainment
        case .schools: return .schools
        case .mall: return .mall
        case .metro: return .metroPrimary
        case .groceries, .supermarkets: return .fullServices
        case .cafes: return .cafes
        default: return .services
        }
    }

 

    var fallbackSystemSymbol: String? {
        switch self {
        case .gasStations: return "fuelpump"
        case .libraries:return "books.vertical"
        case .hospitals:return "stethoscope"
        default: return nil
        }
    }
}



