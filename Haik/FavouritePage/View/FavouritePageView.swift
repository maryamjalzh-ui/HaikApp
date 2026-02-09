//
//  SwiftUIView.swift
//  Haik
//
//  Created by Maryam Jalal Alzahrani on 21/08/1447 AH.
//


import SwiftUI

struct FavoritePage: View {

    private let items: [FavItem] = [
        .init(title: "حي الياسمين", rating: 5, reviews: 29),
        .init(title: "حي الياسمين", rating: 5, reviews: 29)
    ]

    private let commentText = "حي جيد وهادي لكن الشوارع مكسرة من الجهه العلوية"
    private let commentRating = 4

    var body: some View {
        ZStack {
            Image("Building")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.18)

            Color("PageBackground")
                .opacity(0.80) // خففتها عشان تبان Building
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    header
                        .padding(.top, 18)

                    ForEach(items) { item in
                        FavoriteCard(item: item)
                    }

                    commentsHeader
                        .padding(.top, 8)

                    CommentCard(text: commentText, rating: commentRating)

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 30)
            }
        }
        // هذا يمنع قص الهيدر تحت الـ notch
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 1)
        }
        // أهم سطرين لحل مشكلة القص بسبب NavigationStack
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "bookmark")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color("GreenPrimary"))

            Spacer()

            Text("الأحياء المحفوظة:")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.black)
        }
    }

    private var commentsHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: "text.bubble")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color("GreenPrimary"))

            Text("تعليقاتك:")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.black)

            Spacer()
        }
    }
}

private struct FavoriteCard: View {
    let item: FavItem

    var body: some View {
        VStack(spacing: 18) {
            HStack(alignment: .top) {
                Text(item.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.black)

                Spacer()

                HStack(spacing: 10) {
                    StarRow(count: 5, filled: item.rating, size: 26)
                    Text("\(item.reviews)")
                        .font(.system(size: 18))
                        .foregroundStyle(.gray.opacity(0.75))
                }
            }

            HStack(spacing: 10) {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color("GreenPrimary"))

                Text("لمزيد من المعلومات عن الحي")
                    .font(.system(size: 18))
                    .foregroundStyle(.black.opacity(0.65))

                Spacer()
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color("Green2Primary").opacity(0.18), lineWidth: 1)
        )
    }
}

private struct CommentCard: View {
    let text: String
    let rating: Int

    var body: some View {
        VStack(spacing: 14) {
            // دائرة الحساب في المنتصف فوق
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 54, height: 54)
                    .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 10)

                Image(systemName: "person")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.8))
            }
            .padding(.top, 6)

            VStack(alignment: .trailing, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("مجهول")
                            .font(.system(size: 16))
                            .foregroundStyle(.gray.opacity(0.7))
                        Text("العارض")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.black.opacity(0.85))
                    }

                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 18))
                        .foregroundStyle(.gray.opacity(0.55))

                    Spacer()
                }

                Text(text)
                    .font(.system(size: 22))
                    .foregroundStyle(.black.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                HStack {
                    StarRow(count: 5, filled: rating, size: 34)
                    Spacer()
                }
                .padding(.top, 4)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color.white.opacity(0.55))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .frame(maxWidth: .infinity)
    }
}

private struct StarRow: View {
    let count: Int
    let filled: Int
    let size: CGFloat

    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...count, id: \.self) { i in
                Image(systemName: i <= filled ? "star.fill" : "star")
                    .font(.system(size: size, weight: .bold))
                    .foregroundStyle(Color("YellowSecondary"))
            }
        }
    }
}

private struct FavItem: Identifiable {
    let id = UUID()
    let title: String
    let rating: Int
    let reviews: Int
}

#Preview {
    NavigationStack {
        FavoritePage()
    }
}
