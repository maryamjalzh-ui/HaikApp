import SwiftUI

struct ServiceListView: View {

    let neighborhood: Neighborhood
    let service: ServiceCategory

    @StateObject private var vm: ServicesListViewModel
    private let pageBackground = Color("PageBackground")

    init(neighborhood: Neighborhood, service: ServiceCategory) {
        self.neighborhood = neighborhood
        self.service = service
        _vm = StateObject(wrappedValue: ServicesListViewModel(neighborhood: neighborhood, service: service))
    }

    var body: some View {
        VStack(spacing: 12) {

            HStack {
                Spacer()
                Text(vm.title)
                    .font(.system(size: 26, weight: .regular))
                    .foregroundStyle(.black)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            if vm.isLoading {
                ProgressView()
                    .padding(.top, 30)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(vm.places) { place in
                            Button {
                                vm.selectedPlace = place
                            } label: {
                                placeRow(place)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(pageBackground.ignoresSafeArea())
        .environment(\.layoutDirection, .rightToLeft)
        .task {
            await vm.load()
        }
        .sheet(item: $vm.selectedPlace) { place in
            PlaceDetailsSheetView(place: place, service: service)
                .presentationDetents([.medium, .large])
        }
    }

    private func placeRow(_ place: Place) -> some View {
        HStack(spacing: 12) {

            VStack(alignment: .trailing, spacing: 6) {
                Text(place.name)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text(place.address)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineLimit(2)
            }

            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.gray.opacity(0.7))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
    }
}
