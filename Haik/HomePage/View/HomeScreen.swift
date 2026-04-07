////  HomeScreen.swift
////  Haik
////
////  Created by lamess on 07/02/2026.
////
//
//import SwiftUI
//import MapKit
//import Combine
//import FirebaseAuth
//
//struct HomeScreen: View {
//    // MARK: - Properties
//    @StateObject private var viewModel = HomeViewModel()
//    @State private var showRecommendation = false
//    @State private var isKeyboardVisible = false
//    @State private var showFavouritePage = false
//    @State private var showWelcomeAlert = false
//    @State private var showWelcomeSheet = false
//
//    // سويفت سيتعرف على اتجاه اللغة تلقائياً من النظام
//    @Environment(\.layoutDirection) private var layoutDirection
//
//    @Environment(\.colorScheme) private var colorScheme
//
//    // MARK: - Body
//    var body: some View {
//        NavigationStack {
//            ZStack(alignment: .bottom) {
//                // الخريطة
//                Map(coordinateRegion: .init(get: {
//                    viewModel.position.region ?? MKCoordinateRegion(
//                        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
//                        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
//                    )
//                }, set: { _ in }), annotationItems: viewModel.neighborhoods) { neighborhood in
//                    MapAnnotation(coordinate: neighborhood.coordinate) {
//                        NeighborhoodPin(neighborhood: neighborhood) {
//                            hideKeyboard()
//                            viewModel.selectNeighborhood(neighborhood)
//                        }
//                    }
//                }
//                .ignoresSafeArea()
//                .onTapGesture {
//                    hideKeyboard()
//                }
//
//                // إظهار بطاقة المعلومات تلقائياً
//                if !isKeyboardVisible {
//                    if let neighborhood = viewModel.selectedNeighborhood {
//                        bottomInfoCard(neighborhood: neighborhood)
//                            .transition(.move(edge: .bottom).combined(with: .opacity))
//                    } else {
//                        hintCard
//                            .transition(.opacity)
//                    }
//                }
//            }
//            .onAppear {
//                checkFirstTimeLogin()
//            }
//            .safeAreaInset(edge: .top) {
//                VStack(spacing: 8) {
//                    topSearchBar
//                    searchResultsList
//                }
//                .padding(.vertical, 8)
//            }
//            .onReceive(Publishers.Merge(
//                NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification).map { _ in true },
//                NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification).map { _ in false }
//            )) { visible in
//                withAnimation { isKeyboardVisible = visible }
//            }
//            .navigationDestination(isPresented: $viewModel.showServices) {
//                if let n = viewModel.neighborhoodForServices {
//                    NeighborhoodServicesView(
//                        neighborhoodName: n.nameAr, // الهوية الثابتة للـ Database
//                        displayName: n.name,        // لغة العرض للـ UI
//                        aliases: n.aliases,
//                        coordinate: n.coordinate
//                    )
//                }
//            }
//            .navigationDestination(isPresented: $showFavouritePage) {
//                FavouritePage()
//            }
//            .fullScreenCover(isPresented: $showWelcomeSheet) {
//                WelcomeView()
//            }
//            .overlay {
//                if showRecommendation {
//                    RecommendationOnboardingView(isPresented: $showRecommendation)
//                        .transition(.move(edge: .leading))
//                        .zIndex(1)
//                }
//            }
//        }
//    }
//
//    // MARK: - Functions
//    func checkFirstTimeLogin() {
//        let isNewUser = UserDefaults.standard.bool(forKey: "isNewUser")
//        let hasSeenWelcome = UserDefaults.standard.bool(forKey: "hasSeenWelcome")
//        if isNewUser && !hasSeenWelcome {
//            self.showWelcomeAlert = true
//            UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
//            UserDefaults.standard.set(false, forKey: "isNewUser")
//        }
//    }
//}
//
//// MARK: - Components Extension
//extension HomeScreen {
//
//    private var topSearchBar: some View {
//        HStack(spacing: 12) {
//            Button {
//                hideKeyboard()
//                showRecommendation = true
//            } label: {
//                Image(systemName: "sparkles")
//                    .padding(10)
//                    .foregroundColor(Color("GreenPrimary"))
//                    .frame(width: 52, height: 52)
//                    .background(Color("PageBackground"))
//                    .clipShape(Circle())
//                    .shadow(radius: 2)
//            }
//
//            HStack {
//                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
//                TextField("search_placeholder", text: $viewModel.searchText)
//                    .textFieldStyle(.plain)
//                    .autocorrectionDisabled()
//                    .onChange(of: viewModel.searchText) { newValue in
//                        if !newValue.isEmpty {
//                            viewModel.selectedNeighborhood = nil
//                        }
//                    }
//
//                if !viewModel.searchText.isEmpty {
//                    Button(action: {
//                        viewModel.searchText = ""
//                        viewModel.selectedNeighborhood = nil
//                    }) {
//                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
//                    }
//                }
//            }
//            .padding(.horizontal)
//            .frame(height: 52)
//            .background(Color("PageBackground"))
//            .cornerRadius(26)
//            .shadow(radius: 2)
//
//            Button {
//                hideKeyboard()
//                if Auth.auth().currentUser != nil {
//                    showFavouritePage = true
//                } else {
//                    showWelcomeSheet = true
//                }
//            } label: {
//                Image(systemName: "person")
//                    .padding(10)
//                    .foregroundColor(Color("GreenPrimary"))
//                    .frame(width: 52, height: 52)
//                    .background(Color("PageBackground"))
//                    .clipShape(Circle())
//                    .shadow(radius: 2)
//            }
//        }
//        .padding(.horizontal)
//    }
//
//    private var searchResultsList: some View {
//        Group {
//            if !viewModel.searchText.isEmpty && viewModel.isKeyboardVisible {
//                VStack(spacing: 0) {
//                    if viewModel.filteredNeighborhoods.isEmpty {
//                        VStack(spacing: 12) {
//                            Image(systemName: "mappin.slash.circle")
//                                .font(.system(size: 40))
//                                .foregroundColor(Color.gray.opacity(0.4))
//                                .padding(.top, 20)
//
//                            VStack(spacing: 4) {
//                                Text("no_results_title")
//                                    .scaledFont(size: 16, weight: .bold, relativeTo: .body)
//                                    .foregroundStyle(.primary)
//
//                                Text("no_results_subtitle")
//                                    .scaledFont(size: 13, weight: .regular, relativeTo: .caption1)
//                                    .foregroundStyle(.secondary)
//                                    .multilineTextAlignment(.center)
//                                    .padding(.horizontal, 30)
//                            }
//                            .padding(.bottom, 25)
//                        }
//                        .frame(maxWidth: .infinity)
//                        .background(Color("PageBackground"))
//                    } else {
//                        ScrollView {
//                            VStack(spacing: 0) {
//                                ForEach(viewModel.filteredNeighborhoods) { neighborhood in
//                                    Button(action: {
//                                        hideKeyboard()
//                                        viewModel.selectNeighborhood(neighborhood)
//                                    }) {
//                                        HStack(spacing: 12) {
//                                            Image("NHIcon")
//                                                .resizable()
//                                                .scaledToFit()
//                                                .frame(width: 24, height: 24)
//
//                                            Text(neighborhood.name)
//                                                .scaledFont(size: 16, weight: .medium, relativeTo: .body)
//                                                .foregroundStyle(.primary)
//
//                                            Spacer()
//
//                                            Text(neighborhood.regionLocalized) // بدلاً من neighborhood.region
//                                                .scaledFont(size: 12, weight: .regular, relativeTo: .caption1)
//                                                .foregroundStyle(.secondary)
//                                        }
//                                        .padding(.vertical, 14)
//                                        .padding(.horizontal, 16)
//                                        .background(Color("PageBackground"))
//                                    }
//
//                                    if neighborhood.id != viewModel.filteredNeighborhoods.last?.id {
//                                        Divider().padding(.leading, 52)
//                                    }
//                                }
//                            }
//                        }
//                        .frame(maxHeight: 250)
//                    }
//                }
//                .background(Color("PageBackground"))
//                .cornerRadius(16)
//                .shadow(radius: 10)
//                .padding(.horizontal, 20)
//            }
//        }
//    }
//
//    private func bottomInfoCard(neighborhood: Neighborhood) -> some View {
//        VStack(spacing: 14) {
//            // هنا تم التعديل: HStack بسيط، سويفت يقلبه تلقائياً
//            HStack {
//                Text("neighborhood_prefix \(neighborhood.name)")
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundColor(colorScheme == .light ? .black : .white)
//
//                Spacer()
//
//                ratingView(neighborhood: neighborhood)
//            }
//
//            AvgPriceBadgeView(
//                neighborhoodName: neighborhood.name,
//                aliases: neighborhood.aliases
//            )
//
//            Divider()
//
//            Button {
//                viewModel.neighborhoodForServices = neighborhood
//                viewModel.showServices = true
//            } label: {
//                HStack {
//                    Text("view_neighborhood_button")
//                    Image(systemName: "chevron.forward")
//                }
//                .font(.system(size: 14, weight: .medium))
//                .foregroundColor(colorScheme == .light ? .black : .white)
//            }
//        }
//        .padding(22)
//        .frame(maxWidth: 360)
//        .background(Color("PageBackground"))
//        .clipShape(RoundedRectangle(cornerRadius: 30))
//        .shadow(radius: 10)
//        .padding(.bottom, 30)
//    }
//
//    private var hintCard: some View {
//        Text("map_hint_text")
//            .font(.system(size: 14))
//            .foregroundStyle(.primary)
//            .padding()
//            .background(Color("PageBackground"))
//            .cornerRadius(20)
//            .shadow(radius: 5)
//            .padding(.bottom, 40)
//    }
//}
//
//// MARK: - Helper Views
//private func ratingView(neighborhood: Neighborhood) -> some View {
//    // نحول النص (String) لرقم (Double) ثم لعدد صحيح (Int) عشان نعرف كم نجمة نلون
//    let ratingValue = Int(Double(neighborhood.rating) ?? 0.0)
//    
//    return HStack(spacing: 4) {
//        // عرض عدد المراجعات بين قوسين
//        Text("(\(neighborhood.reviewCount))")
//            .font(.system(size: 12))
//            .foregroundStyle(.secondary)
//        
//        // تكرار النجوم من 1 إلى 5
//        ForEach(1...5, id: \.self) { i in
//            Image(systemName: "star.fill")
//            // إذا كان رقم النجمة (i) أقل من أو يساوي التقييم، نلونها بالأصفر
//            // وإلا نلونها برمادي شفاف (نجمة طافية)
//                .foregroundColor(i <= ratingValue ? .yellow : .gray.opacity(0.3))
//                .font(.system(size: 10))
//        }
//    }
//}
//
//// MARK: - NeighborhoodPin
//struct NeighborhoodPin: View {
//    let neighborhood: Neighborhood
//    let action: () -> Void
//
//    @Environment(\.colorScheme) private var colorScheme
//
//    var body: some View {
//        Button(action: action) {
//            VStack(spacing: 4) {
//                Text(neighborhood.rating)
//                    .font(.system(size: 12, weight: .bold))
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 6)
//                    .padding(.vertical, 2)
//                    .background(RoundedRectangle(cornerRadius: 6).fill(colorForRating(neighborhood.rating)))
//
//                Text(neighborhood.name)
//                    .font(.system(size: 10, weight: .bold))
//                    // ✅ لايت: أسود / دارك: أبيض
//                    .foregroundColor(colorScheme == .light ? .black : .white)
//                    .padding(.horizontal, 4)
//                    .background(Color("PageBackground").opacity(0.9))
//                    .cornerRadius(4)
//            }
//        }
//    }
//
//    private func colorForRating(_ rating: String) -> Color {
//        let val = Double(rating) ?? 0.0
//        if val >= 4.0 { return .green }
//        if val >= 3.0 { return Color(red: 0.35, green: 0.65, blue: 0.85) }
//        if val > 0.0 { return .orange }
//        return .gray
//    }
//}
//
//// MARK: - Extensions
//extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}
//
//// MARK: - Previews
//#Preview("Arabic") {
//    HomeScreen()
//        .environment(\.locale, .init(identifier: "ar"))
//}
//
//#Preview("English") {
//    HomeScreen()
//        .environment(\.locale, .init(identifier: "en"))
//}


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

    // Onboarding
    @StateObject private var coach = CoachMarksController(steps: coachmarkSteps)
    @State private var coachAnchors: [CoachmarkTargetID: Anchor<CGRect>] = [:]
    @State private var coachTargetNeighborhoodID: UUID?

    // سويفت سيتعرف على اتجاه اللغة تلقائياً من النظام
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // الخريطة
                Map(position: $viewModel.position) {
                    ForEach(viewModel.neighborhoods) { neighborhood in
                        Annotation("", coordinate: neighborhood.coordinate) {
                            NeighborhoodPin(
                                neighborhood: neighborhood,
                                isCoachTarget: neighborhood.nameAr == "العليا"
                            ) {
                                hideKeyboard()
                                viewModel.selectNeighborhood(neighborhood)
                            }
                        }
                    }
                }
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }

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
            .overlay(alignment: .top) {
                VStack(spacing: 8) {
                    topSearchBar
                    searchResultsList
                }
                .padding(.horizontal, 0)
                .padding(.top, 4)
            }
            .toolbar(.hidden, for: .navigationBar)
            .onPreferenceChange(CoachmarkAnchorKey.self) { value in
                coachAnchors = value
            }
            .overlay {
                CoachMarksOverlay(
                    controller: coach,
                    anchors: coachAnchors
                )
            }
            .onAppear {
                checkFirstTimeLogin()

                let hasSeenHints = UserDefaults.standard.bool(forKey: "hasSeenHomeHints")
                if !hasSeenHints {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        coach.start()
                        UserDefaults.standard.set(true, forKey: "hasSeenHomeHints")
                    }
                }
            }
            
            .onChange(of: coach.index) { _, newValue in
                guard let targetNeighborhood = viewModel.neighborhoods.first(where: { $0.nameAr == "العليا" })
                else { return }

                if newValue == 1 {
                    withAnimation {
                        viewModel.position = .region(
                            MKCoordinateRegion(
                                center: targetNeighborhood.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
                            )
                        )
                    }
                }

                if newValue == 2 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        viewModel.selectNeighborhood(targetNeighborhood)
                    }
                }
            }           .onReceive(Publishers.Merge(
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification).map { _ in true },
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification).map { _ in false }
            )) { visible in
                withAnimation { isKeyboardVisible = visible }
            }
            .navigationDestination(isPresented: $viewModel.showServices) {
                if let n = viewModel.neighborhoodForServices {
                    NeighborhoodServicesView(
                        neighborhoodName: n.nameAr, // الهوية الثابتة للـ Database
                        displayName: n.name,        // لغة العرض للـ UI
                        aliases: n.aliases,
                        coordinate: n.coordinate
                    )
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
                        .transition(.move(edge: .leading))
                        .zIndex(1)
                }
            }
        }
    }
//    private func closestRatedNeighborhoodToCurrentCenter() -> Neighborhood? {
//        let center = viewModel.position.region?.center ?? CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753)
//
//        return viewModel.neighborhoods
//            .filter { $0.rating != "0.0" }
//            .min {
//                let d1 = CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
//                    .distance(from: CLLocation(latitude: center.latitude, longitude: center.longitude))
//                let d2 = CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude)
//                    .distance(from: CLLocation(latitude: center.latitude, longitude: center.longitude))
//                return d1 < d2
//            }
//    }
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
            .coachmarkTarget(.recommendationButton)
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("search_placeholder", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .onChange(of: viewModel.searchText) { newValue in
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
            if !viewModel.searchText.isEmpty && isKeyboardVisible {                VStack(spacing: 0) {
                    if viewModel.filteredNeighborhoods.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "mappin.slash.circle")
                                .font(.system(size: 40))
                                .foregroundColor(Color.gray.opacity(0.4))
                                .padding(.top, 20)

                            VStack(spacing: 4) {
                                Text("no_results_title")
                                    .scaledFont(size: 16, weight: .bold, relativeTo: .body)
                                    .foregroundStyle(.primary)

                                Text("no_results_subtitle")
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
                                        hideKeyboard()
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

                                            Text(neighborhood.regionLocalized)
                                                .scaledFont(size: 12, weight: .regular, relativeTo: .caption1)
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 16)
                                        .background(Color("PageBackground"))
                                    }

                                    if neighborhood.id != viewModel.filteredNeighborhoods.last?.id {
                                        Divider().padding(.leading, 52)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 250)
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
        VStack(spacing: 14) {
            HStack {
                Text("neighborhood_prefix \(neighborhood.name)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(colorScheme == .light ? .black : .white)

                Spacer()

                ratingView(neighborhood: neighborhood)
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
                    Text("view_neighborhood_button")
                    Image(systemName: "chevron.forward")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(colorScheme == .light ? .black : .white)
            }
        }
        .padding(22)
        .frame(maxWidth: 360)
        .background(Color("PageBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(radius: 10)
        .padding(.bottom, 30)
        .coachmarkTarget(.bottomCard)
    }

    private var hintCard: some View {
        Text("map_hint_text")
            .font(.system(size: 14))
            .foregroundStyle(.primary)
            .padding()
            .background(Color("PageBackground"))
            .cornerRadius(20)
            .shadow(radius: 5)
            .padding(.bottom, 40)
    }
}

// MARK: - Helper Views
private func ratingView(neighborhood: Neighborhood) -> some View {
    let ratingValue = Int(Double(neighborhood.rating) ?? 0.0)

    return HStack(spacing: 4) {
        Text("(\(neighborhood.reviewCount))")
            .font(.system(size: 12))
            .foregroundStyle(.secondary)

        ForEach(1...5, id: \.self) { i in
            Image(systemName: "star.fill")
                .foregroundColor(i <= ratingValue ? .yellow : .gray.opacity(0.3))
                .font(.system(size: 10))
        }
    }
}



// MARK: - NeighborhoodPin
struct NeighborhoodPin: View {
    let neighborhood: Neighborhood
    let isCoachTarget: Bool
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Group {
                    if isCoachTarget {
                        Text(neighborhood.rating)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(colorForRating(neighborhood.rating))
                            )
                            .coachmarkTarget(.pinRating)
                    } else {
                        Text(neighborhood.rating)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(colorForRating(neighborhood.rating))
                            )
                    }
                }

                Text(neighborhood.name)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(colorScheme == .light ? .black : .white)
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

// MARK: - Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Previews
#Preview("Arabic") {
    HomeScreen()
        .environment(\.locale, .init(identifier: "ar"))
}

#Preview("English") {
    HomeScreen()
        .environment(\.locale, .init(identifier: "en"))
}
