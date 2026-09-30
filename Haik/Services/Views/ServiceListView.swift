import SwiftUI
import MapKit
import FirebaseAuth

struct ServiceListView: View {

    // MARK: - Dependencies
    @ObservedObject var vm: NeighborhoodServicesViewModel
    let service: ServiceCategory

    // MARK: - Styling (نفس تصميمك بالضبط)
    private let pageBackground = Color("PageBackground")
    private let greenPrimary = Color("GreenPrimary")
    private let blueSecondary = Color("BlueSecondary")
    private let purpleSecondary = Color("PurpleSecondary")
    private let yellowHex = Color("yellow")

    private let rowWidth: CGFloat = 348
    private let rowHeight: CGFloat = 69
    private let rowCorner: CGFloat = 24

    // MARK: - Data
    private var places: [Place] { vm.places(for: service) }
    private var isLoading: Bool { vm.isLoadingByService.contains(service) }

    // MARK: - Navigation
    @Environment(\.dismiss) private var dismiss
    @State private var showLoginSheet = false

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()

            VStack(spacing: 18) {
                header
                
                if isLoading && places.isEmpty {
                    ProgressView().padding(.top, 30)
                } else if places.isEmpty {
                    Text("services_no_results")
                        .foregroundStyle(.secondary)
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
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showLoginSheet) {
            WelcomeView().presentationDetents([.medium, .large])
        }
        .task { await vm.loadPlacesIfNeeded(for: service) }
    }

    // MARK: - Header (دعم انعكاس الاتجاه)
    private var header: some View {
        ZStack {
            Text(LocalizedStringKey(service.rawValue))
                .scaledFont(size: 30, weight: .regular, relativeTo: .title1)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 80)

            HStack {
                // زر العودة: صار "backward" عشان يلف معك يمين ويسار حسب اللغة
                Button { dismiss() } label: {
                    Image(systemName: "chevron.backward")
                        .scaledFont(size: 18, weight: .regular, relativeTo: .headline)
                        .foregroundColor(Color("Green2Primary"))
                        .frame(width: 52, height: 52)
                        .background(Color("GreyBackground"))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
                }
                
                Spacer()
                
                // مساحة توازن
                Color.clear.frame(width: 52, height: 52)
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 6)
    }

    // MARK: - Row (نفس الديزاين مع دعم الانعكاس)
    // الصف كله ينضغط ويفتح الخرائط
    private func placeRow(_ place: Place) -> some View {
        Button { openInMaps(place) } label: {
            HStack(spacing: 12) {
                // اسم المكان ياخذ كل المساحة (يبدأ من اليمين في AR ومن اليسار في EN)
                Text(place.name)
                    .scaledFont(size: 18, weight: .regular, relativeTo: .title3)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // أيقونة اللوكيشن في آخر الصف
                Image(systemName: "location")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(blueSecondary)
                    .frame(width: 36, height: 36)
                    .background(blueSecondary.opacity(0.12))
                    .clipShape(Circle())
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .frame(width: rowWidth)
            .frame(minHeight: rowHeight)
            .background(Color("GreyBackground"))
            .clipShape(RoundedRectangle(cornerRadius: rowCorner, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: rowCorner, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }

    // دالة مساعدة للتأكد من اللغة
    private func isArabic() -> Bool {
        return Locale.current.language.languageCode?.identifier == "ar"
    }

    private func serviceIconColor(_ service: ServiceCategory) -> Color {
        switch service {
        case .libraries, .gasStations, .groceries: return greenPrimary
        case .parks, .hospitals , .mall: return blueSecondary
        case .cafes, .metro, .supermarkets: return purpleSecondary
        case .cinema, .restaurants, .schools: return yellowHex
        }
    }

    private func openInMaps(_ place: Place) {
        let coordinate = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = place.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}
