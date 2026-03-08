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
            case "q2_c":
                set.insert(.groceries)
                set.insert(.supermarkets)
                set.insert(.hospitals)
                set.insert(.gasStations)

            case "q2_d":
                set.insert(.schools)

            case "q2_f":
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

    private func clamp01(_ x: Double) -> Double {
        min(1, max(0, x))
    }

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

        guard let price = RiyadhAvgPriceService.shared.avgPricePerMeter(for: neighborhood.name, aliases: neighborhood.aliases) else {
            return 0.5
        }

        let prices = RiyadhAvgPriceService.shared.records.compactMap { $0.avgPricePerMeter }.sorted()
        guard prices.count >= 6 else { return 0.5 }

        let i1 = Int(Double(prices.count - 1) * 0.33)
        let i2 = Int(Double(prices.count - 1) * 0.66)
        let t1 = prices[max(0, min(i1, prices.count - 1))]
        let t2 = prices[max(0, min(i2, prices.count - 1))]

        let tier: Int
        if price <= t1 {
            tier = 0
        } else if price <= t2 {
            tier = 1
        } else {
            tier = 2
        }

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

    private func distanceFromAnchorMeters(for neighborhood: Neighborhood) -> Double? {
        guard let anchor = anchorCoordinateFromQ2() else { return nil }
        return distanceMeters(neighborhood.coordinate, anchor)
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

    private func appLocaleCode() -> String {
        let code = Locale.current.language.languageCode?.identifier ?? "ar"
        return code == "en" ? "en" : "ar"
    }

    private func makeQuestionsDTO() -> [AIQuestionDTO] {
        questions.map { question in
            AIQuestionDTO(
                id: question.id,
                title: question.title,
                options: question.options.map {
                    AIOptionDTO(id: $0.id, title: $0.title)
                }
            )
        }
    }

    private func makeCandidatesDTO(from neighborhoods: [Neighborhood]) -> [AICandidateDTO] {
        neighborhoods.map { neighborhood in
            let lifestyle = lifestyleScore(for: neighborhood)
            let priority = priorityScore(for: neighborhood)
            let transport = transportScore(for: neighborhood)
            let price = priceScore(for: neighborhood)

            let servicesCount =
                count(for: neighborhood, .groceries) +
                count(for: neighborhood, .supermarkets) +
                count(for: neighborhood, .hospitals) +
                count(for: neighborhood, .gasStations)

            let entertainmentCount =
                count(for: neighborhood, .cafes) +
                count(for: neighborhood, .restaurants) +
                count(for: neighborhood, .cinema) +
                count(for: neighborhood, .parks)

            let schoolsCount = count(for: neighborhood, .schools)
            let metroCount = count(for: neighborhood, .metro)

            let avgPrice = RiyadhAvgPriceService.shared.avgPricePerMeter(
                for: neighborhood.name,
                aliases: neighborhood.aliases
            )

            let baseCompatibility = ((0.15 * lifestyle) + (0.55 * priority) + (0.15 * transport) + (0.15 * price)) * 100.0

            return AICandidateDTO(
                name: neighborhood.name,
                region: neighborhood.regionLocalized,
                avgPricePerMeter: avgPrice,
                metroCount: metroCount,
                servicesCount: servicesCount,
                entertainmentCount: entertainmentCount,
                schoolsCount: schoolsCount,
                distanceFromAnchorMeters: distanceFromAnchorMeters(for: neighborhood),
                lifestyleMatchScore: lifestyle * 100.0,
                priorityMatchScore: priority * 100.0,
                transportMatchScore: transport * 100.0,
                priceMatchScore: price * 100.0,
                baseCompatibilityScore: baseCompatibility
            )
        }
    }

    private func computeAndShowResults() async {
        print("COMPUTE STARTED")
        isComputingResults = true
        computeProgress = 0

        let neighborhoods = neighborhoodsToEvaluate()
        let categories = neededCategories()

        _ = await fetchCounts(neighborhoods: neighborhoods, categories: categories)

        let localSupport: [String: (lifestyle: Double, priority: Double, transport: Double, price: Double)] =
            Dictionary(uniqueKeysWithValues: neighborhoods.map { n in
                (
                    n.name,
                    (
                        lifestyleScore(for: n),
                        priorityScore(for: n),
                        transportScore(for: n),
                        priceScore(for: n)
                    )
                )
            })

        let candidates = makeCandidatesDTO(from: neighborhoods)

        let request = AIRecommendRequest(
            appLocale: appLocaleCode(),
            userAnswers: answers,
            pickedNeighborhoodByOptionID: pickedNeighborhoodByOptionID,
            questions: makeQuestionsDTO(),
            candidates: candidates,
            maxResults: 3
        )

        print("LOCAL CANDIDATES ORDER:", candidates.map { $0.name })

        do {
            let aiResponse = try await HaikAIService.shared.recommend(request: request)

            print("AI SCORED NAMES:", aiResponse.scoredNeighborhoods.map { "\($0.name):\($0.score)" })

            let aiTop3 = aiResponse.scoredNeighborhoods
                .sorted { $0.score > $1.score }
                .prefix(3)

            recommendations = aiTop3.compactMap { item in
                guard
                    let neighborhood = neighborhoods.first(where: { $0.name == item.name }),
                    let support = localSupport[item.name]
                else {
                    return nil
                }

                return RecommendedNeighborhood(
                    name: neighborhood.name,
                    coordinate: neighborhood.coordinate,
                    compatibilityScore: item.score,
                    lifestyleScore: support.lifestyle * 100.0,
                    priorityScore: support.priority * 100.0,
                    transportScore: support.transport * 100.0,
                    rating: 0
                )
            }

            if recommendations.isEmpty {
                let fallback = candidates
                    .sorted { $0.baseCompatibilityScore > $1.baseCompatibilityScore }
                    .prefix(3)

                recommendations = fallback.compactMap { item in
                    guard
                        let neighborhood = neighborhoods.first(where: { $0.name == item.name }),
                        let support = localSupport[item.name]
                    else {
                        return nil
                    }

                    return RecommendedNeighborhood(
                        name: neighborhood.name,
                        coordinate: neighborhood.coordinate,
                        compatibilityScore: item.baseCompatibilityScore,
                        lifestyleScore: support.lifestyle * 100.0,
                        priorityScore: support.priority * 100.0,
                        transportScore: support.transport * 100.0,
                        rating: 0
                    )
                }
            }
        } catch {
            print("AI FAILED, USING FALLBACK")

            let fallback = candidates
                .sorted { $0.baseCompatibilityScore > $1.baseCompatibilityScore }
                .prefix(3)

            recommendations = fallback.compactMap { item in
                guard
                    let neighborhood = neighborhoods.first(where: { $0.name == item.name }),
                    let support = localSupport[item.name]
                else {
                    return nil
                }

                return RecommendedNeighborhood(
                    name: neighborhood.name,
                    coordinate: neighborhood.coordinate,
                    compatibilityScore: item.baseCompatibilityScore,
                    lifestyleScore: support.lifestyle * 100.0,
                    priorityScore: support.priority * 100.0,
                    transportScore: support.transport * 100.0,
                    rating: 0
                )
            }
        }

        isComputingResults = false
        isShowingResults = true
    }

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
            if match >= 0.9 { return ResultInfo(icon: "banknote", label: String(localized: "price_match_very_good")) }
            if match >= 0.4 { return ResultInfo(icon: "banknote", label: String(localized: "price_match_good")) }
            return ResultInfo(icon: "banknote", label: String(localized: "price_match_high"))

        case "q2_f":
            let v = count(for: neighborhood, .cafes)
                + count(for: neighborhood, .restaurants)
                + count(for: neighborhood, .cinema)
                + count(for: neighborhood, .parks)
            return ResultInfo(icon: "popcorn", label: entertainmentLabel(v))

        default:
            return ResultInfo(icon: "star", label: String(localized: "priority_default"))
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
            return ResultInfo(icon: "car", label: String(localized: "transport_car"))
        default:
            return ResultInfo(icon: "car", label: String(localized: "transport_flexible"))
        }
    }

    private func nearLabel(anchorOptionID: String, neighborhood: Neighborhood) -> String {
        guard
            let picked = pickedNeighborhoodByOptionID[anchorOptionID],
            let anchorN = NeighborhoodData.all.first(where: { $0.name == picked })
        else { return String(localized: "near_default") }

        let dKm = distanceMeters(neighborhood.coordinate, anchorN.coordinate) / 1000.0

        if dKm <= 3 { return String(localized: "near_very_close") }
        if dKm <= 8 { return String(localized: "near_close") }
        if dKm <= 15 { return String(localized: "near_medium") }
        return String(localized: "near_far")
    }

    private func servicesLabel(_ v: Int) -> String {
        if v >= 35 { return String(localized: "services_plenty") }
        if v >= 18 { return String(localized: "services_good") }
        return String(localized: "services_limited")
    }

    private func schoolsLabel(_ v: Int) -> String {
        if v >= 12 { return String(localized: "schools_plenty") }
        if v >= 5 { return String(localized: "schools_available") }
        return String(localized: "schools_limited")
    }

    private func entertainmentLabel(_ v: Int) -> String {
        if v >= 35 { return String(localized: "ent_plenty") }
        if v >= 18 { return String(localized: "ent_available") }
        return String(localized: "ent_limited")
    }

    private func metroLabelPrimary(_ m: Int) -> String {
        if m >= 2 { return String(localized: "metro_primary_suitable") }
        if m == 1 { return String(localized: "metro_primary_limited") }
        return String(localized: "metro_none")
    }

    private func metroLabelSometimes(_ m: Int) -> String {
        if m >= 1 { return String(localized: "metro_sometimes_available") }
        return String(localized: "metro_none")
    }

    private static func buildQuestions() -> [Questions] {
        [
            Questions(
                id: "q1",
                title: String(localized: "q1_title"),
                options: [
                    RecommendationOption(id: "q1_a", title: String(localized: "q1_option_a"), icon: .calm, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q1_b", title: String(localized: "q1_option_b"), icon: .active, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q1_c", title: String(localized: "q1_option_c"), icon: .fullServices, showsNeighborhoodPicker: false)
                ],
                selectionMode: .single
            ),
            Questions(
                id: "q2",
                title: String(localized: "q2_title"),
                options: [
                    RecommendationOption(id: "q2_a", title: String(localized: "q2_option_a"), icon: .nearWork, showsNeighborhoodPicker: true),
                    RecommendationOption(id: "q2_b", title: String(localized: "q2_option_b"), icon: .nearFamily, showsNeighborhoodPicker: true),
                    RecommendationOption(id: "q2_c", title: String(localized: "q2_option_c"), icon: .services, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q2_d", title: String(localized: "q2_option_d"), icon: .schools, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q2_e", title: String(localized: "q2_option_e"), icon: .price, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q2_f", title: String(localized: "q2_option_f"), icon: .entertainment, showsNeighborhoodPicker: false)
                ],
                selectionMode: .multi(max: 2)
            ),
            Questions(
                id: "q3",
                title: String(localized: "q3_title"),
                options: [
                    RecommendationOption(id: "q3_a", title: String(localized: "q3_option_a"), icon: .metroPrimary, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q3_b", title: String(localized: "q3_option_b"), icon: .metroSometimes, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q3_c", title: String(localized: "q3_option_c"), icon: .car, showsNeighborhoodPicker: false)
                ],
                selectionMode: .single
            ),
            Questions(
                id: "q4",
                title: String(localized: "q4_title"),
                options: [
                    RecommendationOption(id: "q4_low", title: String(localized: "q4_option_low"), icon: .price, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q4_mid", title: String(localized: "q4_option_mid"), icon: .price, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q4_high", title: String(localized: "q4_option_high"), icon: .price, showsNeighborhoodPicker: false)
                ],
                selectionMode: .single
            )
        ]
    }
}
