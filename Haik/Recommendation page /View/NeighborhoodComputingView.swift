//
//  NeighborhoodComputingView.swift
//  Haik
//
//  Created by Bayan Alshehri on 22/08/1447 AH.
//

import SwiftUI

struct NeighborhoodComputingView: View {
    let progress: Double // 0...1

    @State private var animate = false
    @State private var shimmerX: CGFloat = -220

    var body: some View {
        VStack(spacing: 18) {

            Spacer()

            ZStack {
                // Base logo (slight breathing)
                Image("HaikLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                    .scaleEffect(animate ? 1.02 : 0.98)
                    .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: animate)

                // Shimmer overlay (gives “movement” vibe)
                Image("HaikLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                    .overlay(
                        LinearGradient(
                            colors: [
                                .clear,
                                Color.white.opacity(0.25),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(width: 70)
                        .rotationEffect(.degrees(20))
                        .offset(x: shimmerX)
                        .blendMode(.screen)
                    )
                    .mask(
                        Image("HaikLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180)
                    )
                    .onAppear {
                        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                            shimmerX = 220
                        }
                    }
            }
            .padding(.bottom, 10)

            Text("جاري حساب أفضل الأحياء لك…")
                .scaledFont(size: 20, weight: .bold, relativeTo: .headline)                .multilineTextAlignment(.center)

            Text("\(Int(progress * 100))%")
                .scaledFont(size: 18, weight: .medium, relativeTo: .body)                .foregroundStyle(.gray)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("GreyBackground"))
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear { animate = true }
    }
}
