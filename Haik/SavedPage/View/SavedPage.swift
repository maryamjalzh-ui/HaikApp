//
//  SavedPage.swift
//  Haik
//
//  Created by Maryam Jalal Alzahrani on 21/08/1447 AH.
//

import SwiftUI
import MapKit

// 1. موديل التعليق
struct UserComment: Identifiable {
    let id = UUID()
    var text: String
    var rating: Double
}

struct FavouritePage: View {
    @State private var userName: String = "ساره خالد"
    @State private var userEmail: String = "SarahKhalid@example.com"
    @State private var isEditingProfile: Bool = false
    
    @State private var showServices = false
    @State private var selectedNeighborhoodName = ""
    
    @State private var comments: [UserComment] = [
        UserComment(text: "حي جيد وهادي لكن الشوارع مكسره من الجهه العلوية", rating: 4.0),
        UserComment(text: "المنطقة حيوية جداً وكل الخدمات قريبة مني، لكن الزحمة في أوقات الذروة متعبة قليلاً.", rating: 4.5)
    ]
    
    @State private var selectedCommentIndex: Int = 0
    @State private var isManagingComment: Bool = false
    @State private var draftCommentText: String = ""
    @State private var draftRating: Double = 0.0
    
    var body: some View {
        // تغليف الصفحة بـ NavigationStack لتفعيل التنقل
        NavigationStack {
            ZStack {
                Color(white: 0.97).ignoresSafeArea()
                
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
                        
                        // بطاقة الحساب
                        Button(action: { isEditingProfile = true }) {
                            HStack(spacing: 15) {
                                Image("PersonIcon")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    
                                    
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(userName)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("عرض وتعديل الملف الشخصي")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        HeaderSection(title: "الأحياء المحفوظة:", icon: "heart")
                            .padding(.horizontal)

                        // قائمة الأحياء المحفوظة مع تفعيل زر التفاصيل
                        VStack(spacing: 16) {
                            NeighborhoodCard(name: "حي الياسمين") {
                                selectedNeighborhoodName = "حي الياسمين"
                                showServices = true
                            }
                            NeighborhoodCard(name: "حي النرجس") {
                                selectedNeighborhoodName = "حي النرجس"
                                showServices = true
                            }
                        }
                        
                        HeaderSection(title: "تعليقاتك:", icon: "text.bubble")
                            .padding(.horizontal)
                            .padding(.top, 30)

                        if !comments.isEmpty {
                            HStack(spacing: 15) {
                                Button(action: {
                                    if selectedCommentIndex > 0 {
                                        withAnimation { selectedCommentIndex -= 1 }
                                    }
                                }) {
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(selectedCommentIndex == 0 ? .gray.opacity(0.3) : Color("GreenPrimary"))
                                        .font(.system(size: 20, weight: .bold))
                                }
                                .disabled(selectedCommentIndex == 0)

                                TabView(selection: $selectedCommentIndex) {
                                    ForEach(0..<comments.count, id: \.self) { index in
                                        CommentCard(comment: comments[index])
                                            .tag(index)
                                            .onTapGesture {
                                                draftCommentText = comments[index].text
                                                draftRating = comments[index].rating
                                                isManagingComment = true
                                            }
                                    }
                                }
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                                .frame(width: 300, height: 180)

                                Button(action: {
                                    if selectedCommentIndex < comments.count - 1 {
                                        withAnimation { selectedCommentIndex += 1 }
                                    }
                                }) {
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(selectedCommentIndex >= comments.count - 1 ? .gray.opacity(0.3) : Color("GreenPrimary"))
                                        .font(.system(size: 20, weight: .bold))
                                }
                                .disabled(selectedCommentIndex >= comments.count - 1)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            

            .navigationDestination(isPresented: $showServices) {

                NeighborhoodServicesView(neighborhoodName: selectedNeighborhoodName, coordinate: .init(latitude: 24.7136, longitude: 46.6753))
            }
            
            // شيت إدارة التعليق (تعديل/حذف)
            .sheet(isPresented: $isManagingComment) {
                CommentManagementView(commentText: $draftCommentText, rating: $draftRating, onSave: {
                    comments[selectedCommentIndex].text = draftCommentText
                    comments[selectedCommentIndex].rating = draftRating
                    isManagingComment = false
                }, onDelete: {
                    withAnimation {
                        comments.remove(at: selectedCommentIndex)
                        if selectedCommentIndex >= comments.count && !comments.isEmpty {
                            selectedCommentIndex = comments.count - 1
                        }
                    }
                    isManagingComment = false
                })
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            
            // شيت تعديل الملف الشخصي
            .sheet(isPresented: $isEditingProfile) {
                EditProfileView(name: $userName, email: userEmail)
            }
        }
    }
}

// 2. واجهة تعديل الملف الشخصي
struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var name: String
    var email: String
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("المعلومات الشخصية")) {
                    TextField("الاسم", text: $name)
                    HStack {
                        Text("البريد الإلكتروني")
                        Spacer()
                        Text(email).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("تعديل الحساب")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("تم") { dismiss() }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// 3. مكون النجوم التفاعلي
struct StarRatingView: View {
    @Binding var rating: Double
    var isInteractive: Bool = true
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: starIcon(for: Double(index)))
                    .foregroundColor(.yellow)
                    .font(.system(size: isInteractive ? 24 : 14))
                    .onTapGesture {
                        if isInteractive { handleTap(index: Double(index)) }
                    }
            }
        }
    }
    
    private func starIcon(for index: Double) -> String {
        if rating >= index { return "star.fill" }
        else if rating >= index - 0.5 { return "star.leadinghalf.filled" }
        else { return "star" }
    }
    
    private func handleTap(index: Double) {
        if rating == index { rating -= 0.5 }
        else if rating == index - 0.5 { rating -= 0.5 }
        else { rating = index }
    }
}

// 4. واجهة إدارة التعليق
struct CommentManagementView: View {
    @Binding var commentText: String
    @Binding var rating: Double
    var onSave: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("إدارة تعليقك").font(.system(size: 18, weight: .bold)).padding(.top)
            VStack(alignment: .trailing, spacing: 12) {
                HStack {
                    Image("PersonIcon").resizable().scaledToFill().frame(width: 45, height: 45)
                    VStack(alignment: .leading) {
                        Text("ساره خالد").font(.caption).foregroundColor(.gray.opacity(0.6))
                        Text("العارض").font(.callout).foregroundColor(.black)
                    }
                    Spacer()
                }
                TextEditor(text: $commentText)
                    .font(.system(size: 16))
                    .frame(height: 80)
                    .scrollContentBackground(.hidden)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                StarRatingView(rating: $rating)
            }
            .padding().frame(width: 300).background(Color.white.opacity(0.6)).cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            
            HStack(spacing: 15) {
                
                Button(action: onSave) {
                    Text("حفظ التعديلات").font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color("GreenPrimary")).cornerRadius(15)
                }
                Button(action: onDelete) {
                    Image(systemName: "trash").foregroundColor(.red).padding().background(Color.red.opacity(0.1)).clipShape(Circle())
                }
            }
            .padding(.horizontal, 30)
            Spacer()
        }
        .background(Color(white: 0.98)).environment(\.layoutDirection, .rightToLeft)
    }
}

// 5. بطاقة عرض التعليق
struct CommentCard: View {
    var comment: UserComment
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack {
                Image("PersonIcon").resizable().scaledToFill().frame(width: 45, height: 45)
                VStack(alignment: .leading) {
                    Text("ساره خالد").font(.caption).foregroundColor(.gray.opacity(0.6))
                    Text("العارض").font(.callout).foregroundColor(.black)
                }
                Spacer()
            }
            Text(comment.text).font(.system(size: 14)).foregroundColor(.black.opacity(0.8)).lineLimit(3).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .trailing)
            Spacer(minLength: 0)
            StarRatingView(rating: .constant(comment.rating), isInteractive: false)
        }
        .padding().frame(width: 300, height: 180).background(Color.white.opacity(0.6)).cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}

// 6. مكونات العناوين والأحياء المعدلة لتدعم التنقل
struct HeaderSection: View {
    let title: String; let icon: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.title2).foregroundColor(Color("GreenPrimary"))
            Text(title).font(.system(size: 22, weight: .bold)).foregroundColor(.black)
            Spacer()
        }
    }
}

struct NeighborhoodCard: View {
    var name: String
    var onMoreInfo: () -> Void // إضافة أكشن للضغط
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack {
                Text(name).font(.system(size: 24, weight: .bold))
                Spacer()
                HStack(spacing: 4) {
                    Text("29").font(.caption).foregroundColor(.gray)
                    ForEach(0..<5) { _ in Image(systemName: "star.fill").foregroundColor(.yellow).font(.system(size: 14)) }
                }
            }
            Spacer()
            HStack {
                Button(action: onMoreInfo) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left")
                        Text("لمزيد من المعلومات عن الحي").font(.system(size: 14))
                    }
                    .foregroundColor(Color("GreenPrimary"))
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .environment(\.layoutDirection, .leftToRight)
        }
        .padding(20).frame(width: 333, height: 149).background(Color.white).cornerRadius(20).shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    FavouritePage()
}


