

//  HomeScreen.swift
//  Haik
//
//  Created by lamess on 07/02/2026.
//

import SwiftUI
import MapKit
import Combine

struct HomeScreen: View {
    // MARK: - Properties
    @StateObject private var viewModel = HomeViewModel()
    @State private var showRecommendation = false
    @State private var isKeyboardVisible = false
    @State private var showFavouritePage = false
    
    // تعريف متغير التنبيه داخل الـ Struct ليكون مرئياً للـ body
    @State private var showWelcomeAlert = false

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
            .alert("مرحباً بك في حيك! 🎉", isPresented: $showWelcomeAlert) {
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
        }
    }

    // MARK: - Functions
    
    // دالة فحص الدخول لأول مرة (مكانها صحيح هنا داخل الـ Struct)
    func checkFirstTimeLogin() {
        let isNewUser = UserDefaults.standard.bool(forKey: "isNewUser")
        let hasSeenWelcome = UserDefaults.standard.bool(forKey: "hasSeenWelcome")
        if isNewUser && !hasSeenWelcome {
            self.showWelcomeAlert = true
            UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
            // نحذف علامة المستخدم الجديد لكي لا تظهر مرة أخرى أبداً
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
            
            Button { showFavouritePage = true } label: {
                Image(systemName: "person")
                    .padding(10).background(.white).clipShape(Circle()).shadow(radius: 2).foregroundColor(Color("GreenPrimary"))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }
    
    // --- التعديل هنا: البحث الأصلي مع NHIcon والارتفاع المرن ---
    private var searchResultsList: some View {
        Group {
            if !viewModel.searchText.isEmpty && viewModel.selectedNeighborhood == nil {
                VStack(spacing: 0) {
                    if viewModel.filteredNeighborhoods.isEmpty {
                        Text("لا يوجد حي بهذا الاسم")
                            .font(.system(size: 14)).foregroundColor(.secondary).padding(.vertical, 20)
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(viewModel.filteredNeighborhoods) { neighborhood in
                                    Button(action: { viewModel.selectNeighborhood(neighborhood) }) {
                                        HStack(spacing: 12) {
                                            // إضافة اللوقو الأصلي NHIcon
                                            Image("NHIcon")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)
                                            
                                            Text(neighborhood.name)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            Text(neighborhood.region)
                                                .font(.system(size: 12)).foregroundColor(.secondary)
                                        }
                                        .padding(.vertical, 14).padding(.horizontal, 16)
                                    }
                                    if neighborhood.id != viewModel.filteredNeighborhoods.last?.id {
                                        Divider().padding(.leading, 52)
                                    }
                                }
                            }
                        }
                        // الارتفاع يتحدد حسب عدد النتائج بحد أقصى 250
                        .frame(maxHeight: viewModel.filteredNeighborhoods.count > 3 ? 250 : .infinity)
                    }
                }
                .background(Color.white).cornerRadius(16).shadow(radius: 10).padding(.horizontal, 20)
                .fixedSize(horizontal: false, vertical: true) // هذا السطر يمنع الخلفية من التمدد الزائد
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
            }
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
        .padding(25).frame(width: 360).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 30)).shadow(radius: 10).padding(.bottom, 30)
    }
    
    private var hintCard: some View {
        Text("اضغط على الخريطة لاستكشاف بيانات الحي")
            .font(.system(size: 14)).padding().background(Color.white).cornerRadius(20).shadow(radius: 5).padding(.bottom, 40)
    }
}
    private var hintCard: some View {
        Text("اضغط على الخريطة لاستكشاف بيانات الحي")
            .font(.system(size: 14)).padding().background(Color.white).cornerRadius(20).shadow(radius: 5).padding(.bottom, 40)
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
                    // تغيير اللون بناءً على التقييم (أخضر للتقييم العالي)
                    .background(RoundedRectangle(cornerRadius: 8)
                        .fill(colorForRating(neighborhood.rating)))
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
    
    // دالة لتحديد اللون حسب التقييم
    private func colorForRating(_ rating: String) -> Color {
        let val = Double(rating) ?? 0.0
        if val >= 4.0 { return .green }
        if val >= 3.0 { return Color(red: 0.35, green: 0.65, blue: 0.85) } // اللون الأزرق حقك
        if val > 0.0 { return .orange }
        return .gray // إذا لم يوجد تقييم
    }
}

#Preview {
    HomeScreen()
}
