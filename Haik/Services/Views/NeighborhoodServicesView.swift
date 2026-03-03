import SwiftUI
import CoreLocation
import FirebaseAuth // إضافة المكتبة للتحقق من حالة المستخدم

struct NeighborhoodServicesView: View {

    // MARK: - Colors
    private let greenPrimary = Color("GreenPrimary")
    private let primaryColor = Color("Green2Primary")
    private let pageBackground = Color("PageBackground")
    private let borderGray = Color(.separator)
    private let hintGray = Color(.secondary)
    private let yellowHex = Color(hex: "E7CB62")

    // MARK: - Layout
    private let grid = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18)
    ]

    private let tileSize: CGFloat = 92
    private let tileIconSize: CGFloat = 30
    private let tileTextSize: CGFloat = 14

    // MARK: - State
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: NeighborhoodServicesViewModel
    @FocusState private var isCommentFocused: Bool
    
    // متغير للتحكم بظهور صفحة الترحيب (تسجيل الدخول)
    @State private var showLoginSheet = false

    init(neighborhoodName: String, coordinate: CLLocationCoordinate2D) {
        _vm = StateObject(
            wrappedValue: NeighborhoodServicesViewModel(
                neighborhoodName: neighborhoodName,
                coordinate: coordinate
            )
        )
    }

    // MARK: - View
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    header

                    sectionTitle("services_section_title")
                    servicesGrid

                    sectionTitle("reviews_section_title")
                    reviewComposerSection
                    
                    subsectionHint("comments_list_title")
                    commentsList
                }
                .padding(.bottom, 30)
            }
            .background(pageBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showLoginSheet) {
                WelcomeView()
            }
        }
    }
}

// MARK: - Header
private extension NeighborhoodServicesView {
    
    var header: some View {
        VStack(spacing: 4) {
            ZStack {
                Text(vm.neighborhoodName)
                    .scaledFont(size: 34, weight: .regular, relativeTo: .largeTitle)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            dismiss()
                        }
                    } label: {
                        // chevron.backward يغير اتجاهه تلقائياً حسب اللغة
                        Image(systemName: "chevron.backward")
                            .scaledFont(size: 18, weight: .regular, relativeTo: .headline)
                            .foregroundColor(Color("Green2Primary"))
                            .frame(width: 52, height: 52)
                            .background(Color("GreyBackground"))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
                    }

                    Spacer()

                    // ✅ زر المفضلة في النهاية (trailing)
                    // في الإنجليزي → يمين | في العربي → يسار (تلقائي)
                    Button {
                        if Auth.auth().currentUser != nil {
                            vm.toggleFavorite()
                        } else {
                            showLoginSheet = true
                        }
                    } label: {
                        Image(systemName: vm.isFavorite ? "heart.fill" : "heart")
                            .scaledFont(size: 18, weight: .regular, relativeTo: .headline)
                            .foregroundColor(Color("Green2Primary"))
                            .frame(width: 52, height: 52)
                            .background(Color("GreyBackground"))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
                    }
                }
                .padding(.horizontal, 20)
            }

            HStack(spacing: 4) {
                Text("(\(vm.reviewsCount))")
                    .scaledFont(size: 14, weight: .regular, relativeTo: .caption1)
                    .foregroundColor(.secondary)

                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                }
            }
            .padding(.top, -5)

            // 4. بطاقة السعر
            AvgPriceBadgeView(
                neighborhoodName: vm.neighborhoodName,
                aliases: []
            )
            .padding(.horizontal, 24)
            .padding(.top, 10)
        }
        .padding(.top, 10)
    }
}

// MARK: - Helper Sections
private extension NeighborhoodServicesView {
    
    var reviewComposerSection: some View {
        VStack(spacing: 12) {
            subsectionHint("review_type_hint")
            chipsRow
            reviewInputBox
        }
    }
    
    func sectionTitle(_ text: String) -> some View {
        Text(LocalizedStringKey(text))
            .scaledFont(size: 22, weight: .regular, relativeTo: .title3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .foregroundStyle(.primary)
    }
    
    func subsectionHint(_ text: String) -> some View {
        Text(LocalizedStringKey(text))
            .scaledFont(size: 17, weight: .regular, relativeTo: .body)
            .foregroundStyle(hintGray)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
    }
}

// MARK: - Services Grid
private extension NeighborhoodServicesView {

    var servicesGrid: some View {
        LazyVGrid(columns: grid, spacing: 18) {
            ForEach(vm.services) { service in
                NavigationLink {
                    ServiceListView(vm: vm, service: service)
                        .task { await vm.loadPlacesIfNeeded(for: service) }
                } label: {
                    serviceTile(service)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
    }

    func serviceTile(_ service: ServiceCategory) -> some View {
        VStack(spacing: 6) {
            Image(systemName: service.fallbackSystemSymbol ?? service.icon.systemName)
                .font(.system(size: tileIconSize))
                .foregroundStyle(service.iconColor(using: greenPrimary, yellowHex: yellowHex))

            Text(LocalizedStringKey(service.rawValue))
                .font(.system(size: tileTextSize))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: tileSize, height: tileSize)
        .background(Color("GreyBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 8)
    }
}

// MARK: - Review Composer Logic
private extension NeighborhoodServicesView {

    var chipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ReviewCategory.allCases) { cat in
                    Text(LocalizedStringKey(cat.rawValue))
                        .scaledFont(size: 17, weight: .regular, relativeTo: .body)
                        .foregroundStyle(vm.selectedCategory == cat ? Color.white : Color.primary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(vm.selectedCategory == cat ? primaryColor : Color("GreyBackground"))
                        .overlay(Capsule().stroke(borderGray, lineWidth: 1))
                        .clipShape(Capsule())
                        .onTapGesture { vm.selectedCategory = cat }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 4)
            .padding(.bottom, 6)
        }
    }

    var reviewInputBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color("GreyBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(borderGray, lineWidth: 1)
                )

            ZStack(alignment: .topTrailing) {
                HStack(alignment: .top) {
                    if vm.newComment.isEmpty {
                        Text("comment_placeholder")
                            .scaledFont(size: 17, weight: .regular, relativeTo: .body)
                            .foregroundStyle(hintGray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 5)
                    } else {
                        Spacer(minLength: 0)
                    }

                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: "star.fill")
                                .scaledFont(size: 22, weight: .regular, relativeTo: .title3)
                                .foregroundStyle(i <= vm.newRating ? Color.yellow : Color.gray.opacity(0.35))
                                .onTapGesture { vm.newRating = i }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 2)

                TextEditor(text: $vm.newComment)
                    .scaledFont(size: 16, weight: .regular, relativeTo: .body)
                    .focused($isCommentFocused)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding(.top, 30)
                    .foregroundStyle(.primary)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            if Auth.auth().currentUser != nil {
                                vm.addReview()
                                isCommentFocused = false
                            } else {
                                isCommentFocused = false
                                showLoginSheet = true
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 30, height: 30)
                                .background(primaryColor)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(18)
        }
        .frame(height: 146)
        .padding(.horizontal, 24)
        .contentShape(Rectangle())
        .onTapGesture {
            if Auth.auth().currentUser != nil {
                isCommentFocused = true
            } else {
                showLoginSheet = true
            }
        }
    }
}

// MARK: - Comments List
private extension NeighborhoodServicesView {

    var commentsList: some View {
        VStack(spacing: 14) {
            ForEach(vm.reviews) { review in
                commentCard(review)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 4)
    }

    func commentCard(_ review: NeighborhoodReview) -> some View {
        // ✅ إصلاح: alignment: .leading بدل .trailing
        //    SwiftUI يقلب leading/trailing تلقائياً في RTL
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .scaledFont(size: 18, weight: .regular, relativeTo: .headline)
                            .foregroundStyle(i <= review.rating ? Color.yellow : Color.gray.opacity(0.35))
                    }
                }
                Spacer()
                // ✅ إصلاح: LocalizedStringKey بدل rawValue مباشرة
                Text(LocalizedStringKey(review.category.rawValue))
                    .scaledFont(size: 17, weight: .regular, relativeTo: .body)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(primaryColor)
                    .clipShape(Capsule())
            }

            Text(review.comment)
                .scaledFont(size: 17, weight: .regular, relativeTo: .body)
                .foregroundStyle(.primary)
                // ✅ إصلاح: حذف .multilineTextAlignment(.trailing) و offset(x: -7)
                //    SwiftUI يتولى محاذاة النص تلقائياً
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(relativeDate(review.createdAt))
                .scaledFont(size: 14, weight: .regular, relativeTo: .caption1)
                .foregroundStyle(hintGray)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color("GreyBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 8)
    }

    func relativeDate(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        // ✅ إصلاح: .current بدل Locale(identifier: "ar") الثابت
        //    يتبع لغة الجهاز تلقائياً
        f.locale = .current
        f.unitsStyle = .full
        return f.localizedString(for: date, relativeTo: Date())
    }
}

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

private extension ServiceCategory {
    func iconColor(using greenPrimary: Color, yellowHex: Color) -> Color {
        switch self {
        case .libraries, .gasStations, .groceries:
            return greenPrimary
        case .hospitals, .mall, .parks:
            return Color("BlueSecondary")
        case .cafes, .supermarkets, .metro:
            return Color("PurpleSecondary")
        case .cinema, .restaurants, .schools:
            return yellowHex
        }
    }
}

#Preview {
    NeighborhoodServicesView(
        neighborhoodName: "اسم الحي",
        coordinate: .init(latitude: 0.0, longitude: 0.0)
    )
    .environment(\.locale, .init(identifier: "ar"))
}
#Preview {
    NeighborhoodServicesView(
        neighborhoodName: "Al wrood",
        coordinate: .init(latitude: 0.0, longitude: 0.0)
    )
    .environment(\.locale, .init(identifier: "en"))
}
