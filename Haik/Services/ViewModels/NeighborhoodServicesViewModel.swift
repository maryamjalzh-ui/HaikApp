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
    // 1. مرجع لقاعدة البيانات
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
    
    // دالة جلب التعليقات من Firestore
    // دالة جلب التعليقات مع مراقب التحديثات اللحظي
    func fetchReviews() {
        db.collection("neighborhood_reviews")
            .whereField("neighborhoodName", isEqualTo: self.neighborhoodName)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching: \(error?.localizedDescription ?? "")")
                    return
                }
                
                // تحويل البيانات من Firebase إلى موديل NeighborhoodReview
                self.reviews = documents.compactMap { doc -> NeighborhoodReview? in
                    let data = doc.data()
                    let categoryRaw = data["category"] as? String ?? ""
                    let rating = data["rating"] as? Int ?? 0
                    let comment = data["comment"] as? String ?? ""
                    let timestamp = data["createdAt"] as? Timestamp ?? Timestamp()
                    let category = ReviewCategory(rawValue: categoryRaw) ?? .electricity
                    let userName = data["userName"] as? String ?? "مستخدم"

                    return NeighborhoodReview(
                        category: category,
                        rating: rating,
                        comment: comment,
                        createdAt: timestamp.dateValue(),

                    )
                }
                
                // تحديث العداد الحقيقي بناءً على عدد المستندات في فايربيس
                self.reviewsCount = self.reviews.count
            }
    }
    // دالة إضافة تعليق جديد (تم تنظيفها لتكون متسقة)
    func addReview() {
        let trimmed = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, (1...5).contains(newRating) else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
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
        
        db.collection("neighborhood_reviews").addDocument(data: reviewData) { error in
            if error == nil {
                // التصفيير يتم تلقائياً بعد النجاح
                DispatchQueue.main.async {
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
}

