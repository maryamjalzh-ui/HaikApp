//
//  Shadow.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/8/26.
//

import SwiftUI

extension View {
    func cardShadow() -> some View {
        self.shadow(
            color: Color.black.opacity(0.25),
            radius: DS.shadowRadius,
            x: DS.shadowX,
            y: DS.shadowY
        )
    }
}
