//
//  HomeScreen.swift
//  Haik
//
//  Created by lamess on 07/02/2026.
//

import SwiftUI
import MapKit

struct HomeScreen: View {
    @State private var viewModel = HomeViewModel()
    @State private var showRecommendation = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // الخريطة
                Map(position: $viewModel.position) {
                    ForEach(viewModel.allNeighborhoods) { neighborhood in
                        Annotation("", coordinate: neighborhood.coordinate) {
                            NeighborhoodPin(neighborhood: neighborhood) {
                                viewModel.select(neighborhood: neighborhood)
                            }
                        }
                    }
                }
                .ignoresSafeArea()

                // الكارت السفلي أو التلميح
                if let neighborhood = viewModel.selectedNeighborhood {
                    bottomInfoCard(neighborhood: neighborhood)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    hintCard
                }
            }
            .safeAreaInset(edge: .top) {
                VStack(spacing: 8) {
                    topSearchBar
                    searchResultsList // قائمة نتائج البحث المنسدلة
                }
                .padding(.vertical, 8)
            }
            .environment(\.layoutDirection, .rightToLeft)
            .overlay {
                if showRecommendation {
                    NeighborhoodRecommendationFlowView(isPresented: $showRecommendation)
                        .navigationBarBackButtonHidden(true)
                        .environment(\.layoutDirection, .rightToLeft)
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: showRecommendation)
            .navigationDestination(isPresented: $viewModel.showServices) {
                if let n = viewModel.neighborhoodForServices {
                    NeighborhoodServicesView(neighborhoodName: n.name, coordinate: n.coordinate)
                }
            }
        }
    }
}
extension HomeScreen {

    private var topSearchBar: some View {
        HStack(spacing: 12) {
            Button { showRecommendation = true } label: {
                Image(systemName: "sparkles")
                    .padding(10).background(.white).clipShape(Circle()).shadow(radius: 2)
            }
            .buttonStyle(.plain)

            // حقل البحث الفعلي (تم حذف المايك)
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("ابحث عن حي...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                  //  .multilineTextAlignment(.right)
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal).frame(height: 44).background(Color.white).cornerRadius(22).shadow(radius: 2)

            Image(systemName: "bookmark")
                .padding(10).background(.white).clipShape(Circle()).shadow(radius: 2)
        }
        .padding(.horizontal)
    }

    // قائمة تظهر فقط عند الكتابة في البحث
    private var searchResultsList: some View {
        Group {
            if !viewModel.filteredResults.isEmpty {
                VStack(spacing: 0) {
                    ScrollView {
                        ForEach(viewModel.filteredResults) { neighborhood in
                            Button(action: { viewModel.select(neighborhood: neighborhood) }) {
                                HStack {
                                    Spacer()
                                    Text(neighborhood.name).padding().foregroundColor(.black)
                                }
                            }
                            Divider()
                        }
                    }
                    .frame(maxHeight: 200).background(Color.white).cornerRadius(15).shadow(radius: 5).padding(.horizontal, 60)
                }
            }
        }
    }

    private func bottomInfoCard(neighborhood: Neighborhood) -> some View {
        VStack(alignment: .trailing, spacing: 15) {
            HStack {
                Text("(\(neighborhood.reviewCount))").font(.caption).foregroundColor(.gray)
                ForEach(0..<5) { _ in Image(systemName: "star.fill").foregroundColor(.yellow).font(.system(size: 12)) }
                Spacer()
                Text("حي \(neighborhood.name)").font(.system(size: 20, weight: .bold))
            }
            Spacer().frame(height: 10)
            Divider()
            Button {
                viewModel.neighborhoodForServices = neighborhood
                viewModel.showServices = true
            } label: {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("لمزيد من المعلومات عن الحي")
                }
                .font(.system(size: 14, weight: .medium)).foregroundColor(.black)
            }
        }
        .padding(25).frame(width: 360).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 30)).shadow(color: Color.black.opacity(0.1), radius: 10).padding(.bottom, 30)
    }

    private var hintCard: some View {
        Text("لسه ما عرفت عن الأحياء؟ اضغط على الحي وبتعرف أكثر")
            .font(.system(size: 14)).padding().background(Color.white).cornerRadius(20).shadow(radius: 5).padding(.bottom, 40)
    }
}



struct NeighborhoodPin: View {
    let neighborhood: Neighborhood
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(neighborhood.rating)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.35, green: 0.65, blue: 0.85))
                    )
                    .shadow(radius: 2)

                Text(neighborhood.name)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 4)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(4)
            }
        }
    }
}

#Preview {
    HomeScreen()
}
