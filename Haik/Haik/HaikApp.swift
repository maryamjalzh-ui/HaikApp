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
    // ربط الـ AppDelegate لضمان عمل Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // --- المتغيرات اللي كانت ناقصة وسببت الأخطاء ---
    @State private var isUserLoggedIn = false
    @State private var hasChecked = false

    init() {
        // إجبار الواجهة على دعم الاتجاه من اليمين لليسار (اللغة العربية)
        UIView.appearance().semanticContentAttribute = .forceRightToLeft
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if !hasChecked {
                    // شاشة بيضاء مؤقتة حتى ينتهي التحقق من حالة المستخدم
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
                // التحقق من حالة تسجيل الدخول فور تشغيل التطبيق
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if Auth.auth().currentUser != nil {
                        isUserLoggedIn = true
                    } else {
                        isUserLoggedIn = false
                    }
                    withAnimation {
                        hasChecked = true
                    }
                }
            }
        }
    }
}
