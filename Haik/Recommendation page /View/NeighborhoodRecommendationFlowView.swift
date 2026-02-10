//
//  NeighborhoodRecommendationFlowView.swift
//  Haik
//
import SwiftUI

struct NeighborhoodRecommendationFlowView: View {

    @StateObject private var vm = NeighborhoodRecommendationViewModel()
    @Binding var isPresented: Bool

    var body: some View {
        Group {
            if vm.isComputingResults {
                NeighborhoodComputingView(progress: vm.computeProgress)
            } else if vm.isShowingResults {
                NeighborhoodResultView(vm: vm)
            } else {
                NeighborhoodQuestionView(vm: vm, isPresented: $isPresented)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}
