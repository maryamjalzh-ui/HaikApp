//
//  AuthViewModel.swift
//  Haik
//
//  Created by lamess on 13/02/2026.
//

import Combine
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    // MARK: - Signup Properties
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var isPasswordVisible = false
    @Published var isConfirmPasswordVisible = false
    @Published var errorMessage = ""
    
    @Published var loginEmail = ""
        @Published var loginPassword = ""
        @Published var loginError = ""
        @Published var isLoginSuccess = false
    // Mark
    func login() {
        Auth.auth().signIn(withEmail: loginEmail, password: loginPassword) { result, error in
            if let error = error {
                self.loginError = "تأكد من البريد أو كلمة المرور"
            } else {
                // التحقق هل أكد الإيميل أم لا؟
                if let user = result?.user, user.isEmailVerified {
                    self.loginError = ""
                    self.isLoginSuccess = true
                } else {
                    self.loginError = "يرجى تأكيد حسابك من البريد الإلكتروني أولاً"
                    try? Auth.auth().signOut() // نخرجه حتى يفعل الحساب
                }
            }
        }
    }
    
    // داخل AuthViewModel
    var isPasswordMatching: Bool {
        !confirmPassword.isEmpty && password == confirmPassword
    }
    func signUp() {
        // 1. التأكد من التطابق قبل البدء
        guard isPasswordMatching else {
            self.errorMessage = "يرجى التأكد من تطابق كلمات المرور"
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            // 2. إرسال رابط تأكيد الإيميل (تحسين UX)
            authResult?.user.sendEmailVerification { error in
                if error == nil {
                    self.errorMessage = "تم إرسال رابط التحقق، يرجى تفعيل حسابك من البريد الإلكتروني ثم سجل دخولك."
                    
                    // 3. تسجيل الخروج لإجباره على تسجيل الدخول مرة أخرى
                    try? Auth.auth().signOut()
                }
            }

            // حفظ بيانات المستخدم الأساسية في Firestore كالمعتاد
            let uid = authResult?.user.uid ?? ""
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "id": uid,
                "name": self.name,
                "email": self.email,
                "favoriteNeighborhoods": []
            ]
            db.collection("users").document(uid).setData(userData)
        }
    }
}
