//
//  WelcomeView.swift
//  Haik
//
//  Created by Maryam Jalal Alzahrani on 23/08/1447 AH.
//

import SwiftUI

struct WelcomeView: View {
    // متغير الإغلاق للعودة عند الضغط على "تخطي"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color("GreenPrimary")
                    .ignoresSafeArea()
                    .opacity(0.90)
                
                VStack {
                    Spacer()
                    Image("Building")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                }
                .ignoresSafeArea()

                VStack(spacing: 70) {
                    Spacer()
                    
                    // استخدام مفتاح الترجمة للعنوان
                    Text(String(localized: "welcome_title"))
                        .scaledFont(size: 28, weight: .bold, relativeTo: .title1)
                        .foregroundColor(.white)
                    
                    Image("FirstPageLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 253, height: 238)
                        .blendMode(.colorBurn)
                        .opacity(0.90)
                       
                    Spacer()
                    
                    VStack(spacing: 16) {
                        // الانتقال لصفحة إنشاء حساب
                        NavigationLink(destination: SignupView()) {
                            Text(String(localized: "signup_button"))
                                .scaledFont(size: 17, weight: .semibold, relativeTo: .headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(30)
                        }

                        // الانتقال لصفحة تسجيل الدخول
                        NavigationLink(destination: LogInPage()) {
                            Text(String(localized: "login_button"))
                                .scaledFont(size: 17, weight: .semibold, relativeTo: .headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.white, lineWidth: 1.5)
                                )
                        }

                        // زر التخطي (ليس الآن)
                        Button(action: {
                            dismiss()
                        }) {
                            Text(String(localized: "not_now_button"))
                                .scaledFont(size: 16, weight: .medium, relativeTo: .body)
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
