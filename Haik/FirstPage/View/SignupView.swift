//
//  SignupView.swift
//  Haik
//
//  Created by Maryam Jalal Alzahrani on 23/08/1447 AH.
//
import SwiftUI


struct SignupView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            // الخلفية
            VStack {
                Spacer()
                Image("Building").resizable().scaledToFit()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("مرحبًا بك في حيك")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top, 40)
                
                VStack(alignment: .trailing, spacing: 20) {
                    // حقل الاسم
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("الاسم").foregroundColor(.gray)
                        TextField("اكتب اسمك هنا", text: $viewModel.name)
                            .padding().background(Color(white: 0.92)).cornerRadius(25)
                    }

                    // حقل البريد
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("البريد الإلكتروني").foregroundColor(.gray)
                        TextField("user@gmail.com", text: $viewModel.email)
                            .padding().background(Color(white: 0.92)).cornerRadius(25)
                            .autocapitalization(.none)
                    }
                    
                    // حقل كلمة المرور
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("كلمة المرور").foregroundColor(.gray)
                        HStack {
                            Button(action: { viewModel.isPasswordVisible.toggle() }) {
                                Image(systemName: viewModel.isPasswordVisible ? "eye" : "eye.slash").foregroundColor(.gray)
                            }
                            Spacer()
                            if viewModel.isPasswordVisible {
                                TextField("", text: $viewModel.password).multilineTextAlignment(.trailing)
                            } else {
                                SecureField("", text: $viewModel.password).multilineTextAlignment(.trailing)
                            }
                        }
                        .padding().background(Color(white: 0.92)).cornerRadius(25)
                    }
                    
                    // حقل تأكيد كلمة المرور
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("تأكيد كلمة المرور").foregroundColor(.gray)
                        HStack {
                            Button(action: { viewModel.isConfirmPasswordVisible.toggle() }) {
                                Image(systemName: viewModel.isConfirmPasswordVisible ? "eye" : "eye.slash").foregroundColor(.gray)
                            }
                            Spacer()
                            if viewModel.isConfirmPasswordVisible {
                                TextField("", text: $viewModel.confirmPassword).multilineTextAlignment(.trailing)
                            } else {
                                SecureField("", text: $viewModel.confirmPassword).multilineTextAlignment(.trailing)
                            }
                        }
                        .padding().background(Color(white: 0.92)).cornerRadius(25)
                    }
                    if !viewModel.confirmPassword.isEmpty && !viewModel.isPasswordMatching {
                        Text("كلمات المرور غير متطابقة")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.trailing, 10)
                    }
                    
                }
                .padding(.horizontal, 30)
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage).foregroundColor(.red).font(.caption)
                }
                
                Spacer()
                
                Button(action: viewModel.signUp) {
                    Text("انشاء حساب جديد")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(30)
                        .shadow(color: Color("GreenPrimary").opacity(0.90), radius: 1, x: 1, y: 3)
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.black.opacity(0.05), lineWidth: 0.5))
                }
                .padding(.horizontal, 40).padding(.bottom, 40)
            }
        }
    }
}
#Preview {
    SignupView()
}
