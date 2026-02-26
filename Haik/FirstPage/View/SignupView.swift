//
//  SignupView.swift
//  Haik
//
//  Created by Maryam Jalal Alzahrani on 23/08/1447 AH.
//
import SwiftUI

struct SignupView: View {
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
            
            VStack(spacing: 30) {
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
                    .scaledFont(size: 28, weight: .bold, relativeTo: .title1)
                    .foregroundStyle(.primary)
                VStack(alignment: .trailing, spacing: 20) {
                    // حقل الاسم
                    VStack(alignment: .trailing, spacing: 8) {
                        
                        Text("الاسم")
                            .foregroundColor(.secondary)
                            .scaledFont(size: 16, weight: .regular, relativeTo: .callout)

                        
                        TextField("اكتب اسمك هنا", text: $viewModel.name)
                            .padding().background(Color("GreyBackground")).cornerRadius(25)
                            .foregroundStyle(.primary)
                    }

                    // حقل البريد
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("كلمة المرور")
                            .foregroundColor(.secondary)
                            .scaledFont(size: 16, weight: .regular, relativeTo: .callout)
                        TextField("user @gmail.com", text: $viewModel.email)
                            .padding().background(Color("GreyBackground")).cornerRadius(25)
                            .autocapitalization(.none)
                            .foregroundStyle(.primary)
                    }
                    
                    // حقل كلمة المرور
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("كلمة المرور").foregroundColor(.secondary)
                        HStack {
                            Button(action: { viewModel.isPasswordVisible.toggle() }) {
                                Image(systemName: viewModel.isPasswordVisible ? "eye" : "eye.slash").foregroundColor(.secondary)
                            }
                            Spacer()
                            if viewModel.isPasswordVisible {
                                TextField("", text: $viewModel.password).multilineTextAlignment(.trailing)
                            } else {
                                SecureField("**********", text: $viewModel.password).multilineTextAlignment(.trailing)
                            }
                        }
                        .padding().background(Color("GreyBackground")).cornerRadius(25)
                        .foregroundStyle(.primary)
                    }
                    
                    // حقل تأكيد كلمة المرور
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("تأكيد كلمة المرور")
                            .foregroundColor(.secondary)
                            .scaledFont(size: 16, weight: .regular, relativeTo: .callout)
                        HStack {
                            Button(action: { viewModel.isConfirmPasswordVisible.toggle() }) {
                                Image(systemName: viewModel.isConfirmPasswordVisible ? "eye" : "eye.slash").foregroundColor(.secondary)
                            }
                            Spacer()
                            if viewModel.isConfirmPasswordVisible {
                                TextField("", text: $viewModel.confirmPassword).multilineTextAlignment(.trailing)
                            } else {
                                SecureField("**********", text: $viewModel.confirmPassword).multilineTextAlignment(.trailing)
                            }
                        }
                        .padding().background(Color("GreyBackground")).cornerRadius(25)
                        .foregroundStyle(.primary)
                    }
                    
                    if !viewModel.confirmPassword.isEmpty && !viewModel.isPasswordMatching {
                        Text("كلمات المرور غير متطابقة")
                            .scaledFont(size: 13, weight: .regular, relativeTo: .caption1)                            .foregroundColor(.red)
                            .padding(.trailing, 10)
                    }
                }
                .padding(.horizontal, 30)
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage).foregroundColor(.red).scaledFont(size: 13, weight: .regular, relativeTo: .caption1)
                }
                
                Spacer()
                
                Button(action: viewModel.signUp) {
                    Text("انشاء حساب جديد")
                        .scaledFont(size: 18, weight: .bold, relativeTo: .headline)
                        .foregroundColor(Color("PageBackground"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color("Green2Primary"))
                        .opacity(0.80)
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 8)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
#Preview {
    SignupView()
}
