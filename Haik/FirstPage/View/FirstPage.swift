//
//  WelcomeView.swift
//  Haik
//
//  Created by Maryam Jalal Alzahrani on 23/08/1447 AH.
//

import SwiftUI

struct WelcomeView: View {
    // إضافة متغير الإغلاق للتمكن من العودة عند الضغط على "تخطي"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
             ZStack {                 Color("GreenPrimary")
                    .ignoresSafeArea()
                    .opacity(0.90)
                
                VStack {
                    Spacer()
                    Image("Building")
                        .resizable()
                        .scaledToFit()
                }
                .ignoresSafeArea()

                VStack(spacing: 70) {
                    Spacer()
                    
                    Text("مرحبًا بك في حيّك")
                        .font(.system(size: 28, weight: .bold))
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
                            Text("انشاء حساب جديد")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(30)
                        }

                        // الانتقال لصفحة تسجيل الدخول
                        NavigationLink(destination: LogInPage()) {
                            Text("تسجيل الدخول")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.white, lineWidth: 1.5)
                                )
                        }

                        // زر التخطي (ليس الآن) للعودة للاستكشاف
                        Button(action: {
                            dismiss() // يغلق الصفحة ويعيد المستخدم للخريطة أو تفاصيل الحي
                        }) {
Text("ليس الآن")                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
