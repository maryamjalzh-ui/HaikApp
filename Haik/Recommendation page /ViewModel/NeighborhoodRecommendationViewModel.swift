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

    let totalSteps: Int = 5

    @Published var isComputingResults = false
    @Published var progress: Double = 0

    @Published var computeProgress: Double = 0.0

    private let metricsService = NeighborhoodMetricsService()

    private var countsCache: [UUID: [ServiceCategory: Int]] = [:]

    init() {
        questions = Self.buildQuestions()
    }

    var currentQuestion: Questions {
        questions[currentIndex]
    }

    var currentStep: Int {
        isShowingResults ? totalSteps : (currentIndex + 1)
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
        if currentQuestion.id == "q4" {
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

            case "q2_f": // entertainment
                set.insert(.cafes)
                set.insert(.restaurants)
                set.insert(.cinema)
                set.insert(.parks)

            default:
                break
            }
        }

        if q3 == "q3_a" || q3 == "q3_b" {
            set.insert(.metro)
        }

        return set
    }


    private func count(for neighborhood: Neighborhood, _ category: ServiceCategory) -> Int {
        countsCache[neighborhood.id]?[category] ?? 0
    }

    private func clamp01(_ x: Double) -> Double { min(1, max(0, x)) }

    private func cappedScore(_ value: Int, cap: Int) -> Double {
        guard cap > 0 else { return 0 }
        return clamp01(Double(value) / Double(cap))
    }

    private func distanceScoreMeters(_ meters: CLLocationDistance, maxMeters: CLLocationDistance) -> Double {
        guard maxMeters > 0 else { return 0 }
        return clamp01(1.0 - (meters / maxMeters))
    }

    private func lifestyleScore(for neighborhood: Neighborhood) -> Double {
        let q1 = selectedOptionIDs(for: "q1").first ?? ""

        let cafes = count(for: neighborhood, .cafes)
        let restaurants = count(for: neighborhood, .restaurants)
        let malls = count(for: neighborhood, .mall)
        let cinema = count(for: neighborhood, .cinema)

        let groceries = count(for: neighborhood, .groceries)
        let supermarkets = count(for: neighborhood, .supermarkets)
        let hospitals = count(for: neighborhood, .hospitals)
        let gas = count(for: neighborhood, .gasStations)

        let activity = cafes + restaurants + malls + cinema
        let services = groceries + supermarkets + hospitals + gas + malls

        switch q1 {
        case "q1_a":
            let activityNorm = cappedScore(activity, cap: 35)
            return 1.0 - activityNorm
        case "q1_b":
            return cappedScore(activity, cap: 35)
        case "q1_c":
            return cappedScore(services, cap: 45)
        default:
            return 0.5
        }
    }

    private func transportScore(for neighborhood: Neighborhood) -> Double {
        let q3 = selectedOptionIDs(for: "q3").first ?? ""
        let metroCount = count(for: neighborhood, .metro)

        switch q3 {
        case "q3_a":
            if metroCount >= 2 { return 1.0 }
            if metroCount == 1 { return 0.6 }
            return 0.0
        case "q3_b":
            return metroCount >= 1 ? 1.0 : 0.0
        case "q3_c":
            return 1.0
        default:
            return 0.7
        }
    }

    private func priceScore(for neighborhood: Neighborhood) -> Double {
        let pref = selectedOptionIDs(for: "q4").first ?? ""

        guard let price = RiyadhAvgPriceService.shared.avgPricePerMeter(for: neighborhood.name, aliases: []) else {
            return 0.5
        }

        let prices = RiyadhAvgPriceService.shared.records.compactMap { $0.avgPricePerMeter }.sorted()
        guard prices.count >= 6 else { return 0.5 }

        let i1 = Int(Double(prices.count - 1) * 0.33)
        let i2 = Int(Double(prices.count - 1) * 0.66)
        let t1 = prices[max(0, min(i1, prices.count - 1))]
        let t2 = prices[max(0, min(i2, prices.count - 1))]

        let tier: Int
        if price <= t1 { tier = 0 }
        else if price <= t2 { tier = 1 }
        else { tier = 2 }

        switch pref {
        case "q4_low":
            if tier == 0 { return 1.0 }
            if tier == 1 { return 0.35 }
            return 0.0

        case "q4_mid":
            if tier == 1 { return 1.0 }
            return 0.4

        case "q4_high":
            if tier == 2 { return 1.0 }
            if tier == 1 { return 0.45 }
            return 0.15

        default:
            return 0.5
        }
    }

    private func priorityScore(for neighborhood: Neighborhood) -> Double {
        let q2 = selectedOptionIDs(for: "q2")
        guard q2.count == 2 else { return 0 }

        let p1 = q2[0]
        let p2 = q2[1]

        let w1 = 0.65
        let w2 = 0.35

        func scoreForPriority(_ pid: String) -> Double {
            switch pid {

            case "q2_a":
                guard let anchor = anchorCoordinateFromQ2() else { return 0 }
                let d = distanceMeters(neighborhood.coordinate, anchor)
                return distanceScoreMeters(d, maxMeters: 18_000)

            case "q2_b":
                guard let anchor = anchorCoordinateFromQ2() else { return 0 }
                let d = distanceMeters(neighborhood.coordinate, anchor)
                return distanceScoreMeters(d, maxMeters: 18_000)

            case "q2_c":
                let v = count(for: neighborhood, .groceries)
                      + count(for: neighborhood, .supermarkets)
                      + count(for: neighborhood, .hospitals)
                      + count(for: neighborhood, .gasStations)
                return cappedScore(v, cap: 35)

            case "q2_d":
                let v = count(for: neighborhood, .schools)
                return cappedScore(v, cap: 18)

            case "q2_e":
                return priceScore(for: neighborhood)

            case "q2_f":
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
        if let picked = pickedNeighborhoodByOptionID["q2_a"],
           let n = NeighborhoodData.all.first(where: { $0.name == picked }) {
            return n.coordinate
        }
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
            return all
        }

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

        _ = await fetchCounts(neighborhoods: neighborhoods, categories: categories)

        let wLifestyle = 0.15
        let wPriority  = 0.55
        let wTransport = 0.15
        let wPrice     = 0.15

        let scored: [RecommendedNeighborhood] = neighborhoods.map { n in
            let life = lifestyleScore(for: n)   // 0..1
            let pri  = priorityScore(for: n)    // 0..1
            let tr   = transportScore(for: n)   // 0..1
            let prc  = priceScore(for: n)       // 0..1  ✅ always from q4

            let total01 = (wLifestyle * life) + (wPriority * pri) + (wTransport * tr) + (wPrice * prc)
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

    // MARK: - Result info items

    func resultInfoItems(for neighborhood: Neighborhood) -> [ResultInfo] {
        let q2 = selectedOptionIDs(for: "q2")
        let p1 = q2.first
        let p2 = q2.dropFirst().first

        var items: [ResultInfo] = []

        if let p1 { items.append(infoItem(for: p1, neighborhood: neighborhood)) }
        if let p2 { items.append(infoItem(for: p2, neighborhood: neighborhood)) }

        let q3 = selectedOptionIDs(for: "q3").first ?? ""
        items.append(infoItemForTransport(q3, neighborhood: neighborhood))

        return Array(items.prefix(3))
    }

    private func infoItem(for priorityID: String, neighborhood: Neighborhood) -> ResultInfo {
        switch priorityID {

        case "q2_a":
            let label = nearLabel(anchorOptionID: "q2_a", neighborhood: neighborhood)
            return ResultInfo(icon: "briefcase", label: label)

        case "q2_b":
            let label = nearLabel(anchorOptionID: "q2_b", neighborhood: neighborhood)
            return ResultInfo(icon: "house", label: label)

        case "q2_c":
            let v = count(for: neighborhood, .groceries)
                  + count(for: neighborhood, .supermarkets)
                  + count(for: neighborhood, .hospitals)
                  + count(for: neighborhood, .gasStations)
            return ResultInfo(icon: "cart", label: servicesLabel(v))

        case "q2_d":
            let v = count(for: neighborhood, .schools)
            return ResultInfo(icon: "pencil.and.ruler", label: schoolsLabel(v))

        case "q2_e":
            let match = priceScore(for: neighborhood)
            if match >= 0.9 { return ResultInfo(icon: "banknote", label: "سعر مناسب جدًا") }
            if match >= 0.4 { return ResultInfo(icon: "banknote", label: "سعر مناسب") }
            return ResultInfo(icon: "banknote", label: "سعر مرتفع لميزانيتك")

        case "q2_f":
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
        else { return "قريب" }

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
                    RecommendationOption(id: "q2_a", title: "القرب من مقر العمل", icon: .nearWork, showsNeighborhoodPicker: true)
                    ,
                    RecommendationOption(id: "q2_b", title: "القرب من منزل العائلة أو الأقارب", icon: .nearFamily, showsNeighborhoodPicker: true),
                    RecommendationOption(id: "q2_c", title: "توفر الخدمات", icon: .services, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q2_d", title: "توفر المدارس", icon: .schools, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q2_e", title: "سعر المتر المناسب", icon: .price, showsNeighborhoodPicker: false),
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
            ),

            Questions(
                id: "q4",
                title: "ما ميزانيتك التقريبية لسعر المتر في الحي؟",
                options: [
                    RecommendationOption(id: "q4_low", title: "منخفض (مثال: 3,500 ر.س/م²)", icon: .price, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q4_mid", title: "متوسط (مثال: 6,500 ر.س/م²)", icon: .price, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q4_high", title: "مرتفع (مثال: 11,000 ر.س/م²)", icon: .price, showsNeighborhoodPicker: false)
                ],
                selectionMode: .single
            )
        ]
    }
    
}
#Preview {
    NeighborhoodQuestionView(
        vm: NeighborhoodRecommendationViewModel(),
        isPresented: .constant(true)
    )
    .environment(\.layoutDirection, .rightToLeft)
}
