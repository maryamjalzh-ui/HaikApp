////
////  NeighborhoodRecommendationViewModel.swift
////  Haik
////
////  Created by Shahad Alharbi on 2/8/26.
///
import SwiftUI
import Combine
import CoreLocation

@MainActor
final class NeighborhoodRecommendationViewModel: ObservableObject {

    @Published var questions: [Questions] = []
    @Published var currentIndex: Int = 0
    @Published private(set) var answers: [String: [String]] = [:]
    @Published private(set) var pickedNeighborhoodByOptionID: [String: String] = [:]

    @Published var isShowingResults: Bool = false
    @Published var recommendations: [RecommendedNeighborhood] = []
    @Published var isLoadingResults: Bool = false
    @Environment(\.dismiss) private var dismiss

    let totalSteps: Int = 4

    @Published var isComputingResults = false
    @Published var progress: Double = 0

    @Published var computeProgress: Double = 0.0

    private let metricsService = NeighborhoodMetricsService()

    // ✅ Session cache (not permanent):
    // neighborhoodID -> (category -> count)
    private var countsCache: [UUID: [ServiceCategory: Int]] = [:]

    init() {
        questions = Self.buildQuestions()
    }

    var currentQuestion: Questions {
        questions[currentIndex]
    }

    var currentStep: Int {
        isShowingResults ? 4 : (currentIndex + 1)
    }

    func selectedOptionIDs(for questionID: String) -> [String] {
        answers[questionID] ?? []
    }

    func isSelected(optionID: String, for questionID: String) -> Bool {
        selectedOptionIDs(for: questionID).contains(optionID)
    }

    func pickedNeighborhoodName(for optionID: String) -> String? {
        pickedNeighborhoodByOptionID[optionID]
    }

    func setPickedNeighborhood(_ name: String, for optionID: String) {
        pickedNeighborhoodByOptionID[optionID] = name
    }

    func toggle(option: RecommendationOption, for question: Questions) {
        var current = answers[question.id] ?? []

        switch question.selectionMode {
        case .single:
            current = [option.id]
            answers[question.id] = current

        case .multi(let max):
            if let idx = current.firstIndex(of: option.id) {
                current.remove(at: idx)
                answers[question.id] = current
                if option.showsNeighborhoodPicker {
                    pickedNeighborhoodByOptionID[option.id] = nil
                }
            } else {
                if current.count >= max { return }
                current.append(option.id)
                answers[question.id] = current
            }
        }
    }

    func canGoNext() -> Bool {
        let q = currentQuestion
        let selected = selectedOptionIDs(for: q.id)

        switch q.selectionMode {
        case .single:
            return !selected.isEmpty
        case .multi(let max):
            return selected.count == max
        }
    }

    func goNext() {
        if currentQuestion.id == "q3" {
            Task { await computeAndShowResults() }
            return
        }

        guard currentIndex < questions.count - 1 else { return }
        currentIndex += 1
    }

    func goBack() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }

    // MARK: - Step 5 helpers

    private func neededCategories() -> Set<ServiceCategory> {
        let q2 = selectedOptionIDs(for: "q2")
        let q3 = selectedOptionIDs(for: "q3").first

        var set = Set<ServiceCategory>()

        for opt in q2 {
            switch opt {
            case "q2_c": // services
                set.insert(.groceries)
                set.insert(.supermarkets)
                set.insert(.hospitals)
                set.insert(.gasStations)

            case "q2_d": // schools
                set.insert(.schools)

            case "q2_e": // malls
                set.insert(.mall)

            case "q2_f": // entertainment
                set.insert(.cafes)
                set.insert(.restaurants)
                set.insert(.cinema)
                set.insert(.parks)

            default:
                break // near work/family do not add POI categories
            }
        }

        // transport => metro matters
        if q3 == "q3_a" || q3 == "q3_b" {
            set.insert(.metro)
        }

        return set
    }
    
    // MARK: - Step 6 Scoring helpers

    private func count(for neighborhood: Neighborhood, _ category: ServiceCategory) -> Int {
        countsCache[neighborhood.id]?[category] ?? 0
    }

    private func clamp01(_ x: Double) -> Double { min(1, max(0, x)) }

    /// Converts a count into a 0..1 score using a soft cap.
    /// Example: cap=25 -> 25+ becomes ~1.0, 10 becomes 0.4
    private func cappedScore(_ value: Int, cap: Int) -> Double {
        guard cap > 0 else { return 0 }
        return clamp01(Double(value) / Double(cap))
    }

    /// Distance score: closer is better.
    /// - 0m -> 1.0
    /// - >= maxMeters -> 0.0
    private func distanceScoreMeters(_ meters: CLLocationDistance, maxMeters: CLLocationDistance) -> Double {
        guard maxMeters > 0 else { return 0 }
        return clamp01(1.0 - (meters / maxMeters))
    }

    private func lifestyleScore(for neighborhood: Neighborhood) -> Double {
        let q1 = selectedOptionIDs(for: "q1").first ?? ""

        // Pull only what might exist in cache (if not fetched, it becomes 0)
        let cafes = count(for: neighborhood, .cafes)
        let restaurants = count(for: neighborhood, .restaurants)
        let malls = count(for: neighborhood, .mall)
        let cinema = count(for: neighborhood, .cinema)

        let groceries = count(for: neighborhood, .groceries)
        let supermarkets = count(for: neighborhood, .supermarkets)
        let hospitals = count(for: neighborhood, .hospitals)
        let gas = count(for: neighborhood, .gasStations)

        // "Activity intensity" proxy
        let activity = cafes + restaurants + malls + cinema

        // "Services completeness" proxy
        let services = groceries + supermarkets + hospitals + gas + malls

        switch q1 {
        case "q1_a": // Quiet
            // quiet = low activity => invert
            let activityNorm = cappedScore(activity, cap: 35) // tweak caps later
            return 1.0 - activityNorm

        case "q1_b": // Active
            return cappedScore(activity, cap: 35)

        case "q1_c": // Full services
            return cappedScore(services, cap: 45)

        default:
            return 0.5
        }
    }

    private func transportScore(for neighborhood: Neighborhood) -> Double {
        let q3 = selectedOptionIDs(for: "q3").first ?? ""
        let metroCount = count(for: neighborhood, .metro)

        switch q3 {
        case "q3_a": // Metro primary
            if metroCount >= 2 { return 1.0 }
            if metroCount == 1 { return 0.6 }
            return 0.0

        case "q3_b": // Metro sometimes
            return metroCount >= 1 ? 1.0 : 0.0

        case "q3_c": // Car
            // user doesn't care about metro => neutral score
            return 1.0

        default:
            return 0.7
        }
    }

    private func priorityScore(for neighborhood: Neighborhood) -> Double {
        let q2 = selectedOptionIDs(for: "q2")
        guard q2.count == 2 else { return 0 } // you require exactly 2 priorities

        let p1 = q2[0]
        let p2 = q2[1]

        let w1 = 0.65
        let w2 = 0.35

        func scoreForPriority(_ pid: String) -> Double {
            switch pid {
            case "q2_a": // near work
                guard let anchor = anchorCoordinateFromQ2() else { return 0 }
                let d = distanceMeters(neighborhood.coordinate, anchor)
                return distanceScoreMeters(d, maxMeters: 18_000) // 18km window (tweak later)

            case "q2_b": // near family
                guard let anchor = anchorCoordinateFromQ2() else { return 0 }
                let d = distanceMeters(neighborhood.coordinate, anchor)
                return distanceScoreMeters(d, maxMeters: 18_000)

            case "q2_c": // services
                let v = count(for: neighborhood, .groceries)
                      + count(for: neighborhood, .supermarkets)
                      + count(for: neighborhood, .hospitals)
                      + count(for: neighborhood, .gasStations)
                return cappedScore(v, cap: 35)

            case "q2_d": // schools
                let v = count(for: neighborhood, .schools)
                return cappedScore(v, cap: 18)

            case "q2_e": // malls
                let v = count(for: neighborhood, .mall)
                return cappedScore(v, cap: 8)

            case "q2_f": // entertainment
                let v = count(for: neighborhood, .cafes)
                      + count(for: neighborhood, .restaurants)
                      + count(for: neighborhood, .cinema)
                      + count(for: neighborhood, .parks)
                return cappedScore(v, cap: 35)

            default:
                return 0
            }
        }

        return (w1 * scoreForPriority(p1)) + (w2 * scoreForPriority(p2))
    }


    private func anchorCoordinateFromQ2() -> CLLocationCoordinate2D? {
        // If near work selected
        if let picked = pickedNeighborhoodByOptionID["q2_a"],
           let n = NeighborhoodData.all.first(where: { $0.name == picked }) {
            return n.coordinate
        }
        // If near family selected
        if let picked = pickedNeighborhoodByOptionID["q2_b"],
           let n = NeighborhoodData.all.first(where: { $0.name == picked }) {
            return n.coordinate
        }
        return nil
    }

    private func distanceMeters(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> CLLocationDistance {
        let la = CLLocation(latitude: a.latitude, longitude: a.longitude)
        let lb = CLLocation(latitude: b.latitude, longitude: b.longitude)
        return la.distance(from: lb)
    }

    private func neighborhoodsToEvaluate() -> [Neighborhood] {
        let all = NeighborhoodData.all
        let q2 = selectedOptionIDs(for: "q2")
        let selectedNear = q2.contains("q2_a") || q2.contains("q2_b")

        guard selectedNear, let anchor = anchorCoordinateFromQ2() else {
            // Your rule: if NOT near work/family -> evaluate all neighborhoods
            return all
        }

        // shortlist nearest 12
        return all.sorted {
            distanceMeters($0.coordinate, anchor) < distanceMeters($1.coordinate, anchor)
        }
        .prefix(12)
        .map { $0 }
    }

    private func fetchCounts(
        neighborhoods: [Neighborhood],
        categories: Set<ServiceCategory>
    ) async -> [UUID: [ServiceCategory: Int]] {

        var out: [UUID: [ServiceCategory: Int]] = [:]
        let totalWork = max(1, neighborhoods.count * max(1, categories.count))
        var done = 0

        for n in neighborhoods {
            var perN = countsCache[n.id] ?? [:]

            for cat in categories {
                if perN[cat] == nil {
                    let c = await metricsService.fetchCount(
                        category: cat,
                        neighborhoodNameArabic: n.name,
                        coordinate: n.coordinate
                    )
                    perN[cat] = c
                }

                done += 1
                computeProgress = Double(done) / Double(totalWork)
            }

            out[n.id] = perN
            countsCache[n.id] = perN
        }

        return out
    }

    private func computeAndShowResults() async {
        isComputingResults = true
        computeProgress = 0

        let neighborhoods = neighborhoodsToEvaluate()
        let categories = neededCategories()

        // Step 5: fetch what we need (and fill cache)
        _ = await fetchCounts(neighborhoods: neighborhoods, categories: categories)

        // Step 6: score + rank
        let wLifestyle = 0.35
        let wPriority  = 0.45
        let wTransport = 0.20

        let scored: [RecommendedNeighborhood] = neighborhoods.map { n in
            let life = lifestyleScore(for: n)         // 0..1
            let pri  = priorityScore(for: n)          // 0..1
            let tr   = transportScore(for: n)         // 0..1

            let total01 = (wLifestyle * life) + (wPriority * pri) + (wTransport * tr)
            let total100 = total01 * 100.0

            return RecommendedNeighborhood(
                name: n.name,
                coordinate: n.coordinate,
                compatibilityScore: total100,
                lifestyleScore: life * 100.0,
                priorityScore: pri * 100.0,
                transportScore: tr * 100.0,
                rating: 0
            )
        }
        .sorted { $0.compatibilityScore > $1.compatibilityScore }

        recommendations = Array(scored.prefix(3))

        isComputingResults = false
        isShowingResults = true
    }

    func resultInfoItems(for neighborhood: Neighborhood) -> [ResultInfo] {
        let n = neighborhood

        let q2 = selectedOptionIDs(for: "q2")
        let p1 = q2.first
        let p2 = q2.dropFirst().first

        var items: [ResultInfo] = []

        if let p1 { items.append(infoItem(for: p1, neighborhood: n)) }
        if let p2 { items.append(infoItem(for: p2, neighborhood: n)) }

        // Q3 always as the 3rd item
        let q3 = selectedOptionIDs(for: "q3").first ?? ""
        items.append(infoItemForTransport(q3, neighborhood: n))

        // Ensure exactly 3
        return Array(items.prefix(3))
    }

    private func infoItem(for priorityID: String, neighborhood: Neighborhood) -> ResultInfo {
        switch priorityID {

        case "q2_a": // near work
            let label = nearLabel(anchorOptionID: "q2_a", neighborhood: neighborhood)
            return ResultInfo(icon: "briefcase", label: label)

        case "q2_b": // near family
            let label = nearLabel(anchorOptionID: "q2_b", neighborhood: neighborhood)
            return ResultInfo(icon: "house", label: label)

        case "q2_c": // services
            let v = count(for: neighborhood, .groceries)
                  + count(for: neighborhood, .supermarkets)
                  + count(for: neighborhood, .hospitals)
                  + count(for: neighborhood, .gasStations)
            return ResultInfo(icon: "cart", label: servicesLabel(v))

        case "q2_d": // schools
            let v = count(for: neighborhood, .schools)
            return ResultInfo(icon: "pencil.and.ruler", label: schoolsLabel(v))

        case "q2_e": // malls
            let v = count(for: neighborhood, .mall)
            return ResultInfo(icon: "storefront", label: mallsLabel(v))

        case "q2_f": // entertainment
            let v = count(for: neighborhood, .cafes)
                  + count(for: neighborhood, .restaurants)
                  + count(for: neighborhood, .cinema)
                  + count(for: neighborhood, .parks)
            return ResultInfo(icon: "popcorn", label: entertainmentLabel(v))

        default:
            return ResultInfo(icon: "star", label: "أولوية")
        }
    }

    private func infoItemForTransport(_ q3: String, neighborhood: Neighborhood) -> ResultInfo {
        switch q3 {
        case "q3_a":
            let m = count(for: neighborhood, .metro)
            return ResultInfo(icon: "tram", label: metroLabelPrimary(m))
        case "q3_b":
            let m = count(for: neighborhood, .metro)
            return ResultInfo(icon: "tram", label: metroLabelSometimes(m))
        case "q3_c":
            return ResultInfo(icon: "car", label: "مناسب للسيارة")
        default:
            return ResultInfo(icon: "car", label: "تنقل مرن")
        }
    }

    private func nearLabel(anchorOptionID: String, neighborhood: Neighborhood) -> String {
        guard
            let picked = pickedNeighborhoodByOptionID[anchorOptionID],
            let anchorN = NeighborhoodData.all.first(where: { $0.name == picked })
        else {
            return "قريب"
        }

        let dKm = distanceMeters(neighborhood.coordinate, anchorN.coordinate) / 1000.0

        if dKm <= 3 { return "قريب جدًا" }
        if dKm <= 8 { return "قريب" }
        if dKm <= 15 { return "متوسط القرب" }
        return "بعيد نسبيًا"
    }

    private func servicesLabel(_ v: Int) -> String {
        if v >= 35 { return "خدمات كثيرة" }
        if v >= 18 { return "خدمات جيدة" }
        return "خدمات محدودة"
    }

    private func schoolsLabel(_ v: Int) -> String {
        if v >= 12 { return "مدارس كثيرة" }
        if v >= 5 { return "مدارس متوفرة" }
        return "مدارس قليلة"
    }

    private func mallsLabel(_ v: Int) -> String {
        if v >= 6 { return "مولات كثيرة" }
        if v >= 2 { return "مولات متوفرة" }
        return "مولات قليلة"
    }

    private func entertainmentLabel(_ v: Int) -> String {
        if v >= 35 { return "ترفيه كثير" }
        if v >= 18 { return "ترفيه متوفر" }
        return "ترفيه قليل"
    }

    private func metroLabelPrimary(_ m: Int) -> String {
        if m >= 2 { return "مترو مناسب" }
        if m == 1 { return "مترو محدود" }
        return "بدون مترو قريب"
    }

    private func metroLabelSometimes(_ m: Int) -> String {
        if m >= 1 { return "مترو متوفر" }
        return "بدون مترو قريب"
    }

    // MARK: - Questions

    private static func buildQuestions() -> [Questions] {
        [
            Questions(
                id: "q1",
                title: "أي نمط حياة تفضل؟",
                options: [
                    RecommendationOption(id: "q1_a", title: "حي هادئ", icon: .calm, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q1_b", title: "حي نشط وحيوي", icon: .active, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q1_c", title: "حي متكامل الخدمات", icon: .fullServices, showsNeighborhoodPicker: false)
                ],
                selectionMode: .single
            ),

            Questions(
                id: "q2",
                title: "ما الأولوية الأهم لك عند اختيار الحي؟",
                options: [
                    RecommendationOption(id: "q2_a", title: "القرب من مقر العمل", icon: .nearWork, showsNeighborhoodPicker: true),
                    RecommendationOption(id: "q2_b", title: "القرب من منزل العائلة أو الأقارب", icon: .nearFamily, showsNeighborhoodPicker: true),
                    RecommendationOption(id: "q2_c", title: "توفر الخدمات", icon: .services, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q2_d", title: "توفر المدارس", icon: .schools, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q2_e", title: "توفر مراكز تجارية", icon: .mall, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q2_f", title: "توفر المرافق الترفيهية", icon: .entertainment, showsNeighborhoodPicker: false)
                ],
                selectionMode: .multi(max: 2)
            ),

            Questions(
                id: "q3",
                title: "كيف تفضل نمط تنقلك اليومي؟",
                options: [
                    RecommendationOption(id: "q3_a", title: "أعتمد على المترو بشكل أساسي", icon: .metroPrimary, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q3_b", title: "أستخدم المترو أحيانًا", icon: .metroSometimes, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q3_c", title: "أعتمد على السيارة", icon: .car, showsNeighborhoodPicker: false)
                ],
                selectionMode: .single
            )
        ]
    }
}
