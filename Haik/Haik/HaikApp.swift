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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // تم إزالة متغيرات الحالة التي كانت تجبر المستخدم على تسجيل الدخول
    // ليفتح التطبيق مباشرة على HomeScreen للجميع (ضيف ومسجل)

    init() {
        UIView.appearance().semanticContentAttribute = .forceRightToLeft
    }

    var body: some Scene {
        WindowGroup {
            // الدخول مباشرة لصفحة الـ HomeScreen
            HomeScreen()
                .environment(\.layoutDirection, .rightToLeft)
                
        }
    }
}
