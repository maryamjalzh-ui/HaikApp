//
//  ServiceEnums.swift
//  Haik
//
//  Created by layan Alturki on 09/02/2026.
//

import Foundation

enum ServiceCategory: String, CaseIterable, Identifiable {
    case hospitals = "hospitals"
    case groceries = "groceries"
    case schools = "schools"
    case gasStations = "gas_stations"
    case cinema = "cinema"
    case cafes = "cafes"
    case restaurants = "restaurants"
    case supermarkets = "supermarkets"
    case mall = "mall"
    case parks = "parks"
    case libraries = "libraries"
    case metro = "metro"
    
    var id: String { rawValue }

    var icon: HaikIcon {
        switch self {
        case .parks: return .calm
        case .cinema: return .entertainment
        case .schools: return .schools
        case .mall: return .mall
        case .metro: return .metroPrimary
        case .supermarkets: return .services      
         case .groceries: return .fullServices
        case .cafes: return .cafes
        case .restaurants: return .restaurants
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



