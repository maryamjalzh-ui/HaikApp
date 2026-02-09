//
//  NeighborhoodRecommendationViewModel.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/8/26.
//

import SwiftUI
import Combine

@MainActor
final class NeighborhoodRecommendationViewModel: ObservableObject {

    @Published var questions: [Questions] = []
    @Published var currentIndex: Int = 0
    @Published private(set) var answers: [String: [String]] = [:]
    @Published private(set) var pickedNeighborhoodByOptionID: [String: String] = [:]

    let totalSteps: Int = 4

    init() {
        questions = Self.buildQuestions()
    }

    var currentQuestion: Questions {
        questions[currentIndex]
    }

    var currentStep: Int {
        currentIndex + 1
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
        guard currentIndex < questions.count - 1 else { return }
        currentIndex += 1
    }

    func goBack() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
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
                    RecommendationOption(id: "q2_a", title: "القرب من مقر العمل", icon: .nearWork, showsNeighborhoodPicker: true),
                    RecommendationOption(id: "q2_b", title: "القرب من منزل العائلة أو الأقارب", icon: .nearFamily, showsNeighborhoodPicker: true),
                    RecommendationOption(id: "q2_c", title: "توفر الخدمات", icon: .services, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q2_d", title: "توفر المدارس", icon: .schools, showsNeighborhoodPicker: false),
                    RecommendationOption(id: "q2_e", title: "القرب من الجامعات", icon: .universities, showsNeighborhoodPicker: false),
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
