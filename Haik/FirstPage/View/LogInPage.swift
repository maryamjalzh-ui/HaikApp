//
//  LogInPage.swift
//  Haik
//
//  Created by Maryam Jalal Alzahrani on 23/08/1447 AH.
//
import SwiftUI

struct LogInPage: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    
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
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("البريد الإلكتروني").foregroundColor(.gray).font(.callout)
                        TextField("user@gmail.com", text: $email)
                            .padding().background(Color(white: 0.94)).cornerRadius(25)
                    }
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("كلمة المرور").foregroundColor(.gray).font(.callout)
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
                        .padding().background(Color(white: 0.94)).cornerRadius(25)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                Button(action: { print("تسجيل دخول...") }) {
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
        }
    }
}
#Preview {
    LogInPage()
}
