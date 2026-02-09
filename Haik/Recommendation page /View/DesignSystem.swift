//
//  DesignSystem.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/8/26.
//

import SwiftUI

enum DS {
    static let cardCornerRadius: CGFloat = 24
    static let cardHeight: CGFloat = 69
    static let cardSpacing: CGFloat = 30

    static let selectedFillOpacity: Double = 0.15

    static let shadowRadius: CGFloat = 10
    static let shadowX: CGFloat = 0
    static let shadowY: CGFloat = 6
    static let shadowOpacity: Double = 0.12


    static let progressWidth: CGFloat = 75
    static let progressHeight: CGFloat = 12
    static let progressCornerRadius: CGFloat = 24

    static let iconSize: CGFloat = 18
    static let iconWeight: Font.Weight = .semibold
    static let iconColor: Color = Color("Green2Primary")
    
    static let autoNextDelaySingle: UInt64 = 900_000_000
    static let autoNextDelayMultiAfterConfirm: UInt64 = 450_000_000
    static let scrollToExpandedDelay: TimeInterval = 0.06
    static let scrollAnimationDuration: Double = 0.25
    static let expandCollapseAnimationDuration: Double = 0.18
    static let quickNextAnimationDuration: Double = 0.10
    static let selectionAnimationDuration: Double = 0.12

}
