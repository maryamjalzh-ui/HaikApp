//
//  AvgPriceBadgeView.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/15/26.
//


import SwiftUI

struct AvgPriceBadgeView: View {

    let neighborhoodName: String
    let aliases: [String]

    private let primaryColor = Color("Green2Primary")
    private let hintGray = Color(hex: "ACACAC")
    private let borderGray = Color(hex: "DBDBDB")

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {

            HStack {
                Text("متوسط سعر المتر")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.black)

                Spacer()

                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(primaryColor)
            }

            HStack(spacing: 10) {
                priceChip(value: avgText)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(borderGray, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 8)
    }

    private var avgText: String {
        let service = RiyadhAvgPriceService.shared

        guard let avg = service.avgPricePerMeter(for: neighborhoodName, aliases: aliases) else {
            return "غير متوفر"
        }

        return format(avg)
    }

    private func priceChip(value: String) -> some View {
        HStack(spacing: 6) {

            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(primaryColor)

            Text("ر.س / م²")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(hintGray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }

    private func format(_ value: Double) -> String {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "ar_SA")
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 0
        nf.minimumFractionDigits = 0
        return nf.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
}

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
