//
//  LogInPage.swift
//  Haik
//
//  Created by Maryam Jalal Alzahrani on 23/08/1447 AH.
//
import SwiftUI
import Firebase // استيراد فايربيس
import FirebaseAuth


struct LogInPage: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack {
                Spacer()
                Image("Building").resizable().scaledToFit()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("مرحبًا بك في حيك")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top, 50)
                
                VStack(alignment: .trailing, spacing: 25) {
                    // حقل الإيميل مربوط بالـ ViewModel
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("البريد الإلكتروني").foregroundColor(.gray).font(.callout)
                        TextField("user@gmail.com", text: $viewModel.loginEmail)
                            .padding().background(Color(white: 0.94)).cornerRadius(25)
                            .autocapitalization(.none)
                    }
                    
                    // حقل الباسورد مربوط بالـ ViewModel
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("كلمة المرور").foregroundColor(.gray).font(.callout)
                        HStack {
                            Button(action: { viewModel.isPasswordVisible.toggle() }) {
                                Image(systemName: viewModel.isPasswordVisible ? "eye" : "eye.slash").foregroundColor(.gray)
                            }
                            Spacer()
                            if viewModel.isPasswordVisible {
                                TextField("", text: $viewModel.loginPassword).multilineTextAlignment(.trailing)
                            } else {
                                SecureField("", text: $viewModel.loginPassword).multilineTextAlignment(.trailing)
                            }
                        }
                        .padding().background(Color(white: 0.94)).cornerRadius(25)
                    }
                }
                .padding(.horizontal, 30)
                
                // عرض الخطأ من الـ ViewModel
                if !viewModel.loginError.isEmpty {
                    Text(viewModel.loginError).foregroundColor(.red).font(.caption)
                }
                
                Spacer()
                
                // زر الأكشن ينادي الدالة من الـ ViewModel مباشرة
                Button(action: viewModel.login) {
                    Text("تسجيل الدخول")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color("Green2Primary"))
                        .opacity(0.80)
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 8)
                }
                .padding(.horizontal, 40).padding(.bottom, 60)
            }
        }// --- الرابط الجديد هنا ---
        .fullScreenCover(isPresented: $viewModel.isLoginSuccess) {
            HomeScreen() // الانتقال لصفحة الخريطة عند النجاح
        }
    }
}
#Preview {
    LogInPage()
}
