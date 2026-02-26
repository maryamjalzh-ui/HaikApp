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

    @State private var goHome: Bool = false

    private let sidePadding: CGFloat = 26

    private var neighborhoods: [RecommendedNeighborhood] {
        vm.recommendations
    }

    var body: some View {
        VStack(spacing: 0) {

            HStack {
                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        vm.isShowingResults = false
                    }
                } label: {
                    Image(systemName: "chevron.forward")
                        .environment(\.layoutDirection, .leftToRight) // ✅ فقط للأيقونة
                        .scaledFont(size: 18, weight: .regular, relativeTo: .headline)
                        .foregroundColor(Color("Green2Primary"))
                        .frame(width: 52, height: 52)
                        .background(Color("GreyBackground"))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, sidePadding)
            .padding(.top, 10)
            .environment(\.layoutDirection, .leftToRight)

            DashedProgressBar(total: vm.totalSteps, current: vm.currentStep)
                .padding(.horizontal, sidePadding)
                .padding(.top, 25)

            Text("الأحياء الانسب لك")
                .scaledFont(size: 28, weight: .bold, relativeTo: .title1)                .foregroundStyle(.primary)
                .padding(.top, 30)
                .padding(.bottom, 20)

            if neighborhoods.isEmpty {
                Spacer()
                ProgressView("جاري تحميل النتائج…")
                    .padding(.top, 30)
                Spacer()
            } else {

                ZStack {
                    ForEach(cardOrder, id: \.self) { id in
                        cardView(for: id)
                    }
                }
                .frame(height: 420)

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

            Button(action: { goHome = true }) {
                Text("تم")
                    .scaledFont(size: 22, weight: .bold, relativeTo: .title3)                    .foregroundColor(Color("PageBackground"))
                    .frame(width: 330, height: 65)
                    .background(Color("Green2Primary"))
                    .opacity(0.80)
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 8)
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
                            .scaledFont(size: 11, weight: .bold, relativeTo: .caption2)                            .foregroundColor(.white)
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
                            .foregroundStyle(.secondary)
                            .scaledFont(size: 14, weight: .regular, relativeTo: .caption1)

                        ForEach(0..<5) { i in
                            Image(systemName: i < Int(rating.rounded()) ? "star.fill" : "star")
                                .font(.system(size: 16))
                                .foregroundColor(.yellow)
                        }
                    }

                    Spacer()

                    Text(neighborhood.name)
                        .scaledFont(size: 26, weight: .bold, relativeTo: .title2)                        .foregroundStyle(.primary)
                }
                .environment(\.layoutDirection, .leftToRight)
            }
            .padding([.horizontal, .top], 20)

            // Green Box (Compatibility %)
            VStack {
                HStack(spacing: 8) {
                    Text("\(Int(compatibility.rounded()))%")
                        .scaledFont(size: 21, weight: .bold, relativeTo: .headline)

                    Text("نسبة التوافق")
                        .scaledFont(size: 12, weight: .regular, relativeTo: .caption1)
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

            // Info Box
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
            .background(Color("GreyBackground"))
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
                        .scaledFont(size: 14, weight: .bold, relativeTo: .caption1)
                    Text("عرض الحي")
                        .scaledFont(size: 16, weight: .medium, relativeTo: .body)
                }
                .foregroundColor(Color("Green2Primary"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 25)
                .environment(\.layoutDirection, .leftToRight)
            }
            .buttonStyle(.plain)
            .offset(y: -20)

            Spacer()
        }
        .frame(width: 342, height: 327)
        .background(Color("GreyBackground"))
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
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
 
#Preview {
    ResultCardView(
        neighborhood: NeighborhoodData.all.first!,
        compatibility: 92,
        items: [
            ResultInfo(icon: "sparkles", label: "نمط الحياة"),
            ResultInfo(icon: "tram", label: "وسيلة التنقل"),
            ResultInfo(icon: "banknote", label: "سعر مناسب")
        ],
        isBest: true,
        rating: 4.6
    )
    .padding()
    
}
