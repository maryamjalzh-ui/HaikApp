//  LogInPage.swift
//  Haik
//
//  Created by Maryam Jalal Alzahrani on 23/08/1447 AH.
//
import SwiftUI
import Firebase
import FirebaseAuth

struct LogInPage: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color("PageBackground").ignoresSafeArea()
            VStack {
                Spacer()
                Image("Building").resizable().scaledToFit()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // هيدر يحتوي على زر العودة جهة اليمين
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.forward")
                            .scaledFont(size: 18, weight: .bold, relativeTo: .headline)                            .foregroundColor(Color("GreenPrimary"))
                            .frame(width: 45, height: 45)
                            .background(Color("GreyBackground"))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                Text("مرحبًا بك في حيّك")
                    .scaledFont(size: 28, weight: .bold, relativeTo: .title1)                    .padding(.top, 20)
                    .foregroundStyle(.primary)
                
                VStack(alignment: .trailing, spacing: 25) {
                    // حقل الإيميل
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("البريد الإلكتروني")
                            .foregroundColor(.secondary)
                            .scaledFont(size: 16, weight: .regular, relativeTo: .callout)
                            
                            
                            
                           
                        TextField("user @gmail.com", text: $viewModel.loginEmail)
                            .padding().background(Color("GreyBackground")).cornerRadius(25)
                            .autocapitalization(.none)
                            .foregroundStyle(.primary)
                    }
                    
                    // حقل كلمة المرور
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("كلمة المرور")
                            .foregroundColor(.secondary)
                            .scaledFont(size: 16, weight: .regular, relativeTo: .callout)
                        HStack {
                            Button(action: { viewModel.isPasswordVisible.toggle() }) {
                                Image(systemName: viewModel.isPasswordVisible ? "eye" : "eye.slash").foregroundColor(.secondary)
                            }
                            Spacer()
                            if viewModel.isPasswordVisible {
                                TextField("", text: $viewModel.loginPassword).multilineTextAlignment(.trailing)
                            } else {
                                SecureField("", text: $viewModel.loginPassword).multilineTextAlignment(.trailing)
                            }
                        }
                        .padding().background(Color("GreyBackground")).cornerRadius(25)
                        .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal, 30)
                
                if !viewModel.loginError.isEmpty {
                    Text(viewModel.loginError).foregroundColor(.red).scaledFont(size: 13, weight: .regular, relativeTo: .caption1)
                }
                
                Spacer()
                
                Button(action: viewModel.login) {
                    Text("تسجيل الدخول")
                        .scaledFont(size: 18, weight: .bold, relativeTo: .headline)
                        .foregroundColor(Color("PageBackground"))
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
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $viewModel.isLoginSuccess) {
            HomeScreen()
        }
    }
}
#Preview {
    LogInPage()
}
