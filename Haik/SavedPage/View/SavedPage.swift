//
//  SavedPage.swift
//  Haik
//
//  Created by Maryam Jalal Alzahrani on 21/08/1447 AH.
//


//
//  SwiftUIView.swift
//  Haik
//
//  Created by Maryam Jalal Alzahrani on 21/08/1447 AH.
//
import SwiftUI

struct FavouritePage: View {
    var body: some View {
        ZStack {
            // 1. الخلفية الأساسية (اللون)
            Color(white: 0.97).ignoresSafeArea()
            
            // 2. صورة الخلفية (Building)
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    Image("Building")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                        .allowsHitTesting(false)
                }
            }
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .center, spacing: 25) {
                    
                    // العنوان العلوي (الأيقونة أولاً على اليمين ثم النص)
                    HeaderSection(title: "الأحياء المحفوظة:", icon: "bookmark")
                        .padding(.horizontal)

                    // قائمة الأحياء
                    VStack(spacing: 16) {
                        NeighborhoodCard(name: "حي الياسمين")
                        NeighborhoodCard(name: "حي الياسمين")
                    }
                    
                    // قسم التعليقات (الأيقونة أولاً على اليمين ثم النص)
                    HeaderSection(title: "تعليقاتك:", icon: "text.bubble")
                        .padding(.horizontal)
                        .padding(.top, 150)

                    // كارت التعليق مع إضافة الأسهم يمين ويسار
                    HStack(spacing: 15) {
                        // سهم لليمين (رمادي فاتح)
                        Image(systemName: "arrow.right")
                            .foregroundColor(.gray.opacity(0.3))
                            .font(.system(size: 20, weight: .bold))

                        CommentCard()

                        // سهم لليسار (أخضر Primary)
                        Image(systemName: "arrow.left")
                            .foregroundColor(Color("GreenPrimary"))
                            .font(.system(size: 20, weight: .bold))
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// مكون العناوين المعدل (الأيقونة خضراء والنص أسود)
struct HeaderSection: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            // الأيقونة باللون الأخضر
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("GreenPrimary"))
            
            // النص باللون الأسود
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
        }
    }
}

// كارت الحي المحدث
struct NeighborhoodCard: View {
    var name: String
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack {
                Text(name)
                    .font(.system(size: 24, weight: .bold))
                Spacer()
                HStack(spacing: 4) {
                    Text("29")
                        .font(.caption)
                        .foregroundColor(.gray)
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                    }
                }
            }
            
            Spacer()
            
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                    Text("لمزيد من المعلومات عن الحي")
                        .foregroundColor(.black)
                        .font(.system(size: 14))
                }
                .foregroundColor(Color("GreenPrimary"))
                
                Spacer()
            }
            .environment(\.layoutDirection, .leftToRight)
        }
        .padding(20)
        .frame(width: 333, height: 149)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

// كارت التعليق
struct CommentCard: View {
    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack {
                HStack(spacing: 12) {
                    Image("PersonIcon")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFill()
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text("مجهول")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.6))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption)
                            Text("العارض")
                                .font(.callout)
                                .foregroundColor(.black)
                        }
                        .foregroundColor(.gray)
                    }
                }
                .environment(\.layoutDirection, .rightToLeft)
                
                Spacer()
            }
            
            Text("حي جيد وهادي لكن الشوارع مكسره من الجهه العلوية")
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.8))
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
            
            HStack(spacing: 2) {
                ForEach(0..<4) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding()
        .frame(width: 300) // قمت بتعديل العرض قليلاً ليناسب وجود الأسهم بجانبه في الشاشة
        .background(Color.white.opacity(0.6))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        FavouritePage()
    }
}
