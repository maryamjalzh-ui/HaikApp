//  HomeScreen.swift
//  Haik
//
//  Created by lamess on 07/02/2026.
//

import SwiftUI
import MapKit
import Combine
import FirebaseAuth

struct HomeScreen: View {
    // MARK: - Properties
    @StateObject private var viewModel = HomeViewModel()
    @State private var showRecommendation = false
    @State private var isKeyboardVisible = false
    @State private var showFavouritePage = false
    @State private var showWelcomeAlert = false
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
                            hideKeyboard()
                            viewModel.selectNeighborhood(neighborhood)
                        }
                    }
                }
                .ignoresSafeArea()
                // ميزة إضافية: عند لمس الخريطة يتم إغلاق الكيبورد
                .onTapGesture {
                    hideKeyboard()
                }
                
                // إظهار بطاقة المعلومات فقط إذا لم يكن المستخدم يكتب حالياً
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
            .navigationDestination(isPresented: $viewModel.showServices) {
                if let n = viewModel.neighborhoodForServices {
                    NeighborhoodServicesView(neighborhoodName: n.name, coordinate: n.coordinate)
                }
            }
            .navigationDestination(isPresented: $showFavouritePage) {
                FavouritePage()
            }
            .fullScreenCover(isPresented: $showWelcomeSheet) {
                WelcomeView()
            }
            .overlay {
                if showRecommendation {
                    RecommendationOnboardingView(isPresented: $showRecommendation)
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                }
            }
        }
    }

    // MARK: - Functions
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

// MARK: - Components Extension
extension HomeScreen {
    
    private var topSearchBar: some View {
        HStack(spacing: 12) {
            // زر التوصيات الذكية
            Button {
                hideKeyboard()
                showRecommendation = true
            } label: {
                Image(systemName: "sparkles")
                    .padding(10)
                    .foregroundColor(Color("GreenPrimary"))
                    .frame(width: 52, height: 52)
                    .background(Color("PageBackground"))
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }

            // حقل البحث
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("ابحث عن حي...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .onChange(of: viewModel.searchText) { newValue in
                        // بمجرد أن يبدأ المستخدم بالكتابة، نصفر الاختيار القديم لإظهار القائمة مجدداً
                        if !newValue.isEmpty {
                            viewModel.selectedNeighborhood = nil
                        }
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                        viewModel.selectedNeighborhood = nil
                    }) {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            .frame(height: 52)
            .background(Color("PageBackground"))
            .cornerRadius(26)
            .shadow(radius: 2)
            
            // زر الملف الشخصي
            Button {
                hideKeyboard()
                if Auth.auth().currentUser != nil {
                    showFavouritePage = true
                } else {
                    showWelcomeSheet = true
                }
            } label: {
                Image(systemName: "person")
                    .padding(10)
                    .foregroundColor(Color("GreenPrimary"))
                    .frame(width: 52, height: 52)
                    .background(Color("PageBackground"))
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
        }
        .padding(.horizontal)
    }
    
    private var searchResultsList: some View {
        Group {
            // نستخدم الفلترة الذكية الجاهزة من الفيو مودل
            if !viewModel.searchText.isEmpty && viewModel.isKeyboardVisible {
                VStack(spacing: 0) {
                    if viewModel.filteredNeighborhoods.isEmpty {
                        // التصميم الجديد لحالة "لا توجد نتائج"
                        VStack(spacing: 12) {
                            Image(systemName: "mappin.slash.circle") // أيقونة تعبر عن عدم العثور على موقع
                                .font(.system(size: 40))
                                .foregroundColor(Color.gray.opacity(0.4))
                                .padding(.top, 20)
                            
                            VStack(spacing: 4) {
                                Text("لم نجد هذا الحي")
                                    .scaledFont(size: 16, weight: .bold, relativeTo: .body)
                                    .foregroundStyle(.primary)
                                
                                Text("تأكد من كتابة الاسم بشكل صحيح أو ابحث عن حي آخر بالرياض")
                                    .scaledFont(size: 13, weight: .regular, relativeTo: .caption1)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                            }
                            .padding(.bottom, 25)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color("PageBackground"))
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(viewModel.filteredNeighborhoods) { neighborhood in
                                    Button(action: {
                                        // 1. إغلاق الكيبورد فوراً
                                        hideKeyboard()
                                        
                                        // 2. اختيار الحي (الفيو مودل سيهتم بالباقي)
                                        viewModel.selectNeighborhood(neighborhood)
                                    }) {
                                        HStack(spacing: 12) {
                                            Image("NHIcon")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)
                                            
                                            Text(neighborhood.name)
                                                .scaledFont(size: 16, weight: .medium, relativeTo: .body)
                                                .foregroundStyle(.primary)
                                            
                                            Spacer()
                                            
                                            Text(neighborhood.region)
                                                .scaledFont(size: 12, weight: .regular, relativeTo: .caption1)
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 16)
                                        .background(Color("PageBackground")) // لضمان استجابة السطر كامل للضغط
                                    }
                                    
                                    // إضافة خط فاصل بين العناصر
                                    if neighborhood.id != viewModel.filteredNeighborhoods.last?.id {
                                        Divider().padding(.leading, 52)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 250) // حد أقصى لطول القائمة
                    }
                }
                .background(Color("PageBackground"))
                .cornerRadius(16)
                .shadow(radius: 10)
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func bottomInfoCard(neighborhood: Neighborhood) -> some View {
        VStack(alignment: .trailing, spacing: 14) {
            HStack {
                Text("حي \(neighborhood.name)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                Spacer()
                Text("(\(neighborhood.reviewCount))")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill").foregroundColor(.yellow).font(.system(size: 10))
                }
            }
            AvgPriceBadgeView(neighborhoodName: neighborhood.name, aliases: neighborhood.aliases)
            Divider()
            Button {
                viewModel.neighborhoodForServices = neighborhood
                viewModel.showServices = true
            } label: {
                HStack {
                    Text("عرض الحي")
                    Image(systemName: "arrow.left")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.primary)
            }
        }
        .padding(22)
        .frame(maxWidth: 360)
        .background(Color("PageBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(radius: 10)
        .padding(.bottom, 30)
    }
    
    private var hintCard: some View {
        Text("اضغط على الخريطة لاستكشاف بيانات الحي")
            .font(.system(size: 14))
            .foregroundStyle(.primary)
            .padding()
            .background(Color("PageBackground"))
            .cornerRadius(20)
            .shadow(radius: 5)
            .padding(.bottom, 40)
    }
}

// MARK: - Helper Extension
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - NeighborhoodPin (كود الـ Pin كما هو مع تحسين بسيط)
struct NeighborhoodPin: View {
    let neighborhood: Neighborhood
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(neighborhood.rating)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(RoundedRectangle(cornerRadius: 6).fill(colorForRating(neighborhood.rating)))
                
                Text(neighborhood.name)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 4)
                    .background(Color("PageBackground").opacity(0.9))
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
