//
//  CardShadow.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/9/26.
//

import SwiftUI

extension View {
    func cardShadow() -> some View {
        self.shadow(
            color: Color.black.opacity(DS.shadowOpacity),
            radius: DS.shadowRadius,
            x: DS.shadowX,
            y: DS.shadowY
        )
    }
}
