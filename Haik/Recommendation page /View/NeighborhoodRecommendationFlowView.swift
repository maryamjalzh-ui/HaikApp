//
//  NeighborhoodRecommendationFlowView.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/8/26.
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
                NeighborhoodQuestionView(vm: vm)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if vm.isShowingResults {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            vm.isShowingResults = false
                        }
                    } else if vm.currentIndex > 0 {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            vm.goBack()
                        }
                    } else {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isPresented = false
                        }
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.7))
                        .clipShape(Circle())
                }
            }
        }
    }
}
