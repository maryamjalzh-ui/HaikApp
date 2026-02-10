import SwiftUI
import CoreLocation

struct NeighborhoodServicesView: View {

    // MARK: - Colors
    private let greenPrimary = Color("GreenPrimary")
    private let primaryColor = Color("Green2Primary")
    private let pageBackground = Color("PageBackground")
    private let borderGray = Color(hex: "DBDBDB")
    private let hintGray = Color(hex: "ACACAC")
    private let yellowHex = Color(hex: "E7CB62")

    // MARK: - Grid
    private let grid = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18)
    ]

    // MARK: - Tile Size
    private let tileSize: CGFloat = 92
    private let tileIconSize: CGFloat = 30
    private let tileTextSize: CGFloat = 14

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: NeighborhoodServicesViewModel
    @FocusState private var isCommentFocused: Bool

    init(neighborhoodName: String, coordinate: CLLocationCoordinate2D) {
        _vm = StateObject(
            wrappedValue: NeighborhoodServicesViewModel(
                neighborhoodName: neighborhoodName,
                coordinate: coordinate
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    header

                    sectionTitle("الخدمات")
                    servicesGrid

                    sectionTitle("التقييمات والتعليقات")
                    subsectionHint("نوع التعليق")

                    chipsRow
                    reviewInputBox

                    subsectionHint("التعليقات")
                    commentsList
                }
                .padding(.bottom, 30)
            }
            .background(pageBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - Header
private extension NeighborhoodServicesView {

    var header: some View {
        ZStack {
            Text(vm.neighborhoodName)
                .font(.system(size: 34))
                .foregroundStyle(.black)
                .lineLimit(1)
                .padding(.horizontal, 90)

            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 18))
                        .foregroundStyle(.black)
                        .frame(width: 52, height: 52)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
                }

                Spacer()

                Button { } label: {
                    Image(systemName: "bookmark")
                        .font(.system(size: 18))
                        .foregroundStyle(.black)
                        .frame(width: 52, height: 52)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
                }
            }
            .padding(.horizontal, 20)
            .environment(\.layoutDirection, .leftToRight)
        }
        .padding(.top, 10)
    }
}

// MARK: - Section Titles (Force visual RIGHT)
private extension NeighborhoodServicesView {

    func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 22))
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 24)
            .environment(\.layoutDirection, .leftToRight) // يثبتها يمين بصريًا
    }

    func subsectionHint(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17))
            .foregroundStyle(hintGray)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 24)
            .environment(\.layoutDirection, .leftToRight) // يثبتها يمين بصريًا
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

            Text(service.rawValue)
                .font(.system(size: tileTextSize))
                .foregroundStyle(Color.gray.opacity(0.75))
                .lineLimit(1)
        }
        .frame(width: tileSize, height: tileSize)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 8)
    }
}

// MARK: - Review Input
private extension NeighborhoodServicesView {

    var chipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ReviewCategory.allCases) { cat in
                    Text(cat.rawValue)
                        .font(.system(size: 17))
                        .foregroundStyle(vm.selectedCategory == cat ? .white : .black)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(vm.selectedCategory == cat ? primaryColor : .white)
                        .overlay(Capsule().stroke(borderGray))
                        .clipShape(Capsule())
                        .onTapGesture { vm.selectedCategory = cat }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    var reviewInputBox: some View {
        ZStack(alignment: .topTrailing) {

            RoundedRectangle(cornerRadius: 22)
                .fill(.white)
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(borderGray))
                .frame(height: 146)

            // Placeholder (Right)
            if vm.newComment.isEmpty {
                Text("اكتب تعليقك...")
                    .font(.system(size: 17))
                    .foregroundStyle(hintGray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 16)
                    .padding(.trailing, 18)
                    .environment(\.layoutDirection, .rightToLeft) 
            }

            // Stars (Top-Left inside box)
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(i <= vm.newRating ? .yellow : .gray.opacity(0.35))
                        .onTapGesture { vm.newRating = i }
                }
            }
            .environment(\.layoutDirection, .leftToRight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 16)
            .padding(.leading, 18)

            // TextEditor (Right aligned)
            TextEditor(text: $vm.newComment)
                .font(.system(size: 16))
                .padding(.horizontal, 14)
                .padding(.top, 44)
                .focused($isCommentFocused)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .environment(\.layoutDirection, .rightToLeft) // هذا السطر هو الحل


            // Plus (inside border, bottom-right)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        vm.addReview()
                        isCommentFocused = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(primaryColor)
                            .clipShape(Circle())
                    }
                }
                .padding(.trailing, 18)
                .padding(.bottom, 18)
            }
        }
        .padding(.horizontal, 24)
        .onTapGesture { isCommentFocused = true }
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
    }

    func commentCard(_ review: NeighborhoodReview) -> some View {
        VStack(alignment: .trailing, spacing: 10) {

            // Top row: Stars left, Category right (inside card)
            HStack {
                HStack(spacing: 6) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(i <= review.rating ? .yellow : .gray.opacity(0.35))
                    }
                }

                Spacer()

                Text(review.category.rawValue)
                    .font(.system(size: 17))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(primaryColor)
                    .clipShape(Capsule())
            }
            .environment(\.layoutDirection, .leftToRight) // يثبت: نجوم يسار + تصنيف يمين

            // Comment text (Right)
            Text(review.comment)
                .font(.system(size: 17))
                .foregroundStyle(.black)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)

            // Date (Right)
            Text(relativeDate(review.createdAt))
                .font(.system(size: 14))
                .foregroundStyle(hintGray)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 8)
    }

    func relativeDate(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "ar")
        return f.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Helpers
private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(
            .sRGB,
            red: Double((int >> 16) & 0xFF) / 255,
            green: Double((int >> 8) & 0xFF) / 255,
            blue: Double(int & 0xFF) / 255,
            opacity: 1
        )
    }
}

private extension ServiceCategory {
    func iconColor(using greenPrimary: Color, yellowHex: Color) -> Color {
        switch self {
        case .parks, .libraries, .gasStations, .groceries: return greenPrimary
        case .metro, .hospitals: return Color("BlueSecondary")
        case .cafes, .mall, .supermarkets: return Color("PurpleSecondary")
        case .cinema, .restaurants, .schools: return yellowHex
        }
    }
}
