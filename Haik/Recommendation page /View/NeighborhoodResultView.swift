//
//  NeighborhoodResultView.swift
//  Haik
//
//  Created by Bayan Alshehri on 22/08/1447 AH.
//

//import SwiftUI
//
//struct NeighborhoodResultView: View {
//    @ObservedObject var vm: NeighborhoodRecommendationViewModel
//    @State private var cardOrder = [0, 1, 2]
//    @State private var dragOffset: CGFloat = 0
//    
//    // Neighborhood data - in a real app, these would come from your VM
//    let neighborhoods = ["حي الياسمين", "حي النرجس", "حي الملقا"]
//    private let sidePadding: CGFloat = 26
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // 1. Progress Bar (Using your custom component)
//            DashedProgressBar(total: vm.totalSteps, current: vm.currentStep)
//                .padding(.top, 14)
//                .padding(.horizontal, sidePadding)
//            
//            // 2. Title
//            Text("الاحي الانسب لك")
//                .font(.system(size: 28, weight: .bold)) // SF Arabic bold
//                .foregroundColor(.black)
//                .padding(.top, 30)
//                .padding(.bottom, 20)
//            
//            // 3. Stacked Carousel
//            ZStack {
//                ForEach(cardOrder, id: \.self) { id in
//                    let position = getPosition(for: id)
//                    
//                    ResultCardView(name: neighborhoods[id])
//                        .scaleEffect(1.0 - CGFloat(position) * 0.05)
//                        .offset(y: CGFloat(position) * 12)
//                        .zIndex(-Double(position))
//                        .offset(x: position == 0 ? dragOffset : 0)
//                        .gesture(
//                            position == 0 ?
//                            DragGesture()
//                                .onChanged { dragOffset = $0.translation.width }
//                                .onEnded { value in
//                                    if value.translation.width < -100 {
//                                        withAnimation(.spring()) { shiftForward() }
//                                    } else if value.translation.width > 100 {
//                                        withAnimation(.spring()) { shiftBackward() }
//                                    } else {
//                                        withAnimation(.spring()) { dragOffset = 0 }
//                                    }
//                                } : nil
//                        )
//                }
//            }
//            .frame(height: 420)
//            
//            // 4. Page Indicators (Matching your screenshot style)
//            HStack(spacing: 8) {
//                ForEach(0..<3) { i in
//                    Circle()
//                        .fill(cardOrder[0] == i ? Color("Green2Primary") : Color.clear)
//                        .frame(width: 8, height: 8)
//                        .overlay(Circle().stroke(Color("Green2Primary"), lineWidth: 1))
//                }
//            }
//            .padding(.top, 20)
//            
//            Spacer()
//            
//            // 5. Save Button (Using your card styling)
//            Button(action: { /* Save Logic */ }) {
//                Text("حفظ")
//                    .font(.system(size: 22, weight: .bold))
//                    .foregroundColor(.black)
//                    .frame(width: 330, height: 65)
//                    .background(Color.white)
//                    .cornerRadius(40)
//                    .cardShadow() // Using your custom extension
//            }
//            .padding(.bottom, 30)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color("GreyBackground"))
//        .environment(\.layoutDirection, .rightToLeft)
//    }
//    
//    // Carousel Logic
//    private func getPosition(for id: Int) -> Int { cardOrder.firstIndex(of: id) ?? 0 }
//    private func shiftForward() { let first = cardOrder.removeFirst(); cardOrder.append(first); dragOffset = 0 }
//    private func shiftBackward() { let last = cardOrder.removeLast(); cardOrder.insert(last, at: 0); dragOffset = 0 }
//}
//
//struct ResultCardView: View {
//    let name: String
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            // Header Section
//            VStack(alignment: .trailing, spacing: 10) {
//                HStack {
//                    Text("الأفضل لك")
//                        .font(.system(size: 11, weight: .bold))
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 10).padding(.vertical, 5)
//                        .background(Color(red: 0.6, green: 0.35, blue: 0.9)).cornerRadius(6)
//                    Spacer()
//                }
//                
//                HStack(alignment: .center) {
//                    HStack(spacing: 3) {
//                        Text("29").foregroundColor(.gray).font(.system(size: 14))
//                        ForEach(0..<5) { i in
//                            Image(systemName: "star.fill")
//                                .font(.system(size: 16))
//                                .foregroundColor(i < 3 ? .yellow : .gray.opacity(0.2))
//                        }
//                    }
//                    Spacer()
//                    Text(name)
//                        .font(.system(size: 26, weight: .bold))
//                        .foregroundColor(.black)
//                }
//            }
//            .padding([.horizontal, .top], 20)
//            
//            // Green Box (Compatibility %)
//            VStack {
//                HStack(spacing: 8) {
//                    Text("98%")
//                        .font(.system(size: 21, weight: .bold)) // As requested: Size 21
//                    Text("نسبة التوافق")
//                        .font(.system(size: 12))
//                }
//                .foregroundColor(.white)
//                .padding(.top, 16)
//                Spacer()
//            }
//            .frame(width: 300, height: 100)
//            .background(Color("Green2Primary"))
//            .cornerRadius(22)
//            .padding(.top, 15)
//            
//            // White Info Box (The Overlap/Pocket)
//            HStack(spacing: 0) {
//                ResultInfoItem(icon: "cart", label: "خدمات قريبه")
//                Divider().frame(height: 40).background(Color.gray.opacity(0.1))
//                ResultInfoItem(icon: "briefcase", label: "قرب العمل")
//                Divider().frame(height: 40).background(Color.gray.opacity(0.1))
//                ResultInfoItem(icon: "pencil.and.outline", label: "مدارس كثيره")
//            }
//            .frame(width: 310, height: 115)
//            .background(Color.white)
//            .cornerRadius(22)
//            .cardShadow() // Using your custom extension
//            .offset(y: -40) // This creates the specific overlap from your photo
//            
//            // Footer: عرض المزيد
//            HStack(spacing: 8) {
//                Image(systemName: "arrow.right") // Right arrow for RTL
//                    .font(.system(size: 14, weight: .bold))
//                Text("عرض المزيد")
//                    .font(.system(size: 16, weight: .medium))
//                Spacer()
//            }
//            .foregroundColor(Color("Green2Primary"))
//            .padding(.horizontal, 25)
//            .offset(y: -20)
//            
//            Spacer()
//        }
//        .frame(width: 342, height: 327)
//        .background(Color.white)
//        .cornerRadius(DS.cardCornerRadius)
//        .cardShadow()
//    }
//}
//
//struct ResultInfoItem: View {
//    let icon: String
//    let label: String
//    var body: some View {
//        VStack(spacing: 8) {
//            Image(systemName: icon)
//                .font(.system(size: 24, weight: .medium))
//                .foregroundColor(Color("Green2Primary"))
//            Text(label)
//                .font(.system(size: 11))
//                .foregroundColor(.gray)
//        }
//        .frame(maxWidth: .infinity)
//    }
//}
//
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
                        let position = getPosition(for: id)
                        let item = neighborhoods[id]

                        // ✅ get the Neighborhood object using the recommended item name
                        let n = NeighborhoodData.all.first(where: { $0.name == item.name })

                        ResultCardView(
                            name: item.name,
                            compatibility: item.compatibilityScore,
                            items: itemsForCard(named: item.name),
                            isBest: position == 0
                        )
                
                        .scaleEffect(1.0 - CGFloat(position) * 0.05)
                        .offset(y: CGFloat(position) * 12)
                        .zIndex(-Double(position))
                        .offset(x: position == 0 ? dragOffset : 0)
                        .gesture(
                            position == 0 ?
                            DragGesture()
                                .onChanged { dragOffset = $0.translation.width }
                                .onEnded { value in
                                    if value.translation.width < -100 {
                                        withAnimation(.spring()) { shiftForward() }
                                    } else if value.translation.width > 100 {
                                        withAnimation(.spring()) { shiftBackward() }
                                    } else {
                                        withAnimation(.spring()) { dragOffset = 0 }
                                    }
                                } : nil
                        )
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

            Button(action: { /* Save Logic */ }) {
                Text("حفظ")
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
    let name: String
    let compatibility: Double
    let items: [ResultInfo]
    let isBest: Bool
    
    var body: some View {
        VStack(spacing: 0) {

            VStack(alignment: .trailing, spacing: 10) {
                HStack {
                    if isBest {
                        Text("الأفضل لك")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(red: 0.6, green: 0.35, blue: 0.9))
                            .cornerRadius(6)
                    }
                    Spacer()
                }

                HStack(alignment: .center) {
                    HStack(spacing: 3) {
                        Text("29")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))

                        ForEach(0..<5) { i in
                            Image(systemName: "star.fill")
                                .font(.system(size: 16))
                                .foregroundColor(i < 3 ? .yellow : .gray.opacity(0.2))
                        }
                    }
                    Spacer()

                    Text(name)
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

                Spacer()
            }
            .frame(width: 300, height: 100)
            .background(Color("Green2Primary"))
            .cornerRadius(22)
            .padding(.top, 15)

            // White Info Box (still static labels for now)
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

            HStack(spacing: 8) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
                Text("عرض المزيد")
                    .font(.system(size: 16, weight: .medium))
                Spacer()
            }
            .foregroundColor(Color("Green2Primary"))
            .padding(.horizontal, 25)
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
