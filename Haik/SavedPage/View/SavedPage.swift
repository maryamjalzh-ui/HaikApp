//  SavedPage.swift
//  Haik
//
//  Created by Maryam Jalal Alzahrani on 21/08/1447 AH.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine
internal import _LocationEssentials

struct FavouritePage: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isEditingProfile: Bool = false
    @State private var showServices = false
    @State private var selectedNeighborhoodName = ""
    @State private var showDeleteAlert = false
    @State private var commentToDelete: ProfileViewModel.UserComment?
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCommentIndex: Int = 0
    @State private var isManagingComment: Bool = false
    @State private var draftCommentText: String = ""
    @State private var draftRating: Double = 0.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("PageBackground").ignoresSafeArea()
                
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
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.forward")
                                .scaledFont(size: 18, weight: .regular, relativeTo: .headline)
                                .foregroundColor(Color("Green2Primary"))
                                .frame(width: 52, height: 52)
                                .background(Color("GreyBackground"))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
                        }
                    }
                    .padding(.horizontal, 26)
                    .padding(.top, 10)
                    .environment(\.layoutDirection, .leftToRight)
                    
                  
                        VStack(alignment: .center, spacing: 25) {
                            Button(action: { isEditingProfile = true }) {
                                HStack(spacing: 15) {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(Color("GreenPrimary"))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(viewModel.userName)
                                            .scaledFont(size: 20, weight: .bold, relativeTo: .headline)                                            .foregroundStyle(.primary)
                                        Text("عرض وتعديل الملف الشخصي")
                                            .scaledFont(size: 12, weight: .regular, relativeTo: .caption1)                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.left").foregroundStyle(.secondary)
                                }
                                .padding(20)
                                .frame(width: 360)
                                .background(Color("GreyBackground"))
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.05), radius: 5)
                            }

                            HeaderSection(title: "الأحياء المحفوظة:", icon: "heart")
                                .frame(width: 360)

                            VStack(spacing: 16) {
                                if viewModel.savedNeighborhoodNames.isEmpty {
                                    Text("لم تقم بحفظ أي أحياء بعد")
                                        .scaledFont(size: 12, weight: .regular, relativeTo: .caption1)                                        .foregroundStyle(.secondary)
                                        .padding()
                                } else {
                                    ForEach(viewModel.savedNeighborhoodNames, id: \.self) { name in
                                        NeighborhoodCard(name: name, reviewCount: "عرض التفاصيل") {
                                            selectedNeighborhoodName = name
                                            showServices = true
                                        }
                                    }
                                }
                            }
                            
                            HeaderSection(title: "تعليقاتك:", icon: "text.bubble")
                                .frame(width: 360)
                                .padding(.top, 10)

                            if !viewModel.userComments.isEmpty {
                                commentsPagerView
                            } else {
                                Text("لا توجد تعليقات منشورة بعد")
                                    .scaledFont(size: 14, weight: .regular, relativeTo: .subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 20)
                            }
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                        .frame(maxWidth: .infinity)
                    
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showServices) {
                NeighborhoodServicesView(neighborhoodName: selectedNeighborhoodName, coordinate: .init(latitude: 24.7136, longitude: 46.6753))
            }
            .sheet(isPresented: $isEditingProfile) {
                // مررنا dismiss التابع لـ FavouritePage لكي يتم استدعاؤه عند تسجيل الخروج
                EditProfileView(name: $viewModel.userName, email: viewModel.userEmail) {
                    self.dismiss()
                }
            }
        }
    }
    
    private var commentsPagerView: some View {
        List {
            ForEach(viewModel.userComments) { comment in
                CommentCard(viewModel: viewModel, comment: comment, userName: viewModel.userName)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            commentToDelete = comment
                            showDeleteAlert = true
                        } label: {
                            Label("حذف", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .alert("تأكيد الحذف", isPresented: $showDeleteAlert) {
            Button("حذف", role: .destructive) {
                if let comment = commentToDelete {
                    viewModel.deleteComment(comment)
                }
            }
            Button("إلغاء", role: .cancel) {}
        } message: {
            Text("هل أنت متأكد أنك تريد حذف هذا التعليق؟")
        }
    }}

// MARK: - Modified EditProfileView

struct EditProfileView: View {
    @Binding var name: String
    var email: String
    @Environment(\.dismiss) var dismiss
    
    // إضافة هاندلر لإغلاق الصفحة الرئيسية
    var onSignOut: () -> Void
    
    @State private var showSignOutError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("المعلومات الشخصية")) {
                    TextField("الاسم", text: $name)
                    Text(email).foregroundStyle(.secondary)
                }
                
                Section {
                    Button(role: .destructive) {
                        signOut()
                    } label: {
                        HStack {
                            Spacer()
                            Text("تسجيل الخروج")
                                .fontWeight(.bold)
                            Image(systemName: "log.out.fill")
                            Spacer()
                        }
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
            .alert("تنبيه", isPresented: $showSignOutError) {
                Button("موافق", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            dismiss()      // يغلق الشيت
            onSignOut()    // يغلق صفحة FavouritePage ويرجعك للهوم
        } catch let error {
            errorMessage = error.localizedDescription
            showSignOutError = true
        }
    }
}

// MARK: - Supporting Components (باقي الكود كما هو)

import SwiftUI

import SwiftUI

struct CommentCard: View {
    @ObservedObject var viewModel: ProfileViewModel
    var comment: ProfileViewModel.UserComment
    var userName: String
    
    @State private var isEditing = false
    @State private var editedText: String = ""
    @State private var editedRating: Double = 0
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            
            // ===== Header: البروفايل واسم المستخدم + النجوم =====
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color("GreenPrimary"))
                
                VStack(alignment: .leading) {
                    Text(userName)
                        .scaledFont(size: 12, weight: .regular, relativeTo: .caption1)
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text(comment.neighborhoodName)
                        .scaledFont(size: 16, weight: .regular, relativeTo: .callout)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                // النجوم
                HStack(spacing: 6) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .scaledFont(size: 18, weight: .regular, relativeTo: .headline)
                            .foregroundStyle(i <= (isEditing ? Int(editedRating) : Int(comment.rating)) ? Color.yellow : Color.gray.opacity(0.35))
                            .onTapGesture {
                                if isEditing { editedRating = Double(i) }
                            }
                    }
                }
            }
            .environment(\.layoutDirection, .leftToRight)
            
            // ===== التعليق: TextField شفاف inline =====
            TextField("", text: $editedText)
                .scaledFont(size: 17, weight: .regular, relativeTo: .body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.plain)
                .background(Color.clear)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .disabled(!isEditing)
                .focused($isFocused)
                .onAppear {
                    // نملأ النص دائماً عند ظهور الكارد
                    if editedText.isEmpty {
                        editedText = comment.text
                        editedRating = comment.rating
                    }
                }
            
            // ===== تاريخ التعليق =====
         /*   Text(relativeDate(comment.createdAt))
                .scaledFont(size: 14, weight: .regular, relativeTo: .caption1)
                .foregroundStyle(Color.gray.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .leftToRight)
            */
            // ===== أزرار حفظ / إلغاء أو القلم =====
            HStack {
                if isEditing {
                    Button("إلغاء") {
                        isEditing = false
                        editedText = comment.text
                        editedRating = comment.rating
                    }
                    .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button("حفظ") {
                        viewModel.updateComment(comment, newText: editedText, newRating: editedRating)
                        isEditing = false
                    }
                    .foregroundColor(Color("GreenPrimary"))
                } else {
                    Button {
                        isEditing = true
                        editedText = comment.text
                        editedRating = comment.rating
                        isFocused = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(Color("GreenPrimary"))
                    }
                    
                    Spacer()
                }
            }
            
        }
        .padding(16)
        .background(Color("GreyBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 8)
        .animation(.easeInOut, value: isEditing)
    }
    
    // دالة تحويل التاريخ إلى نسبي
    func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
struct HeaderSection: View {
    let title: String
    let icon: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.title2).foregroundColor(Color("GreenPrimary"))
            Text(title).scaledFont(size: 22, weight: .bold, relativeTo: .title3).foregroundStyle(.primary)
            Spacer()
        }
    }
}

struct NeighborhoodCard: View {
    var name: String
    var reviewCount: String
    var onMoreInfo: () -> Void
    var body: some View {
        VStack(alignment: .trailing, spacing: 15) {
            HStack {
                Text("حي \(name)").scaledFont(size: 20, weight: .bold, relativeTo: .headline)
                Spacer()
                Text("(\(reviewCount))").scaledFont(size: 12, weight: .regular, relativeTo: .caption1).foregroundStyle(.secondary)
                ForEach(0..<5) { _ in Image(systemName: "star.fill").foregroundColor(.yellow).scaledFont(size: 12, weight: .regular, relativeTo: .caption1) }
            }
            Divider()
            Button(action: onMoreInfo) {
                HStack { Text("عرض الحي"); Image(systemName: "arrow.left") }
                    .scaledFont(size: 14, weight: .medium, relativeTo: .subheadline).foregroundStyle(.primary)
            }
        }
        .padding(25).frame(width: 360).background(Color("GreyBackground")).cornerRadius(30).shadow(radius: 5)
    }
}

#Preview {
    FavouritePage()
}
