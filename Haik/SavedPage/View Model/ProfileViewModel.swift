//
//  ProfileViewModel.swift
//  Haik
//
//  Created by lamess on 14/02/2026.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ProfileViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userComments: [UserComment] = []
    @Published var savedNeighborhoodNames: [String] = []

  
    private let db = Firestore.firestore()
    
    init() {
        fetchUserData()
        fetchUserComments()
    }
    
    // جلب بيانات المستخدم كاملة (بما فيها الأحياء المحفوظة)
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).addSnapshotListener { snapshot, _ in
            if let data = snapshot?.data() {
                DispatchQueue.main.async {
                    self.userName = data["name"] as? String ?? "مستخدم جديد"
                    self.userEmail = data["email"] as? String ?? ""
                    
                    // جلب مصفوفة الأحياء المحفوظة حقيقياً من Firebase
                    if let favorites = data["favoriteNeighborhoods"] as? [String] {
                        self.savedNeighborhoodNames = favorites
                    }
                }
            }
        }
    }
    
    // جلب كل التعليقات التي كتبها هذا المستخدم فقط
    func fetchUserComments() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("neighborhood_reviews")
            .whereField("userId", isEqualTo: uid)
            .addSnapshotListener { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                
                self.userComments = documents.map { doc in
                    let data = doc.data()
                    return UserComment(
                        id: UUID(), // للتوافق مع Identifiable
                        text: data["comment"] as? String ?? "",
                        rating: Double(data["rating"] as? Int ?? 0),
                        neighborhoodName: data["neighborhoodName"] as? String ?? "حي مجهول"
                    )
                }
            }
    }
    struct UserComment: Identifiable {
        let id: UUID
        var text: String
        var rating: Double
        var neighborhoodName: String // أضفنا هذا المتغير للاتساق
    }
}

