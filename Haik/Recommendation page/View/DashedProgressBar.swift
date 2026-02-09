//
//  DashedProgressBar.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/8/26.
//

import SwiftUI

struct DashedProgressBar: View {

    let total: Int
    let current: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<total, id: \.self) { index in

                let isFilled = index >= (total - current)

                Capsule()
                    .fill(isFilled ? Color("Green2Primary") : Color.clear)
                    .frame(height: 6)
                    .overlay(
                        Capsule()
                            .stroke(Color("Green2Primary"), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 18)
    }
}
