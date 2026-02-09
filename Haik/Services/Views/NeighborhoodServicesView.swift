import SwiftUI

struct NeighborhoodServicesView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: NeighborhoodServicesViewModel

    private let greenPrimary = Color("GreenPrimary")
    private let pageBackground = Color("PageBackground")

    private let grid = [
        GridItem(.flexible(), spacing: 20, alignment: .top),
        GridItem(.flexible(), spacing: 20, alignment: .top),
        GridItem(.flexible(), spacing: 20, alignment: .top)
    ]

    init(neighborhood: Neighborhood) {
        _vm = StateObject(wrappedValue: NeighborhoodServicesViewModel(neighborhood: neighborhood))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {

                header

                Text("الخدمات")
                    .font(.system(size: 22, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)

                LazyVGrid(columns: grid, alignment: .trailing, spacing: 24) {
                    ForEach(vm.services) { service in
                        NavigationLink {
                            ServiceListView(neighborhood: vm.neighborhood, service: service)
                        } label: {
                            serviceTile(service)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 6)
            }
            .padding(.bottom, 30)
        }
        .background(pageBackground.ignoresSafeArea())
        .environment(\.layoutDirection, .rightToLeft)
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(greenPrimary)
                    .frame(width: 56, height: 56)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
            }

            Spacer()

            Text("حي \(vm.neighborhood.name)")
                .font(.system(size: 34, weight: .regular))
                .foregroundStyle(.black)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }

    private func serviceTile(_ service: ServiceCategory) -> some View {
        VStack(spacing: 6) {
            Image(systemName: service.systemIconName)
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(service.iconColor())
                .frame(width: 80, height: 80)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)

            Text(service.rawValue)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.black)
                .frame(width: 80)
                .multilineTextAlignment(.center)
        }
    }
}
