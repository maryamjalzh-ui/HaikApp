//
//  CoachMarksController.swift
//  
//
//  Created by Bayan Alshehri on 15/10/1447 AH.
//

import SwiftUI
import Combine

@MainActor
final class CoachMarksController: ObservableObject {

    @Published var isActive: Bool = false
    @Published var index: Int = 0

    let steps: [CoachmarkStep]

    init(steps: [CoachmarkStep]) {
        self.steps = steps
    }

    var currentStep: CoachmarkStep? {
        guard isActive, index >= 0, index < steps.count else { return nil }
        return steps[index]
    }

    func start() {
        guard !steps.isEmpty else { return }
        index = 0
        isActive = true
    }

    func next() {
        guard index < steps.count - 1 else {
            isActive = false
            return
        }
        index += 1
    }

    func close() {
        isActive = false
    }
}
