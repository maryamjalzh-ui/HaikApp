//
//  Font.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/25/26.
//

import SwiftUI
import UIKit

private extension UIFont.Weight {
    static func from(_ w: Font.Weight) -> UIFont.Weight {
        switch w {
        case .ultraLight: return .ultraLight
        case .thin:       return .thin
        case .light:      return .light
        case .regular:    return .regular
        case .medium:     return .medium
        case .semibold:   return .semibold
        case .bold:       return .bold
        case .heavy:      return .heavy
        case .black:      return .black
        default:          return .regular
        }
    }
}

private struct ScaledFontModifier: ViewModifier {
    let size: CGFloat
    let weight: Font.Weight
    let textStyle: UIFont.TextStyle

    func body(content: Content) -> some View {
        let base = UIFont.systemFont(ofSize: size, weight: .from(weight))
        let scaled = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base)
        return content.font(Font(scaled))
    }
}

extension View {
    func scaledFont(
        size: CGFloat,
        weight: Font.Weight = .regular,
        relativeTo textStyle: UIFont.TextStyle = .body
    ) -> some View {
        modifier(ScaledFontModifier(size: size, weight: weight, textStyle: textStyle))
    }
}
