//
//  OptionCardButton.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/8/26.
//

import SwiftUI

struct OptionCardButton: View {

    let title: String
    let sfSymbol: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {

            HStack(spacing: 12) {
                Spacer(minLength: 0)

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Image(systemName: sfSymbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("Green2Primary"))
            }
            .padding(.horizontal, 16)
            .frame(height: DS.cardHeight)
            .background(
                RoundedRectangle(cornerRadius: DS.cardCornerRadius, style: .continuous)
                    .fill(
                        isSelected
                        ? Color("Green2Primary").opacity(DS.selectedFillOpacity)
                        : .white
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.cardCornerRadius, style: .continuous)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
            .cardShadow()
        }
        .buttonStyle(.plain)
    }
}
