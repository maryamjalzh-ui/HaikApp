//  HomeScreen.swift
//  Haik
//
//  Created by lamess on 07/02/2026.
//

import SwiftUI
import MapKit
import Combine
import FirebaseAuth // تم إضافة المكتبة للتحقق من حالة المستخدم

struct HomeScreen: View {
    // MARK: - Properties
    @StateObject private var viewModel = HomeViewModel()
    @State private var showRecommendation = false
    @State private var isKeyboardVisible = false
    @State private var showFavouritePage = false
    
    // تعريف متغير التنبيه داخل الـ Struct ليكون مرئياً للـ body
    @State private var showWelcomeAlert = false
    
    // متغير للتحكم في ظهور صفحة تسجيل الدخول للضيف
    @State private var showWelcomeSheet = false

    // MARK: - Body
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
            .onAppear {
                checkFirstTimeLogin()
                viewModel.updateNeighborhoodRatings()
            }
            .alert("مرحباً بك في حيّك! 🎉", isPresented: $showWelcomeAlert) {
                Button("استكشاف الأحياء", role: .cancel) { }
            } message: {
                Text("تم تفعيل حسابك بنجاح. الآن يمكنك استكشاف أحياء الرياض، إضافة تعليقاتك، والحصول على أفضل التوصيات المخصصة لك.")
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
                    RecommendationOnboardingView(isPresented: $showRecommendation)
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
            .navigationDestination(isPresented: $showFavouritePage) {
                FavouritePage()
            }
            // إضافة غطاء كامل لصفحة الترحيب عند محاولة الضيف الدخول للبروفايل
            .fullScreenCover(isPresented: $showWelcomeSheet) {
                WelcomeView()
            }
        }
    }

    // MARK: - Functions
    
    // دالة فحص الدخول لأول مرة
    func checkFirstTimeLogin() {
        let isNewUser = UserDefaults.standard.bool(forKey: "isNewUser")
        let hasSeenWelcome = UserDefaults.standard.bool(forKey: "hasSeenWelcome")
        if isNewUser && !hasSeenWelcome {
            self.showWelcomeAlert = true
            UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
            UserDefaults.standard.set(false, forKey: "isNewUser")
        }
    }
}

// MARK: - Extension for UI Components
extension HomeScreen {
    
    private var topSearchBar: some View {
        HStack(spacing: 12) {
            Button { showRecommendation = true } label: {
                Image(systemName: "sparkles")
                    .padding(10).background(.white).clipShape(Circle()).shadow(radius: 2).foregroundColor(Color("GreenPrimary"))
            }
            .buttonStyle(.plain)
            
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("ابحث عن حي...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                    }
                }
            }
            
            .padding(.horizontal).frame(height: 44).background(Color.white).cornerRadius(22).shadow(radius: 2)
            
            // تعديل منطق زر البروفايل
            Button {
                if Auth.auth().currentUser != nil {
                    showFavouritePage = true
                } else {
                    showWelcomeSheet = true // إظهار صفحة التسجيل للضيف
                }
            } label: {
                Image(systemName: "person")
                    .padding(10).background(.white).clipShape(Circle()).shadow(radius: 2).foregroundColor(Color("GreenPrimary"))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }
    
    private var searchResultsList: some View {
        Group {
            if !viewModel.searchText.isEmpty && viewModel.selectedNeighborhood == nil {
                VStack(spacing: 0) {
                    if viewModel.filteredNeighborhoods.isEmpty {
                        Text("لا يوجد حي بهذا الاسم")
                            .scaledFont(size: 14, weight: .regular, relativeTo: .caption1).foregroundColor(.secondary).padding(.vertical, 20)
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(viewModel.filteredNeighborhoods) { neighborhood in
                                    Button(action: { viewModel.selectNeighborhood(neighborhood) }) {
                                        HStack(spacing: 12) {
                                            Image("NHIcon")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)
                                            
                                            Text(neighborhood.name)
                                                .scaledFont(size: 16, weight: .medium, relativeTo: .body)
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            Text(neighborhood.region)
                                                .scaledFont(size: 12, weight: .regular, relativeTo: .caption1).foregroundColor(.secondary)
                                        }
                                        .padding(.vertical, 14).padding(.horizontal, 16)
                                    }
                                    if neighborhood.id != viewModel.filteredNeighborhoods.last?.id {
                                        Divider().padding(.leading, 52)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: viewModel.filteredNeighborhoods.count > 3 ? 250 : .infinity)
                    }
                }
                .background(Color.white).cornerRadius(16).shadow(radius: 10).padding(.horizontal, 20)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func bottomInfoCard(neighborhood: Neighborhood) -> some View {
        VStack(alignment: .trailing, spacing: 14) {

            HStack {
                Text("حي \(neighborhood.name)")
                    .scaledFont(size: 20, weight: .bold, relativeTo: .headline)
                Spacer()

                Text("(\(neighborhood.reviewCount))")
                    .scaledFont(size: 12, weight: .regular, relativeTo: .caption1)                    .foregroundColor(.gray)

                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    .scaledFont(size: 12, weight: .regular, relativeTo: .caption1)                }
            }

            AvgPriceBadgeView(
                neighborhoodName: neighborhood.name,
                aliases: neighborhood.aliases
            )

            Divider()

            Button {
                viewModel.neighborhoodForServices = neighborhood
                viewModel.showServices = true
            } label: {
                HStack {
                    Text("عرض الحي")
                    Image(systemName: "arrow.left")
                }
                .scaledFont(size: 14, weight: .medium, relativeTo: .subheadline)                .foregroundColor(.black)
            }
        }
        .padding(22)
        .frame(width: 360)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(radius: 10)
        .padding(.bottom, 30)
    }

    
    private var hintCard: some View {
        Text("اضغط على الخريطة لاستكشاف بيانات الحي")
            .scaledFont(size: 14, weight: .regular, relativeTo: .caption1).padding().background(Color.white).cornerRadius(20).shadow(radius: 5).padding(.bottom, 40)
    }
}

struct NeighborhoodPin: View {
    let neighborhood: Neighborhood
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(neighborhood.rating)
                    .scaledFont(size: 14, weight: .bold, relativeTo: .caption1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 8)
                        .fill(colorForRating(neighborhood.rating)))
                    .shadow(radius: 2)
                
                Text(neighborhood.name)
                    .scaledFont(size: 12, weight: .bold, relativeTo: .caption2)
                    .foregroundColor(.black)
                    .padding(.horizontal, 4)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(4)
            }
        }
    }
    
    private func colorForRating(_ rating: String) -> Color {
        let val = Double(rating) ?? 0.0
        if val >= 4.0 { return .green }
        if val >= 3.0 { return Color(red: 0.35, green: 0.65, blue: 0.85) }
        if val > 0.0 { return .orange }
        return .gray
    }
}

#Preview {
    HomeScreen()
}
