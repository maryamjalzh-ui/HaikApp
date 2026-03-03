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
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.backward")
                                .scaledFont(size: 18, weight: .regular, relativeTo: .headline)
                                .foregroundColor(Color("Green2Primary"))
                                .frame(width: 52, height: 52)
                                .background(Color("GreyBackground"))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 26)
                    .padding(.top, 10)
                    
                  
                        VStack(alignment: .center, spacing: 25) {
                            Button(action: { isEditingProfile = true }) {
                                HStack(spacing: 15) {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(Color("GreenPrimary"))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(viewModel.userName)
                                            .scaledFont(size: 20, weight: .bold, relativeTo: .headline)
                                            .foregroundStyle(.primary)
                                        Text(String(localized: "view_edit_profile")) // "عرض وتعديل الملف الشخصي"
                                            .scaledFont(size: 12, weight: .regular, relativeTo: .caption1)
                                            .foregroundStyle(.secondary)
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

                            HeaderSection(title: String(localized: "saved_neighborhoods_title"), icon: "heart") // "الأحياء المحفوظة:"
                                .frame(width: 360)

                            VStack(spacing: 16) {
                                if viewModel.savedNeighborhoodNames.isEmpty {
                                    Text(String(localized: "no_saved_neighborhoods")) // "لم تقم بحفظ أي أحياء بعد"
                                        .scaledFont(size: 12, weight: .regular, relativeTo: .caption1)
                                        .foregroundStyle(.secondary)
                                        .padding()
                                } else {
                                    ForEach(viewModel.savedNeighborhoodNames, id: \.self) { name in
                                        NeighborhoodCard(name: name, reviewCount: String(localized: "view_details")) { // "عرض التفاصيل"
                                            selectedNeighborhoodName = name
                                            showServices = true
                                        }
                                    }
                                }
                            }
                            
                            HeaderSection(title: String(localized: "your_comments_title"), icon: "text.bubble") // "تعليقاتك:"
                                .frame(width: 360)
                                .padding(.top, 10)

                            if !viewModel.userComments.isEmpty {
                                commentsPagerView
                            } else {
                                Text(String(localized: "no_comments_yet")) // "لا توجد تعليقات منشورة بعد"
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
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showServices) {
                NeighborhoodServicesView(neighborhoodName: selectedNeighborhoodName, coordinate: .init(latitude: 24.7136, longitude: 46.6753))
            }
            .sheet(isPresented: $isEditingProfile) {
                EditProfileView(name: $viewModel.userName, email: viewModel.userEmail) {
                    self.dismiss()
                }
            }
        }
    }
    // ... باقي الـ pagerView كما هو ...
    private var commentsPagerView: some View {
        List {
            ForEach($viewModel.userComments) { $comment in
                CommentCard(viewModel: viewModel, comment: $comment, userName: viewModel.userName)

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

// MARK: - Components المحدثة للترجمة

struct NeighborhoodCard: View {
    var name: String
    var reviewCount: String
    var onMoreInfo: () -> Void
    var body: some View {
        VStack(alignment: .trailing, spacing: 15) {
            HStack {
                // استخدام الـ Key المتفق عليه لدعم "حي الياسمين" / "Al-Yasmin District"
                Text("neighborhood_prefix \(name)")
                    .scaledFont(size: 20, weight: .bold, relativeTo: .headline)
                Spacer()
                Text("(\(reviewCount))").scaledFont(size: 12, weight: .regular, relativeTo: .caption1).foregroundStyle(.secondary)
                ForEach(0..<5) { _ in Image(systemName: "star.fill").foregroundColor(.yellow).scaledFont(size: 12, weight: .regular, relativeTo: .caption1) }
            }
            Divider()
            Button(action: onMoreInfo) {
                HStack {
                    Text(String(localized: "view_neighborhood_button")) // "عرض الحي"
                    Image(systemName: "arrow.left")
                }
                .scaledFont(size: 14, weight: .medium, relativeTo: .subheadline).foregroundStyle(.primary)
            }
        }
        .padding(25).frame(width: 360).background(Color("GreyBackground")).cornerRadius(30).shadow(radius: 5)
    }
}

struct EditProfileView: View {
    @Binding var name: String
    var email: String
    @Environment(\.dismiss) var dismiss
    var onSignOut: () -> Void
    
    @State private var showSignOutError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(String(localized: "personal_info_header"))) { // "المعلومات الشخصية"
                    TextField(String(localized: "name_placeholder"), text: $name) // "الاسم"
                    Text(email).foregroundStyle(.secondary)
                }
                
                Section {
                    Button(role: .destructive) {
                        signOut()
                    } label: {
                        HStack {
                            Spacer()
                            Text(String(localized: "sign_out_button")) // "تسجيل الخروج"
                                .fontWeight(.bold)
                            Image(systemName: "log.out.fill")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "edit_profile_title")) // "تعديل الحساب"
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "done_button")) { dismiss() } // "تم"
                }
            }
            .alert(String(localized: "alert_error_title"), isPresented: $showSignOutError) { // "تنبيه"
                Button(String(localized: "ok_button"), role: .cancel) { } // "موافق"
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            dismiss()
            onSignOut()
        } catch let error {
            errorMessage = error.localizedDescription
            showSignOutError = true
        }
    }
}

// MARK: - Supporting Components (باقي الكود كما هو)

struct CommentCard: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Binding var comment: ProfileViewModel.UserComment
    var userName: String

    @State private var isEditing = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
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

                HStack(spacing: 6) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .scaledFont(size: 18, weight: .regular, relativeTo: .headline)
                            .foregroundStyle(i <= (isEditing ? Int(comment.rating) : Int(comment.rating)) ? Color.yellow : Color.gray.opacity(0.35))
                            .onTapGesture {
                                if isEditing { comment.rating = Double(i) }
                            }
                    }
                }
            }
            .environment(\.layoutDirection, .leftToRight)

            TextField("", text: $comment.text)
                .scaledFont(size: 17, weight: .regular, relativeTo: .body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.plain)
                .background(Color.clear)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .disabled(!isEditing)
                .focused($isFocused)

            HStack {
                if isEditing {
                    Button("إلغاء") {
                        isEditing = false
                        viewModel.fetchUserComments() // استرجاع النص الأصلي من Firebase
                    }
                    .foregroundColor(.gray)

                    Spacer()

                    Button("حفظ") {
                        isEditing = false
                        viewModel.updateComment(comment, newText: comment.text, newRating: comment.rating)
                    }
                    .foregroundColor(Color("GreenPrimary"))
                } else {
                    Button {
                        isEditing = true
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


#Preview {
    FavouritePage()
}
