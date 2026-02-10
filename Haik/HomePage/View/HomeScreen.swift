//
//  HomeScreen.swift
//  Haik
//
//  Created by lamess on 07/02/2026.
//

import SwiftUI
import MapKit
import Combine

struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showRecommendation = false
    
    @State private var isKeyboardVisible = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // الخريطة
                Map(coordinateRegion: .init(get: {
                    viewModel.position.region ?? MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
                        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
                    )
                }, set: { _ in }), annotationItems: viewModel.neighborhoods) { neighborhood in
                    MapAnnotation(coordinate: neighborhood.coordinate) {
                        NeighborhoodPin(neighborhood: neighborhood) {
                            viewModel.selectNeighborhood(neighborhood)
                        }
                    }
                }
                .ignoresSafeArea()
                
                if !isKeyboardVisible {
                    if let neighborhood = viewModel.selectedNeighborhood {
                        bottomInfoCard(neighborhood: neighborhood)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        hintCard
                            .transition(.opacity)
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                VStack(spacing: 8) {
                    topSearchBar
                    searchResultsList
                }
                .padding(.vertical, 8)
            }
            .onReceive(Publishers.Merge(
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification).map { _ in true },
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification).map { _ in false }
            )) { visible in
                withAnimation { isKeyboardVisible = visible }
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
                    .padding(10).background(.white).clipShape(Circle()).shadow(radius: 2).foregroundColor(.greenPrimary)
            }
            .buttonStyle(.plain)
            
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                
                TextField("ابحث عن حي...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }) {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal).frame(height: 44).background(Color.white).cornerRadius(22).shadow(radius: 2)
            
            Image(systemName: "heart")
                .padding(10).background(.white).clipShape(Circle()).shadow(radius: 2).foregroundColor(.greenPrimary)
        }
        .padding(.horizontal)
    }
    
    private var searchResultsList: some View {
        Group {
            if !viewModel.searchText.isEmpty && viewModel.selectedNeighborhood == nil {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        if viewModel.filteredNeighborhoods.isEmpty {
                            // MARK: - التعديل 5: رسالة "لا يوجد نتائج"
                            HStack {
                                Spacer()
                                Text("لا يوجد حي بهذا الاسم، تأكد من الكتابة")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 20)
                                Spacer()
                            }
                        } else {
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(viewModel.filteredNeighborhoods) { neighborhood in
                                        Button(action: {
                                            viewModel.selectNeighborhood(neighborhood)
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        }) {
                                            HStack {
                                                Image(systemName: "NHIcon")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 14))
                                                Text(neighborhood.name)
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                Text(neighborhood.region)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.vertical, 14).padding(.horizontal, 16)
                                        }
                                        Divider().padding(.leading, 40)
                                    }
                                }
                            }
                            .frame(maxHeight: CGFloat(min(viewModel.filteredNeighborhoods.count * 55, 250)))
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                    .padding(.horizontal, 20)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private func bottomInfoCard(neighborhood: Neighborhood) -> some View {
        VStack(alignment: .trailing, spacing: 15) {
            HStack {
                Text("حي \(neighborhood.name)").font(.system(size: 20, weight: .bold))
                Spacer()
                Text("(\(neighborhood.reviewCount))").font(.caption).foregroundColor(.gray)
                ForEach(0..<5) { _ in Image(systemName: "star.fill").foregroundColor(.yellow).font(.system(size: 12)) }
           //     Spacer()
            }
            Spacer().frame(height: 10)
            Divider()
            Button {
                viewModel.neighborhoodForServices = neighborhood
                viewModel.showServices = true
            } label: {
                HStack {
                    Text("عرض الحي")
                    Image(systemName: "arrow.left")
                    
                }
                .font(.system(size: 14, weight: .medium)).foregroundColor(.black)
            }
        }
        .padding(25).frame(width: 360).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 30)).shadow(color: Color.black.opacity(0.1), radius: 10).padding(.bottom, 30)
    }
    
    private var hintCard: some View {
        Text("اضغط على الخريطة لاستكشاف بيانات الحي")
            .font(.system(size: 14)).padding().background(Color.white).cornerRadius(20).shadow(radius: 5).padding(.bottom, 40)
    }
}

struct NeighborhoodPin: View {
    let neighborhood: Neighborhood
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(neighborhood.rating).font(.system(size: 14, weight: .bold)).foregroundColor(.white).padding(.horizontal, 8).padding(.vertical, 4).background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.35, green: 0.65, blue: 0.85))).shadow(radius: 2)
                Text(neighborhood.name).font(.system(size: 12, weight: .bold)).foregroundColor(.black).padding(.horizontal, 4).background(Color.white.opacity(0.8)).cornerRadius(4)
            }
        }
    }
}
#Preview {
    HomeScreen()
}
