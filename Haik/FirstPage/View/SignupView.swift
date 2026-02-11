//
//  SignupView.swift
//  Haik
//
//  Created by Maryam Jalal Alzahrani on 23/08/1447 AH.
//

import SwiftUI

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
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
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("البريد الإلكتروني").foregroundColor(.gray)
                        TextField("user@gmail.com", text: $email)
                            .padding().background(Color(white: 0.92)).cornerRadius(25)
                    }
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("كلمة المرور").foregroundColor(.gray)
                        HStack {
                            Button(action: { isPasswordVisible.toggle() }) {
                                Image(systemName: isPasswordVisible ? "eye" : "eye.slash").foregroundColor(.gray)
                            }
                            Spacer()
                            if isPasswordVisible {
                                TextField("", text: $password).multilineTextAlignment(.trailing)
                            } else {
                                SecureField("", text: $password).multilineTextAlignment(.trailing)
                            }
                        }
                        .padding().background(Color(white: 0.92)).cornerRadius(25)
                    }
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("تأكيد كلمة المرور").foregroundColor(.gray)
                        HStack {
                            Button(action: { isConfirmPasswordVisible.toggle() }) {
                                Image(systemName: isConfirmPasswordVisible ? "eye" : "eye.slash").foregroundColor(.gray)
                            }
                            Spacer()
                            if isConfirmPasswordVisible {
                                TextField("", text: $confirmPassword).multilineTextAlignment(.trailing)
                            } else {
                                SecureField("", text: $confirmPassword).multilineTextAlignment(.trailing)
                            }
                        }
                        .padding().background(Color(white: 0.92)).cornerRadius(25)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                Button(action: { print("إنشاء حساب...") }) {
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
