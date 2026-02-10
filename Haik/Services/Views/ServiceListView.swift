import SwiftUI
import MapKit

struct ServiceListView: View {

    // MARK: - Dependencies
    @ObservedObject var vm: NeighborhoodServicesViewModel
    let service: ServiceCategory

    // MARK: - Styling
    private let pageBackground = Color("PageBackground")
    private let greenPrimary = Color("GreenPrimary")
    private let blueSecondary = Color("BlueSecondary")
    private let purpleSecondary = Color("PurpleSecondary")
    private let yellowHex = Color("yellow") // from Assets (no Color(hex:))

    private let rowWidth: CGFloat = 348
    private let rowHeight: CGFloat = 69
    private let rowCorner: CGFloat = 24

    // MARK: - Data
    private var places: [Place] { vm.places(for: service) }
    private var isLoading: Bool { vm.isLoadingByService.contains(service) }

    // MARK: - Navigation
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body
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
                                placeRow(place)
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
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task { await vm.loadPlacesIfNeeded(for: service) }
    }

    // MARK: - Header (Chevron on RIGHT)
    private var header: some View {
        ZStack {
            Text(service.rawValue)
                .font(.system(size: 30, weight: .regular))
                .foregroundStyle(.black)
                .lineLimit(1)
                .padding(.horizontal, 90)

            HStack {
                Color.clear
                    .frame(width: 52, height: 52)

                Spacer()

                Button { dismiss() } label: {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(.black)
                        .frame(width: 52, height: 52)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                }
            }
            .padding(.horizontal, 20)
            .environment(\.layoutDirection, .leftToRight)
        }
        .padding(.top, 6)
    }

    // MARK: - Row
    private func placeRow(_ place: Place) -> some View {
        HStack {

            // Name + location icon
            HStack(spacing: 8) {
                Button { openInMaps(place) } label: {
                    Image(systemName: "location")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(blueSecondary)
                }
                .buttonStyle(.plain)

                Text(place.name)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(.black)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            // Service icon (same symbol + same color logic)
            Image(systemName: service.fallbackSystemSymbol ?? service.icon.systemName)
                .font(.system(size: 34, weight: .regular))
                .foregroundStyle(serviceIconColor(service))
                .padding(.leading, 16)
        }
        .padding(.horizontal, 18)
        .frame(width: rowWidth, height: rowHeight)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: rowCorner, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 10)
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: - Icon Color (matches Neighborhood page)
    private func serviceIconColor(_ service: ServiceCategory) -> Color {
        switch service {
        case .parks, .libraries, .gasStations, .groceries:
            return greenPrimary
        case .metro, .hospitals:
            return blueSecondary
        case .cafes, .mall, .supermarkets:
            return purpleSecondary
        case .cinema, .restaurants, .schools:
            return yellowHex
        }
    }

    // MARK: - Maps
    private func openInMaps(_ place: Place) {
        let coordinate = CLLocationCoordinate2D(
            latitude: place.coordinate.latitude,
            longitude: place.coordinate.longitude
        )

        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = place.name

        mapItem.openInMaps(
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }
}
