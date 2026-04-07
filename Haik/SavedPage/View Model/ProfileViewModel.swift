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
    @Published var neighborhoodRatings: [String: (avg: Double, count: Int)] = [:]

  
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
                        self.fetchRatingsForNeighborhoods()
                    }
                }
            }
        }
    }
    
    func fetchRatingsForNeighborhoods() {
        let db = Firestore.firestore()
        
        for name in savedNeighborhoodNames {
            db.collection("neighborhood_reviews")
                .whereField("neighborhoodName", isEqualTo: name)
                .getDocuments { snapshot, _ in
                    guard let docs = snapshot?.documents else { return }
                    
                    let ratings = docs.compactMap { $0.data()["rating"] as? Int }
                    
                    let count = ratings.count
                    let avg = count > 0 ? Double(ratings.reduce(0, +)) / Double(count) : 0
                    
                    DispatchQueue.main.async {
                        self.neighborhoodRatings[name] = (avg, count)
                    }
                }
        }
    }
    
    
    func updateUserName(newName: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).updateData([
            "name": newName
        ]) { error in
            if let error = error {
                print("Error updating name: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.userName = newName
                }
            }
        }
    }
    func signOut(completion: (() -> Void)? = nil) {
        do {
            try Auth.auth().signOut()

            DispatchQueue.main.async {
                self.userName = ""
                self.userEmail = ""
                self.userComments = []
                self.savedNeighborhoodNames = []
                self.neighborhoodRatings = [:]
                completion?()
            }
        } catch {
            print("Sign out failed: \(error.localizedDescription)")
        }
    }
    // جلب كل التعليقات التي كتبها هذا المستخدم فقط
    func fetchUserComments() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("neighborhood_reviews")
            .whereField("userId", isEqualTo: uid)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                guard let documents = snapshot?.documents else { return }
                
                self.userComments = documents.map { doc in
                    let data = doc.data()
                    return UserComment(
                        documentId: doc.documentID,
                        text: data["comment"] as? String ?? "",
                        rating: Double(data["rating"] as? Int ?? 0),
                        neighborhoodName: data["neighborhoodName"] as? String ?? "حي مجهول"
                    )
                }
            }
    }

    func deleteComment(_ comment: UserComment) {
        db.collection("neighborhood_reviews")
            .document(comment.documentId)
            .delete { error in
                if let error = error {
                    print("Error deleting comment: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.userComments.removeAll { $0.id == comment.id }
                    }
                }
            }
    }

    func updateComment(_ comment: UserComment, newText: String, newRating: Double) {
        let docRef = db.collection("neighborhood_reviews").document(comment.documentId)

        docRef.updateData([
            "comment": newText,
            "rating": Int(newRating)
        ]) { [weak self] error in
            if let error = error {
                print("Error updating comment: \(error.localizedDescription)")
                return
            }
            print("Comment updated successfully in Firebase!")
        }
    }

    //  حذف حساب المستخدم + بياناته من Firestore
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            let error = NSError(
                domain: "Auth",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No signed-in user."]
            )
            print("Delete failed: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        let uid = user.uid
        print("Start deleting account for uid: \(uid)")

        db.collection("neighborhood_reviews")
            .whereField("userId", isEqualTo: uid)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Failed fetching user reviews: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                let docs = snapshot?.documents ?? []
                print("Found \(docs.count) reviews to delete")

                let batch = self.db.batch()
                docs.forEach { batch.deleteDocument($0.reference) }

                batch.commit { err in
                    if let err = err {
                        print("Batch delete failed: \(err.localizedDescription)")
                        completion(.failure(err))
                        return
                    }

                    print("Reviews deleted successfully")

                    self.db.collection("users").document(uid).delete { err2 in
                        if let err2 = err2 {
                            print("User document delete failed: \(err2.localizedDescription)")
                            completion(.failure(err2))
                            return
                        }

                        print("User document deleted successfully")

                        user.delete { err3 in
                            if let err3 = err3 {
                                print("Firebase Auth delete failed: \(err3.localizedDescription)")
                                completion(.failure(err3))
                                return
                            }

                            print("Auth account deleted successfully")

                            DispatchQueue.main.async {
                                self.userName = ""
                                self.userEmail = ""
                                self.userComments = []
                                self.savedNeighborhoodNames = []
                                self.neighborhoodRatings = [:]
                            }

                            completion(.success(()))
                        }
                    }
                }
            }
    }

    struct UserComment: Identifiable {
      //  let id: UUID
        var id: String { documentId }
        let documentId: String  //للحذف من الفايربيس
        var text: String
        var rating: Double
        var neighborhoodName: String // أضفنا هذا المتغير للاتساق
        
    }
}
