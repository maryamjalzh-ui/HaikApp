import SwiftUI
import CoreLocation

struct NeighborhoodServicesView: View {

    private let greenPrimary = Color("GreenPrimary")
    private let pageBackground = Color("PageBackground")
    private let borderGray = Color(hex: "DBDBDB")
    private let hintGray = Color(hex: "ACACAC")
    private let yellowHex = Color(hex: "E7CB62")

    @StateObject private var vm: NeighborhoodServicesViewModel

    private let grid = [
        GridItem(.flexible(), spacing: 22),
        GridItem(.flexible(), spacing: 22),
        GridItem(.flexible(), spacing: 22)
    ]

    init(neighborhoodName: String, coordinate: CLLocationCoordinate2D) {
        _vm = StateObject(wrappedValue: NeighborhoodServicesViewModel(neighborhoodName: neighborhoodName, coordinate: coordinate))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    header

                    Text("الخدمات")
                        .font(.system(size: 22, weight: .regular))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 24)
                        .padding(.top, 4)

                    servicesGrid

                    Text("التقييمات والتعليقات")
                        .font(.system(size: 22, weight: .regular))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 18)

                    Text("نوع التعليق")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(hintGray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 24)

                    chipsRow
                    reviewInputBox

                    Text("التعليقات")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(hintGray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 24)
                        .padding(.top, 10)

                    commentsList
                }
                .padding(.bottom, 30)
            }
            .background(pageBackground.ignoresSafeArea())
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var header: some View {
        HStack {
            Button { } label: {
                Image(systemName: "bookmark")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.black)
                    .frame(width: 52, height: 52)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
            }

            Spacer()

            Text(vm.neighborhoodName)
                .font(.system(size: 34, weight: .regular))
                .foregroundStyle(.black)

            Spacer()

            Button { } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(greenPrimary)
                    .frame(width: 52, height: 52)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }

    private var servicesGrid: some View {
        LazyVGrid(columns: grid, spacing: 22) {
            ForEach(vm.services) { service in
                NavigationLink {
                    ServiceListView(vm: vm, service: service)
                        .task {
                            await vm.loadPlacesIfNeeded(for: service)
                        }
                } label: {
                    serviceTile(service)
                }
                .buttonStyle(.plain)
                .task {
                    await vm.loadPlacesIfNeeded(for: service)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 6)
    }


    private func serviceTile(_ service: ServiceCategory) -> some View {
        VStack(spacing: 10) {
            if let fallback = service.fallbackSystemSymbol {
                Image(systemName: fallback)
                    .font(.system(size: 34, weight: .regular))
                    .foregroundStyle(service.iconColor(using: greenPrimary, yellowHex: yellowHex))
            } else {
                Image(systemName: service.icon.systemName)
                    .font(.system(size: 34, weight: .regular))
                    .foregroundStyle(service.iconColor(using: greenPrimary, yellowHex: yellowHex))
            }

            Text(service.rawValue)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.gray.opacity(0.75))
        }
        .frame(width: 108, height: 108)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 10)
    }

    private var chipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ReviewCategory.allCases) { cat in
                    Text(cat.rawValue)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(vm.selectedCategory == cat ? Color.white : greenPrimary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(vm.selectedCategory == cat ? greenPrimary : Color.white)
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

    private var reviewInputBox: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(borderGray, lineWidth: 1))
                .frame(width: 355, height: 146)

            if vm.newComment.isEmpty {
                Text("اكتب تعليقك...")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(hintGray)
                    .padding(.top, 16)
                    .padding(.trailing, 18)
            }

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(i <= vm.newRating ? Color.yellow : Color.gray.opacity(0.35))
                        .onTapGesture { vm.newRating = i }
                }
                Spacer()
            }
            .padding(.top, 16)
            .padding(.leading, 18)
            .frame(width: 355)

            TextEditor(text: $vm.newComment)
                .font(.system(size: 16, weight: .regular))
                .padding(.horizontal, 14)
                .padding(.top, 44)
                .frame(width: 355, height: 146)
                .scrollContentBackground(.hidden)
                .background(Color.clear)

            VStack {
                Spacer()
                HStack {
                    Button { vm.addReview() } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 52, height: 52)
                            .background(greenPrimary)
                            .clipShape(Circle())
                    }
                    .padding(.leading, 14)
                    .padding(.bottom, 14)

                    Spacer()
                }
            }
            .frame(width: 355, height: 146)
        }
        .padding(.top, 6)
    }

    private var commentsList: some View {
        VStack(spacing: 14) {
            ForEach(vm.reviews) { r in
                commentCard(r)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 4)
    }

    private func commentCard(_ review: NeighborhoodReview) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(i <= review.rating ? Color.yellow : Color.gray.opacity(0.35))
                    }
                }

                Spacer()

                Text(review.category.rawValue)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(greenPrimary)
                    .overlay(Capsule().stroke(borderGray, lineWidth: 1))
                    .clipShape(Capsule())
            }

            Text(review.comment)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.black)

            Text(relativeDate(review.createdAt))
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(hintGray)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 8)
    }

    private func relativeDate(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "ar")
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
        case .parks, .libraries, .gasStations, .groceries:
            return greenPrimary
        case .metro, .hospitals:
            return Color("BlueSecondary")
        case .cafes, .universities, .supermarkets:
            return Color("PurpleSecondary")
        case .cinema, .restaurants, .schools:
            return yellowHex
        }
    }
}
