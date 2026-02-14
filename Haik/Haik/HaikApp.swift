//
//  HaikApp.swift
//  Haik
//
//  Created by lamess on 04/02/2026.
//

import SwiftUI

@main
struct HaikApp: App {
    init() {
          UIView.appearance().semanticContentAttribute = .forceRightToLeft
      }
    var body: some Scene {
        WindowGroup {
            HomeScreen()
        }
    }
}
