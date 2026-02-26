//
//  CardShadow.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/9/26.
//

import SwiftUI

extension View {
    func cardShadow() -> some View {
        modifier(CardShadowModifier())
    }
}

private struct CardShadowModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    
    func body(content: Content) -> some View {
        content.shadow(
            color: scheme == .dark
                ? Color.black.opacity(DS.shadowOpacity * 1.8)
                : Color.black.opacity(DS.shadowOpacity),
            radius: DS.shadowRadius,
            x: DS.shadowX,
            y: DS.shadowY
        )
    }
}
