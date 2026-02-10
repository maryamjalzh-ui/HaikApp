//
//  NeighborhoodComputingView.swift
//  Haik
//
//  Created by Bayan Alshehri on 22/08/1447 AH.
//

import SwiftUI

struct NeighborhoodComputingView: View {

    let progress: Double // 0...1

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .frame(width: 260)

            Text("جاري حساب أفضل الأحياء لك…")
                .font(.system(size: 18, weight: .semibold))

            Text("\(Int(progress * 100))%")
                .font(.system(size: 14))
                .foregroundStyle(.gray)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("GreyBackground"))
        .environment(\.layoutDirection, .rightToLeft)
    }
}
