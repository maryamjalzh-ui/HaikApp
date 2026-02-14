//
//  RiyadhAvgPriceService.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/15/26.
//

import Foundation

struct NeighborhoodAvgRecord: Codable, Hashable {
    let neighborhood: String
    let avgPricePerMeter: Double?
    let transactionsCount: Int
}

final class RiyadhAvgPriceService {

    static let shared = RiyadhAvgPriceService()

    private(set) var records: [NeighborhoodAvgRecord] = []
    private var lookup: [String: NeighborhoodAvgRecord] = [:]

    private init() {
        loadFromBundle()
    }

    private func loadFromBundle() {
        guard let url = Bundle.main.url(forResource: "riyadh_avg", withExtension: "json") else {
            print("riyadh_avg.json not found in Bundle.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([NeighborhoodAvgRecord].self, from: data)
            self.records = decoded

            var dict: [String: NeighborhoodAvgRecord] = [:]
            for r in decoded {
                dict[normalize(r.neighborhood)] = r
            }

            if let embassies = dict[normalize("السفارات")] {
                dict[normalize("حي السفارات")] = embassies
            }
            self.lookup = dict

        } catch {
            print("Failed to decode riyadh_avg.json: \(error)")
        }
    }

    func record(for neighborhoodName: String, aliases: [String] = []) -> NeighborhoodAvgRecord? {
        if let r = lookup[normalize(neighborhoodName)] { return r }

        for a in aliases {
            if let r = lookup[normalize(a)] { return r }
        }

        let withHay = "حي \(neighborhoodName)"
        if let r = lookup[normalize(withHay)] { return r }

        return nil
    }

    func avgPricePerMeter(for neighborhoodName: String, aliases: [String] = []) -> Double? {
        record(for: neighborhoodName, aliases: aliases)?.avgPricePerMeter
    }

    func transactionsCount(for neighborhoodName: String, aliases: [String] = []) -> Int? {
        record(for: neighborhoodName, aliases: aliases)?.transactionsCount
    }

    private func normalize(_ input: String) -> String {
        var s = input.trimmingCharacters(in: .whitespacesAndNewlines)

        s = s.replacingOccurrences(of: "أ", with: "ا")
        s = s.replacingOccurrences(of: "إ", with: "ا")
        s = s.replacingOccurrences(of: "آ", with: "ا")
        s = s.replacingOccurrences(of: "ى", with: "ي")
        s = s.replacingOccurrences(of: "ة", with: "ه")

        s = s.replacingOccurrences(of: "حي ", with: "")
        s = s.replacingOccurrences(of: "حي", with: "")

        s = s.trimmingCharacters(in: .whitespacesAndNewlines)

        s = s.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")

        return s
    }
}
