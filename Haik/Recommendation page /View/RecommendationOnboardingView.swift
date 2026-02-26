//
//  RecommendationOnboardingView.swift
//  Haik
//
//  Created by Shahad Alharbi on 2/14/26.
//

import SwiftUI

struct RecommendationOnboardingView: View {
    
    @ScaledMetric(relativeTo: .title) private var logoWidth: CGFloat = 150

    @Binding var isPresented: Bool
    @State private var page: Int = 0
    @State private var goQuestions: Bool = false

    private let sidePadding: CGFloat = 26

    var body: some View {
        NavigationStack {
            ZStack {
                Color("GreyBackground").ignoresSafeArea()

                VStack(spacing: 0) {

                    HStack {
                        Spacer()

                        Button {
                            withAnimation(.easeInOut(duration: 0.22)) {
                                if page > 0 {
                                    page -= 1
                                } else {
                                    isPresented = false
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.forward")
                                .scaledFont(size: 18, weight: .regular, relativeTo: .headline)
                                .foregroundColor(Color("Green2Primary"))
                                .frame(width: 52, height: 52)
                                .background(Color("GreyBackground"))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .environment(\.layoutDirection, .leftToRight)

                    Spacer().frame(height: 10)

                    TabView(selection: $page) {
                        pageOne.tag(0)
                        pageTwo.tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    Spacer().frame(height: 18)

                    OnboardingDots(total: 2, current: page)

                    Spacer().frame(height: 18)

                    Button {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            if page < 1 {
                                page += 1
                            } else {
                                goQuestions = true
                            }
                        }
                    } label: {
                        Text(page < 1 ? "التالي" : "بدء")
                            .scaledFont(size: 18, weight: .bold, relativeTo: .headline)                            .foregroundColor(Color("GreyBackground"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(Color("Green2Primary"))
                            .opacity(0.80)
                            .cornerRadius(25)
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 8)
                    }
                    .padding(.horizontal, sidePadding)
                    .padding(.bottom, 30)
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $goQuestions) {
                NeighborhoodRecommendationFlowView(isPresented: $isPresented)
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}

private extension RecommendationOnboardingView {

    var pageOne: some View {
        VStack(spacing: 18) {

            Spacer().frame(height: 6)

            Image("HaikLogo")
                .resizable()
                .scaledToFit()
                .frame(width: logoWidth)                .padding(.top, 10)

            Text("توصية الحي المناسب لك")
                .scaledFont(size: 28, weight: .bold, relativeTo: .title1)                .foregroundStyle(.primary)
                .padding(.top, 6)

            Text("سيتم طرح مجموعة أسئلة لتحديد تفضيلاتك، بما يشمل:")
                .scaledFont(size: 15, weight: .regular, relativeTo: .body)                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .lineSpacing(4)

            VStack(spacing: 12) {
                OnboardingInfoCard(title: "نمط الحياة", icon: "sparkles")
                OnboardingInfoCard(title: "الأولويات", icon: "slider.horizontal.3")
                OnboardingInfoCard(title: "وسيلة التنقل", icon: "tram")
                OnboardingInfoCard(title: "سعر العقار في الحي", icon: "banknote")
            }
            .padding(.horizontal, sidePadding)
            .padding(.top, 6)

            Spacer(minLength: 0)
        }
    }
}

private extension RecommendationOnboardingView {

    var pageTwo: some View {
        VStack(spacing: 16) {

            Spacer().frame(height: 6)

            Text("نتائج التوصية")
                .scaledFont(size: 28, weight: .bold, relativeTo: .title1)                .foregroundStyle(.primary)
                .padding(.top, 10)

            Text("ستظهر قائمة بالأحياء المقترحة، متضمنة نسبة التوافق وأبرز مبررات الترشيح")
                .scaledFont(size: 15, weight: .regular, relativeTo: .body)                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .lineSpacing(4)

            VStack(spacing: 14) {

                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color("GreyBackground"))

                    Image("RecommendationExample")
                        .resizable()
                        .scaledToFit()
                        .padding(16)
                }
                .frame(maxHeight: 340)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

                VStack(alignment: .trailing, spacing: 10) {
                    BulletRow(text: "إظهار نسبة التوافق لكل حي")
                    BulletRow(text: "عرض مبررات للترشيح")
                    BulletRow(text: "متوسط سعر المتر في الحي")
                    BulletRow(text: "إتاحة استعراض الخدمات المتوفرة")
                }
                .padding(.horizontal, 6)
            }
            .padding(18)
            .background(Color("GreyBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 12)
            .padding(.horizontal, 26)
            .padding(.top, 6)

            Spacer(minLength: 0)
        }
    }
}

private struct OnboardingDots: View {
    let total: Int
    let current: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                Circle()
                    .fill(i == current ? Color("Green2Primary") : Color.clear)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(Color("Green2Primary"), lineWidth: 1)
                    )
            }
        }
    }
}

private struct OnboardingInfoCard: View {

    let title: String
    let icon: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DS.cardCornerRadius, style: .continuous)
                .fill(Color("GreyBackground"))
                .cardShadow()

            HStack(spacing: 12) {

                Image(systemName: icon)
                    .font(.system(size: DS.iconSize, weight: DS.iconWeight))
                    .foregroundColor(DS.iconColor)

                Text(title)
                    .scaledFont(size: 16, weight: .semibold, relativeTo: .headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.trailing)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(height: DS.cardHeight)
    }
}

private struct BulletRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color("Green2Primary"))
                .frame(width: 6, height: 6)

            Text(text)
                .scaledFont(size: 14, weight: .medium, relativeTo: .subheadline)                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
    }
}

#Preview {
    NavigationStack {
        RecommendationOnboardingView(isPresented: .constant(true))
    }
}
