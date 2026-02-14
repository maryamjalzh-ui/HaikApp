//
//  HaikApp.swift
//  Haik
//
//  Created by lamess on 04/02/2026.
//
import SwiftUI
import FirebaseCore
import FirebaseAuth
import UIKit
// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// MARK: - Main App
@main
struct HaikApp: App {
    init() {
          UIView.appearance().semanticContentAttribute = .forceRightToLeft
      }
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !hasChecked {
                    // شاشة بيضاء مؤقتة بدل السوداء حتى ينتهي التحقق
                    Color.white.ignoresSafeArea()
                } else {
                    if isUserLoggedIn {
                        HomeScreen()
                    } else {
                        WelcomeView()
                    }
                }
            }
            .onAppear {
                // نتحقق من الحساب فور تشغيل الواجهة
                DispatchQueue.main.async {
                    if Auth.auth().currentUser != nil {
                        isUserLoggedIn = true
                    } else {
                        isUserLoggedIn = false
                    }
                    hasChecked = true
                }
            }
        }
    }
}
