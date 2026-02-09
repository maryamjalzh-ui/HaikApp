//
//  HomeScreen.swift
//  Haik
//
//  Created by lamess on 07/02/2026.
//
import SwiftUI
import MapKit

struct HomeScreen: View {
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    )

    @State private var selectedNeighborhood: Neighborhood? = nil
    @State private var showRecommendation = false
    @State private var showServices = false
    @State private var neighborhoodForServices: Neighborhood? = nil


    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $position) {
                    ForEach(NeighborhoodData.all) { neighborhood in
                        Annotation("", coordinate: neighborhood.coordinate) {
                            NeighborhoodPin(neighborhood: neighborhood) {
                                withAnimation(.spring()) {
                                    selectedNeighborhood = neighborhood
                                }
                            }
                        }
                    }
                }
                .ignoresSafeArea()

                if let neighborhood = selectedNeighborhood {
                    bottomInfoCard(neighborhood: neighborhood)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    hintCard
                }
            }
            .safeAreaInset(edge: .top) {
                topSearchBar
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
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
            .navigationDestination(isPresented: $showServices) {
                if let n = neighborhoodForServices {
                    NeighborhoodServicesView(neighborhood: n)
                        .navigationBarBackButtonHidden(true)
                        .environment(\.layoutDirection, .rightToLeft)
                }
            }

     

        }
    }
}

extension HomeScreen {

    private var topSearchBar: some View {
        HStack(spacing: 12) {
            Button {
                showRecommendation = true
            } label: {
                Image(systemName: "sparkles")
                    .padding(10)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
            .buttonStyle(.plain)

            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                Text("ابحث عن حي...").foregroundColor(.gray)
                Spacer()
                Image(systemName: "mic.fill").foregroundColor(.gray)
            }
            .padding(.horizontal)
            .frame(height: 44)
            .background(Color.white)
            .cornerRadius(22)
            .shadow(radius: 2)

            Image(systemName: "bookmark")
                .padding(10)
                .background(.white)
                .clipShape(Circle())
                .shadow(radius: 2)
        }
        .padding(.horizontal)
    }

    private func bottomInfoCard(neighborhood: Neighborhood) -> some View {
        VStack(alignment: .trailing, spacing: 15) {
            HStack {
                Text("(\(neighborhood.reviewCount))")
                    .font(.caption)
                    .foregroundColor(.gray)
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 12))
                }
                Spacer()
                Text("حي \(neighborhood.name)")
                    .font(.system(size: 20, weight: .bold))
            }

            Spacer().frame(height: 10)

            Divider()

            Button {
                neighborhoodForServices = neighborhood
                showServices = true
            } label: {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("لمزيد من المعلومات عن الحي")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
            }

        }
        .padding(25)
        .frame(width: 360)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: Color.black.opacity(0.1), radius: 10)
        .padding(.bottom, 30)
    }

    private var hintCard: some View {
        Text("لسه ما عرفت عن الأحياء؟ اضغط على الحي وبتعرف أكثر")
            .font(.system(size: 14))
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)
            .padding(.bottom, 40)
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
