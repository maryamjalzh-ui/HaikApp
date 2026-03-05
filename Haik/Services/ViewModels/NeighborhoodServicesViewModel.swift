import Foundation
import Combine
import CoreLocation
import FirebaseFirestore // استيراد فايربيس
import FirebaseAuth

@MainActor
final class NeighborhoodServicesViewModel: ObservableObject {

    // MARK: - Properties (Basic Info)
    let neighborhoodName: String
    let neighborhoodCoordinate: CLLocationCoordinate2D
    let services: [ServiceCategory] = ServiceCategory.allCases
    private let placesService: PlacesSearching
    @Published var isFavorite: Bool = false

    // MARK: - Firebase Properties
    private let db = Firestore.firestore()

    // 2. المصفوفة التي ستعرض التعليقات الحقيقية القادمة من Firebase
    @Published private(set) var reviews: [NeighborhoodReview] = []

    // 3. المتغير الذي سيحسب عدد التعليقات الحقيقي بدلاً من الرقم الثابت
    @Published var reviewsCount: Int = 0

    // 4. متغيرات إدخال التعليق الجديد (مربوطة بالواجهة)
    @Published var selectedCategory: ReviewCategory = .electricity
    @Published var newRating: Int = 0
    @Published var newComment: String = ""

    // MARK: - Services Properties
    @Published private(set) var placesByService: [ServiceCategory: [Place]] = [:]
    @Published private(set) var isLoadingByService: Set<ServiceCategory> = []

    // 5. حساب متوسط التقييم بناءً على التعليقات الموجودة
    var averageRating: Double {
        guard !reviews.isEmpty else { return 0.0 }
        let total = reviews.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(reviews.count)
    }
    
    private var reviewsListener: ListenerRegistration?

    // MARK: - Init
    init(
        neighborhoodName: String,
        coordinate: CLLocationCoordinate2D,
        placesService: PlacesSearching = AppleMapsPlacesService()
    ) {
        self.neighborhoodName = neighborhoodName
        self.neighborhoodCoordinate = coordinate
        self.placesService = placesService

        // البدء بمصفوفة فارغة لضمان الاتساق (Consistency)
        self.reviews = []
        self.reviewsCount = 0
        checkIfFavorite()
        // جلب التعليقات الحقيقية فور تشغيل الصفحة
        fetchReviews()
    }

    // MARK: - Firebase Functions (جلب وحفظ)
    func fetchReviews() {
        db.collection("neighborhood_reviews")
            .whereField("neighborhoodName", isEqualTo: self.neighborhoodName)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }

                let mapped: [NeighborhoodReview] = documents.compactMap { doc in
                    let data = doc.data()

                    let categoryRaw = data["category"] as? String ?? ""
                    let category: ReviewCategory
                    switch categoryRaw {
                    case "الكهرباء", "electricity": category = .electricity
                    case "المياه", "water":        category = .water
                    case "الانترنت", "internet":   category = .internet
                    case "عام", "general":         category = .general
                    case "الهدوء", "quiet":        category = .quiet
                    case "ثقافة الناس", "culture": category = .culture
                    default:                       category = .electricity
                    }

                    return NeighborhoodReview(
                        id: doc.documentID,
                        category: category,
                        rating: data["rating"] as? Int ?? 0,
                        comment: data["comment"] as? String ?? "",
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }

                DispatchQueue.main.async {
                    self.reviews = mapped
                    self.reviewsCount = mapped.count
                }
            }
    } // دالة إضافة تعليق جديد (تم تنظيفها لتكون متسقة)
    func addReview() {
        let trimmed = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, (1...5).contains(newRating) else { return }

        guard let uid = Auth.auth().currentUser?.uid else { return }

        let tempId = "local-\(UUID().uuidString)"
        let local = NeighborhoodReview(
            id: tempId,
            category: selectedCategory,
            rating: newRating,
            comment: trimmed,
            createdAt: Date()
        )

        reviews.insert(local, at: 0)
        reviewsCount = reviews.count

        let userName = Auth.auth().currentUser?.displayName ?? "مستخدم"
        let reviewData: [String: Any] = [
            "userId": uid,
            "userName": userName,
            "neighborhoodName": self.neighborhoodName,
            "category": selectedCategory.rawValue,
            "rating": newRating,
            "comment": trimmed,
            "createdAt": Timestamp(date: Date())
        ]

        var ref: DocumentReference? = nil
        ref = db.collection("neighborhood_reviews").addDocument(data: reviewData) { error in
            if let error = error {
                print("addReview error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.reviews.removeAll { $0.id == tempId }
                    self.reviewsCount = self.reviews.count
                }
                return
            }

            if let docId = ref?.documentID {
                DispatchQueue.main.async {
                    if let idx = self.reviews.firstIndex(where: { $0.id == tempId }) {
                        self.reviews[idx] = NeighborhoodReview(
                            id: docId,
                            category: local.category,
                            rating: local.rating,
                            comment: local.comment,
                            createdAt: local.createdAt
                        )
                    }

                    self.newRating = 0
                    self.newComment = ""
                    self.selectedCategory = .electricity
                }
            }
        }
    }

    // MARK: - Places Logic (كودك الأصلي)
    func places(for service: ServiceCategory) -> [Place] {
        placesByService[service] ?? []
    }
    
    
    func checkIfFavorite() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).addSnapshotListener { snapshot, _ in
            if let data = snapshot?.data(),
               let favorites = data["favoriteNeighborhoods"] as? [String] {
                DispatchQueue.main.async {
                    // التحقق هل الحي الحالي ضمن القائمة
                    self.isFavorite = favorites.contains(self.neighborhoodName)
                }
            }
        }
    }

    func toggleFavorite() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection("users").document(uid)
        
        // 1. تحديث الحالة في الواجهة فوراً (عشان يصير Fill)
        self.isFavorite.toggle()
        
        // 2. تحديث قاعدة البيانات في الخلفية
        if isFavorite {
            // إذا صار لايك، نضيفه للمصفوفة
            userRef.updateData([
                "favoriteNeighborhoods": FieldValue.arrayUnion([self.neighborhoodName])
            ])
        } else {
            // إذا شال اللايك، نحذفه
            userRef.updateData([
                "favoriteNeighborhoods": FieldValue.arrayRemove([self.neighborhoodName])
            ])
        }
    }

    func loadPlacesIfNeeded(for service: ServiceCategory) async {
        if placesByService[service] != nil || isLoadingByService.contains(service) { return }

        isLoadingByService.insert(service)
        defer { isLoadingByService.remove(service) }

        do {
            let mapPlaces = try await placesService.searchPlaces(
                query: service.rawValue,
                center: neighborhoodCoordinate,
                regionSpanMeters: 3500,
                limit: 40,
                neighborhoodNameArabic: neighborhoodName
            )

            let uiPlaces: [Place] = mapPlaces.map {
                Place(
                    name: $0.name,
                    rating: Int.random(in: 3...5),
                    isOpen: Bool.random(),
                    coordinate: $0.coordinate
                )
            }
            placesByService[service] = uiPlaces
        } catch {
            placesByService[service] = []
        }
    }
    deinit {
        reviewsListener?.remove()
    }
}

