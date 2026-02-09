//
//  OptionCardButton.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/8/26.
//

import SwiftUI

struct OptionCardButton: View {

    let title: String
    let icon: HaikIcon
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DS.cardCornerRadius, style: .continuous)
                .fill(isSelected ? Color("Green2Primary").opacity(0.14) : .white)
                .cardShadow()

            HStack(spacing: 12) {
                Image(systemName: icon.systemName)
                    .font(.system(size: DS.iconSize, weight: DS.iconWeight))
                    .foregroundColor(DS.iconColor)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(height: DS.cardHeight)
        .contentShape(RoundedRectangle(cornerRadius: DS.cardCornerRadius, style: .continuous))
        .onTapGesture {
            onTap()
        }
    }
}
