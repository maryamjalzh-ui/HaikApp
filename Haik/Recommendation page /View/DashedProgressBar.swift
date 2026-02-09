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
        HStack(spacing: 12) {
            ForEach(1...total, id: \.self) { step in
                let isFilled = step <= current

                RoundedRectangle(cornerRadius: DS.progressCornerRadius, style: .continuous)
                    .fill(isFilled ? Color("Green2Primary") : .white)
                    .frame(width: DS.progressWidth, height: DS.progressHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.progressCornerRadius, style: .continuous)
                            .stroke(Color("Green2Primary"), lineWidth: 1)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, 18)
    }
}
