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
    
   

    var body: some Scene {
        WindowGroup {
            // الدخول مباشرة لصفحة الـ HomeScreen
            HomeScreen()
                
        }
    }
}
