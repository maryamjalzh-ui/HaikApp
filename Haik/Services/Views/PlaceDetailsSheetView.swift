import SwiftUI

struct PlaceDetailsSheetView: View {

    let place: Place
    let service: ServiceCategory

    private let greenPrimary = Color("GreenPrimary")
    private let blueSecondary = Color("BlueSecondary")

    var body: some View {
        VStack(spacing: 16) {

            Capsule()
                .fill(Color.gray.opacity(0.25))
                .frame(width: 50, height: 6)
                .padding(.top, 10)

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(i <= place.rating ? Color.yellow : Color.gray.opacity(0.35))
                }
                Spacer()
            }
            .padding(.horizontal, 20)

            HStack {
                Text(place.isOpen ? "مفتوح" : "مغلق")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(place.isOpen ? greenPrimary : Color.gray)
                    .clipShape(Capsule())

                Spacer()

                Text(place.name)
                    .font(.system(size: 26))
                    .foregroundStyle(.black)

                Image(systemName: service.systemIconName)
                    .font(.system(size: 34))
                    .foregroundStyle(service.iconColor())
                    .frame(width: 66, height: 66)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 8)
            }
            .padding(.horizontal, 20)

            Button { } label: {
                HStack(spacing: 10) {
                    Image(systemName: "paperplane")
                        .font(.system(size: 20))
                    Text("خذني للموقع")
                        .font(.system(size: 20))
                }
                .foregroundStyle(blueSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .environment(\.layoutDirection, .rightToLeft)
        .background(Color.white)
    }
}
