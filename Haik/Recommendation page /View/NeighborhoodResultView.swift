
//
//  NeighborhoodResultView.swift
//  Haik
//
//  Created by Bayan Alshehri on 22/08/1447 AH.
//

import SwiftUI

struct ResultInfo: Hashable {
    let icon: String
    let label: String
}

struct NeighborhoodResultView: View {
    @ObservedObject var vm: NeighborhoodRecommendationViewModel

    @State private var cardOrder: [Int] = []
    @State private var dragOffset: CGFloat = 0

    // ✅ added (go back to HomeScreen on save)
    @State private var goHome: Bool = false

    private let sidePadding: CGFloat = 26

    private var neighborhoods: [RecommendedNeighborhood] {
        vm.recommendations
    }

    var body: some View {
        VStack(spacing: 0) {

            DashedProgressBar(total: vm.totalSteps, current: vm.currentStep)
                .padding(.top, 14)
                .padding(.horizontal, sidePadding)

            Text("الاحي الانسب لك")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 30)
                .padding(.bottom, 20)

            if neighborhoods.isEmpty {
                Spacer()
                ProgressView("جاري تحميل النتائج…")
                    .padding(.top, 30)
                Spacer()
            } else {

                // Stacked Carousel
                ZStack {
                    ForEach(cardOrder, id: \.self) { id in
                        cardView(for: id)
                    }
                }
                .frame(height: 420)

                // Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<neighborhoods.count, id: \.self) { i in
                        Circle()
                            .fill(cardOrder.first == i ? Color("Green2Primary") : Color.clear)
                            .frame(width: 8, height: 8)
                            .overlay(Circle().stroke(Color("Green2Primary"), lineWidth: 1))
                    }
                }
                .padding(.top, 20)
            }

            Spacer()

            // ✅ Save -> HomeScreen
            Button(action: { goHome = true }) {
                Text("تم")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 330, height: 65)
                    .background(Color.white)
                    .cornerRadius(40)
                    .cardShadow()
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("GreyBackground"))
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear {
            cardOrder = Array(neighborhoods.indices)
        }
        .onChange(of: vm.recommendations) { _, newValue in
            cardOrder = Array(newValue.indices)
            dragOffset = 0
        }
        // ✅ presents HomeScreen (no need to know your navigation stack structure)
        .fullScreenCover(isPresented: $goHome) {
            HomeScreen()
        }
    }

    @ViewBuilder
    private func cardView(for id: Int) -> some View {
        let position = getPosition(for: id)
        let item = neighborhoods[id]
        let n = NeighborhoodData.all.first(where: { $0.name == item.name })

        if let n {
            ResultCardView(
                neighborhood: n,
                compatibility: item.compatibilityScore,
                items: vm.resultInfoItems(for: n),
                isBest: position == 0,
                rating: item.rating
            )
            .scaleEffect(1.0 - CGFloat(position) * 0.05)
            .offset(y: CGFloat(position) * 12)
            .zIndex(-Double(position))
            .offset(x: position == 0 ? dragOffset : 0)
            .contentShape(Rectangle())
            // ✅ SWIPE FIX: gesture only on the top card
            .gesture(
                position == 0
                ? DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 100
                        if value.translation.width < -threshold {
                            withAnimation(.spring()) { shiftForward() }
                        } else if value.translation.width > threshold {
                            withAnimation(.spring()) { shiftBackward() }
                        } else {
                            withAnimation(.spring()) { dragOffset = 0 }
                        }
                    }
                : nil
            )
        }
    }

    private func itemsForCard(named name: String) -> [ResultInfo] {
        guard let n = NeighborhoodData.all.first(where: { $0.name == name }) else {
            return []
        }
        return vm.resultInfoItems(for: n)
    }

    // Carousel Logic
    private func getPosition(for id: Int) -> Int { cardOrder.firstIndex(of: id) ?? 0 }

    private func shiftForward() {
        guard cardOrder.count > 1 else { dragOffset = 0; return }
        let first = cardOrder.removeFirst()
        cardOrder.append(first)
        dragOffset = 0
    }

    private func shiftBackward() {
        guard cardOrder.count > 1 else { dragOffset = 0; return }
        let last = cardOrder.removeLast()
        cardOrder.insert(last, at: 0)
        dragOffset = 0
    }
}

struct ResultCardView: View {
    let neighborhood: Neighborhood
    let compatibility: Double
    let items: [ResultInfo]
    let isBest: Bool
    let rating: Double

    var body: some View {
        VStack(spacing: 0) {

            VStack(alignment: .trailing, spacing: 10) {

                HStack {
                    Spacer()

                    if isBest {
                        Text("الأفضل لك")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(red: 0.6, green: 0.35, blue: 0.9))
                            .cornerRadius(6)
                    }
                }

                HStack(alignment: .center) {

                    // ⭐ Rating on LEFT side (because RTL)
                    HStack(spacing: 4) {
                        Text(String(format: "%.1f", rating))
                            .foregroundColor(.gray)
                            .font(.system(size: 14))

                        ForEach(0..<5) { i in
                            Image(systemName: i < Int(rating.rounded()) ? "star.fill" : "star")
                                .font(.system(size: 16))
                                .foregroundColor(.yellow)
                        }
                    }

                    Spacer()

                    Text(neighborhood.name)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .padding([.horizontal, .top], 20)

            // Green Box (Compatibility %)
            VStack {
                HStack(spacing: 8) {
                    Text("\(Int(compatibility.rounded()))%")
                        .font(.system(size: 21, weight: .bold))
                    Text("نسبة التوافق")
                        .font(.system(size: 12))
                }
                .foregroundColor(.white)
                .padding(.top, 16)
                .environment(\.layoutDirection, .leftToRight)

                Spacer()
            }
            .frame(width: 300, height: 100)
            .background(Color("Green2Primary"))
            .cornerRadius(22)
            .padding(.top, 15)

            // White Info Box
            HStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { idx in
                    let it = items[idx]
                    ResultInfoItem(icon: it.icon, label: it.label)

                    if idx != items.count - 1 {
                        Divider().frame(height: 40).background(Color.gray.opacity(0.1))
                    }
                }
            }
            .frame(width: 310, height: 115)
            .background(Color.white)
            .cornerRadius(22)
            .cardShadow()
            .offset(y: -40)

            NavigationLink {
                NeighborhoodServicesView(
                    neighborhoodName: neighborhood.name,
                    coordinate: neighborhood.coordinate
                )
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 14, weight: .bold))
                    Text("عرض المزيد")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(Color("Green2Primary"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 25)
            }
            .buttonStyle(.plain)
            .offset(y: -20)

            Spacer()
        }
        .frame(width: 342, height: 327)
        .background(Color.white)
        .cornerRadius(DS.cardCornerRadius)
        .cardShadow()
    }
}

struct ResultInfoItem: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color("Green2Primary"))
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
