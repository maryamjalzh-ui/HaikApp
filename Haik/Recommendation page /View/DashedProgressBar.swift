import SwiftUI

struct DashedProgressBar: View {

    let total: Int
    let current: Int

    var body: some View {
        GeometryReader { geo in
            let maxW = min(geo.size.width, DS.progressBarMaxWidth)
            let spacing = DS.progressSpacing
            let count = max(1, total)
            let segmentW = (maxW - (spacing * CGFloat(count - 1))) / CGFloat(count)

            HStack(spacing: spacing) {
                ForEach(1...count, id: \.self) { step in
                    let isFilled = step <= current

                    RoundedRectangle(cornerRadius: DS.progressCornerRadius, style: .continuous)
                        .fill(isFilled ? Color("Green2Primary") : .white)
                        .frame(width: segmentW, height: DS.progressHeight)
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.progressCornerRadius, style: .continuous)
                                .stroke(Color("Green2Primary"), lineWidth: 1)
                        )
                }
            }
            .frame(width: maxW, alignment: .center)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: DS.progressHeight)
        .padding(.horizontal, 26)
    }
}
