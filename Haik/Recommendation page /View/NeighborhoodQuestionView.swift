 //
//  NeighborhoodQuestionView.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/8/26.
//

import SwiftUI

struct NeighborhoodQuestionView: View {

    @ObservedObject var vm: NeighborhoodRecommendationViewModel
    private let sidePadding: CGFloat = 26

    @State private var expandedOptionID: String? = nil
    @State private var q2SelectionOrder: [String] = []

    var body: some View {

        let question = vm.currentQuestion
        let options = orderedOptions(for: question)

        VStack(spacing: DS.cardSpacing) {

            DashedProgressBar(total: vm.totalSteps, current: vm.currentStep)
                .padding(.top, 14)
                .padding(.horizontal, sidePadding)

            Text(question.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding(.horizontal, sidePadding)

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {

                        ForEach(options) { option in

                            if question.id == "q2", option.showsNeighborhoodPicker {

                                ExpandableNeighborhoodOptionCard(
                                    option: option,
                                    isSelected: vm.isSelected(optionID: option.id, for: question.id),
                                    isExpanded: expandedOptionID == option.id,
                                    pickedNeighborhoodName: vm.pickedNeighborhoodName(for: option.id),
                                    onTapHeader: {
                                        let willExpand = expandedOptionID != option.id

                                        withAnimation(.easeInOut(duration: DS.expandCollapseAnimationDuration)) {
                                            expandedOptionID = willExpand ? option.id : nil
                                        }

                                        if willExpand {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + DS.scrollToExpandedDelay) {
                                                withAnimation(.easeInOut(duration: DS.scrollAnimationDuration)) {
                                                    proxy.scrollTo(option.id, anchor: .top)
                                                }
                                            }
                                        }
                                    },
                                    onConfirm: { chosenName in
                                        if !vm.isSelected(optionID: option.id, for: question.id) {
                                            vm.toggle(option: option, for: question)
                                            q2TrackSelection(optionID: option.id, questionID: question.id)
                                        }

                                        vm.setPickedNeighborhood(chosenName, for: option.id)

                                        withAnimation(.easeInOut(duration: DS.expandCollapseAnimationDuration)) {
                                            expandedOptionID = nil
                                        }

                                        if question.id == "q2" {
                                            withAnimation(.easeInOut(duration: 0.18)) {
                                                proxy.scrollTo(q2SelectionOrder.first ?? option.id, anchor: .top)
                                            }
                                        }

                                        if vm.canGoNext() {
                                            Task {
                                                try? await Task.sleep(nanoseconds: DS.autoNextDelayMultiAfterConfirm)
                                                withAnimation(.easeInOut(duration: DS.quickNextAnimationDuration)) {
                                                    vm.goNext()
                                                }
                                            }
                                        }
                                    }
                                )
                                .id(option.id)

                            } else {

                                OptionCardButton(
                                    title: option.title,
                                    icon: option.icon,
                                    isSelected: vm.isSelected(optionID: option.id, for: question.id),
                                    onTap: {
                                        withAnimation(.easeInOut(duration: DS.selectionAnimationDuration)) {

                                            vm.toggle(option: option, for: question)

                                            if question.id == "q2" {
                                                q2TrackSelection(optionID: option.id, questionID: question.id)

                                                if expandedOptionID == option.id { expandedOptionID = nil }

                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                                    withAnimation(.easeInOut(duration: 0.18)) {
                                                        proxy.scrollTo(q2SelectionOrder.first ?? option.id, anchor: .top)
                                                    }
                                                }
                                            } else {
                                                if expandedOptionID == option.id { expandedOptionID = nil }
                                            }
                                        }

                                        if question.id != "q2" {
                                            Task {
                                                try? await Task.sleep(nanoseconds: DS.autoNextDelaySingle)
                                                withAnimation(.easeInOut(duration: DS.quickNextAnimationDuration)) {
                                                    vm.goNext()
                                                }
                                            }
                                        } else {
                                            if vm.canGoNext() {
                                                Task {
                                                    try? await Task.sleep(nanoseconds: DS.autoNextDelayMultiAfterConfirm)
                                                    withAnimation(.easeInOut(duration: DS.quickNextAnimationDuration)) {
                                                        vm.goNext()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                )
                                .id(option.id)
                            }
                        }
                    }
                    .padding(.horizontal, sidePadding)
                    .padding(.top, 6)
                    .padding(.bottom, 12)
                }
            }

            if question.id == "q2" {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("- يمكنك اختيار خيارين كحد أقصى ")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Text("- اختيارك الأول يحدد أولويتك")

                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.trailing)
                .padding(.horizontal, sidePadding)
                .padding(.top, 4)
                .environment(\.layoutDirection, .leftToRight)

            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .background(Color("GreyBackground"))
        .onChange(of: vm.currentIndex) { _, _ in
            expandedOptionID = nil
            if vm.currentQuestion.id != "q2" {
                q2SelectionOrder = []
            }
        }
    }

    private func orderedOptions(for question: Questions) -> [RecommendationOption] {
        guard question.id == "q2" else { return question.options }

        let selected = question.options.filter { vm.isSelected(optionID: $0.id, for: question.id) }
        let unselected = question.options.filter { !vm.isSelected(optionID: $0.id, for: question.id) }

        let selectedSorted = selected.sorted { a, b in
            let ia = q2SelectionOrder.firstIndex(of: a.id) ?? Int.max
            let ib = q2SelectionOrder.firstIndex(of: b.id) ?? Int.max
            return ia < ib
        }

        return selectedSorted + unselected
    }

    private func q2TrackSelection(optionID: String, questionID: String) {
        guard questionID == "q2" else { return }

        let isNowSelected = vm.isSelected(optionID: optionID, for: questionID)

        if isNowSelected {
            if !q2SelectionOrder.contains(optionID) {
                q2SelectionOrder.append(optionID)
            }
        } else {
            q2SelectionOrder.removeAll { $0 == optionID }
        }

        if q2SelectionOrder.count > 2 {
            q2SelectionOrder = Array(q2SelectionOrder.prefix(2))
        }
    }
}

struct ExpandableNeighborhoodOptionCard: View {

    let option: RecommendationOption
    let isSelected: Bool
    let isExpanded: Bool
    let pickedNeighborhoodName: String?
    let onTapHeader: () -> Void
    let onConfirm: (String) -> Void

    @State private var query: String = ""
    @State private var tempPicked: String? = nil

    private var neighborhoodsSorted: [Neighborhood] {
        NeighborhoodData.all.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    private var filteredNeighborhoods: [Neighborhood] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return neighborhoodsSorted }
        return neighborhoodsSorted.filter { $0.name.localizedCaseInsensitiveContains(q) }
    }

    private var effectivePicked: String? {
        tempPicked ?? (pickedNeighborhoodName?.isEmpty == false ? pickedNeighborhoodName : nil)
    }

    private var expandedCardMinHeight: CGFloat {
        let h = UIScreen.main.bounds.height
        return min(720, max(560, h * 0.66))
    }

    private var listHeight: CGFloat {
        let rowH: CGFloat = 48
        let spacing: CGFloat = 8
        let padding: CGFloat = 12
        let minFor4 = (rowH * 4) + (spacing * 3) + padding

        let h = UIScreen.main.bounds.height
        let desired = h * 0.36

        return max(minFor4, desired)
    }

    var body: some View {
        VStack(spacing: 0) {

            Button(action: onTapHeader) {
                HStack(spacing: 12) {

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)

                    Spacer(minLength: 0)

                    VStack(alignment: .trailing, spacing: 6) {
                        Text(option.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)

                        if let name = effectivePicked {
                            Text(name)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }

                    Image(systemName: option.icon.systemName)
                        .font(.system(size: DS.iconSize, weight: DS.iconWeight))
                        .foregroundColor(DS.iconColor)
                }
                .environment(\.layoutDirection, .leftToRight)
                .padding(.horizontal, 18)
                .frame(height: DS.cardHeight)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                    .opacity(0.25)
                    .padding(.horizontal, 18)

                VStack(spacing: 12) {

                    NeighborhoodSearchField(text: $query)

                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredNeighborhoods) { n in
                                Button {
                                    tempPicked = n.name
                                } label: {
                                    NeighborhoodRow(title: n.name, isChosen: tempPicked == n.name)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .frame(height: listHeight)

                    Spacer(minLength: 0)

                    Button {
                        if let chosen = tempPicked ?? pickedNeighborhoodName, !chosen.isEmpty {
                            onConfirm(chosen)
                            tempPicked = nil
                            query = ""
                        }
                    } label: {
                        Text("تأكيد الاختيار")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("Green2Primary"))
                            .frame(width: 220, height: 46)
                            .background(Color("Green2Primary").opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled((tempPicked ?? pickedNeighborhoodName)?.isEmpty ?? true)
                    .opacity(((tempPicked ?? pickedNeighborhoodName)?.isEmpty ?? true) ? 0.5 : 1)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 16)
                .onAppear {
                    tempPicked = nil
                    query = ""
                }
            }
        }
        .frame(minHeight: isExpanded ? expandedCardMinHeight : DS.cardHeight, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: DS.cardCornerRadius, style: .continuous)
                .fill(isSelected ? Color("Green2Primary").opacity(0.14) : .white)
        )
        .cardShadow()
        .clipShape(RoundedRectangle(cornerRadius: DS.cardCornerRadius, style: .continuous))
    }
}

struct NeighborhoodSearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {

            TextField("ابحث عن الحي", text: $text)
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(Color("GreyBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .environment(\.layoutDirection, .leftToRight)
    }
}

struct NeighborhoodRow: View {
    let title: String
    let isChosen: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(isChosen ? Color("Green2Primary").opacity(0.12) : Color("GreyBackground"))
            
            HStack(spacing: 10) {
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                Image("NHIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .trailing)        .environment(\.layoutDirection, .leftToRight)

        }
        .frame(height: 48)
        .environment(\.layoutDirection, .leftToRight)
    }
}
