//
//  NeighborhoodQuestionView.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/8/26.
//

import SwiftUI

struct NeighborhoodQuestionView: View {

    @ObservedObject var vm: NeighborhoodRecommendationViewModel

    var body: some View {

        let question = vm.currentQuestion
        let selectedID = vm.selectedOptionID(for: question.id)

        VStack(spacing: 18) {

            DashedProgressBar(total: vm.totalSteps, current: vm.currentStep)
                .padding(.top, 14)

            Text(question.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)
                .padding(.top, 10)

            VStack(spacing: 12) {
                ForEach(question.options) { option in
                    OptionCardButton(
                        title: option.title,
                        sfSymbol: option.sfSymbol,
                        isSelected: selectedID == option.id,
                        onTap: {
                            vm.select(option: option, for: question)
                        }
                    )
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 6)

            Spacer()

            Button {
                vm.goNext()
            } label: {
                Text("التالي")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color("Green2Primary"))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .opacity(vm.canGoNext() ? 1 : 0.5)
            }
            .disabled(!vm.canGoNext())
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("GreyBackground"))
        .environment(\.layoutDirection, .rightToLeft)
    }
}
