import SwiftUI

struct ServiceListView: View {

    @ObservedObject var vm: NeighborhoodServicesViewModel
    let service: ServiceCategory

    @State private var selectedPlace: Place? = nil

    private let pageBackground = Color("PageBackground")
    private let greenPrimary = Color("GreenPrimary")

    private let rowWidth: CGFloat = 348
    private let rowHeight: CGFloat = 69
    private let rowCorner: CGFloat = 24

    private var places: [Place] {
        vm.places(for: service)
    }

    private var isLoading: Bool {
        vm.isLoadingByService.contains(service)
    }

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()

            VStack(spacing: 18) {
                header

                if isLoading && places.isEmpty {
                    ProgressView()
                        .padding(.top, 30)
                } else if places.isEmpty {
                    Text("لا توجد نتائج حالياً")
                        .foregroundStyle(.gray)
                        .padding(.top, 30)
                } else {
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 18) {
                            ForEach(places) { place in
                                Button {
                                    selectedPlace = place
                                } label: {
                                    placeRow(place)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 20)
                    }
                }

                Spacer()
            }
            .padding(.top, 10)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .navigationBarBackButtonHidden(true)
        .sheet(item: $selectedPlace) { place in
            PlaceDetailSheetView(place: place, service: service)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .task {
            await vm.loadPlacesIfNeeded(for: service)
        }
    }

    private var header: some View {
        ZStack {
            HStack {
                BackCircleButton(tint: greenPrimary)
                Spacer()
            }

            Text(service.rawValue)
                .font(.system(size: 34, weight: .regular))
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 22)
    }

    private func placeRow(_ place: Place) -> some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(Color.gray.opacity(0.65))
                .padding(.leading, 18)

            Spacer()

            Text(place.name)
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(.black)

            serviceIcon
                .font(.system(size: 34, weight: .regular))
                .foregroundStyle(greenPrimary)
                .padding(.trailing, 18)
        }
        .frame(width: rowWidth, height: rowHeight)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: rowCorner, style: .continuous))
        .shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 10)
    }

    private var serviceIcon: Image {
        if let fallback = service.fallbackSystemSymbol {
            return Image(systemName: fallback)
        }
        return Image(systemName: service.icon.systemName)
    }
}

private struct BackCircleButton: View {
    @Environment(\.dismiss) private var dismiss
    let tint: Color

    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "arrow.right")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(tint)
                .frame(width: 56, height: 56)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
        }
    }
}
