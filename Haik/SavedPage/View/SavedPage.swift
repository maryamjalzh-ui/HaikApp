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
    
    // دالة لجلب بيانات الحي كاملة (الاسم المترجم وعدد التقييمات)
    func getNeighborhood(for nameAr: String) -> Neighborhood? {
        return NeighborhoodData.all.first(where: { $0.nameAr == nameAr })
    }

    @Environment(\.colorScheme) private var colorScheme
    
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
                    // Header القسم العلوي
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.backward")
                                .scaledFont(size: 16, weight: .regular, relativeTo: .headline)
                                .foregroundColor(Color("Green2Primary"))
                                .frame(width: 48, height: 48)
                                .background(Color("GreyBackground"))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        
                        Spacer()
                        
                        Text(String(localized: "profile_page_title"))
                            .scaledFont(size: 19, weight: .bold, relativeTo: .title3)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Color.clear.frame(width: 48, height: 48)
                    }
                    .padding(.horizontal, 26)
                    .padding(.top, 10)
                    
                    VStack(alignment: .center, spacing: 25) {
                        // بوكس تعديل البروفايل (360)
                        Button(action: { isEditingProfile = true }) {
                            HStack(spacing: 15) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 44, height: 44)
                                    .foregroundColor(Color("GreenPrimary"))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(viewModel.userName)
                                        .scaledFont(size: 18, weight: .bold, relativeTo: .headline)
                                        .foregroundColor(colorScheme == .light ? .black : .white)
                                    
                                    Text(String(localized: "view_edit_profile"))
                                        .scaledFont(size: 11, weight: .regular, relativeTo: .caption1)
                                        .foregroundColor(colorScheme == .light ? .gray : .secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(colorScheme == .light ? .gray : .secondary)
                            }
                            .padding(25)
                            .frame(width: 360)
                            .background(Color("GreyBackground"))
                            .cornerRadius(18)
                            .shadow(color: Color.black.opacity(0.03), radius: 4)
                        }

                        HeaderSection(title: String(localized: "saved_neighborhoods_title"), icon: "heart")
                            .frame(width: 360)

                        VStack(spacing: 16) {
                            if viewModel.savedNeighborhoodNames.isEmpty {
                                Text(String(localized: "no_saved_neighborhoods"))
                                    .scaledFont(size: 12, weight: .regular, relativeTo: .caption1)
                                    .foregroundStyle(.secondary)
                                    .padding()
                            } else {
                                ForEach(viewModel.savedNeighborhoodNames, id: \.self) { nameAr in
                                    if let n = getNeighborhood(for: nameAr) {
                                        NeighborhoodCard(
                                            name: n.name, // يترجم الاسم تلقائياً
                                            reviewCount: n.reviewCount // يجلب العدد الحقيقي
                                        ) {
                                            selectedNeighborhoodName = nameAr
                                            showServices = true
                                        }
                                    }
                                }
                            }
                        }
                        
                        HeaderSection(title: String(localized: "your_comments_title"), icon: "text.bubble")
                            .frame(width: 360)
                            .padding(.top, 10)

                        if !viewModel.userComments.isEmpty {
                            commentsPagerView
                        } else {
                            Text(String(localized: "no_comments_posted_yet"))
                                .scaledFont(size: 13, weight: .regular, relativeTo: .subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 20)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showServices) {
                if let neighborhood = getNeighborhood(for: selectedNeighborhoodName) {
                    NeighborhoodServicesView(
                        neighborhoodName: neighborhood.nameAr,
                        displayName: neighborhood.name,
                        coordinate: neighborhood.coordinate
                    )
                }
            }
            .sheet(isPresented: $isEditingProfile) {
                EditProfileView(viewModel: viewModel, name: $viewModel.userName, email: viewModel.userEmail)
            }
        }
    }

    private var commentsPagerView: some View {
        List {
            ForEach($viewModel.userComments) { $comment in
                CommentCard(comment: $comment, userName: viewModel.userName)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            commentToDelete = comment
                            showDeleteAlert = true
                        } label: {
                            Label(String(localized: "delete_button"), systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .alert(String(localized: "delete_confirm_title"), isPresented: $showDeleteAlert) {
            Button(String(localized: "delete_button"), role: .destructive) {
                if let comment = commentToDelete {
                    viewModel.deleteComment(comment)
                }
            }
            Button(String(localized: "cancel_button"), role: .cancel) {}
        } message: {
            Text(String(localized: "delete_confirm_message"))
        }
    }
}

// MARK: - Components

struct NeighborhoodCard: View {
    var name: String
    var reviewCount: String
    var onMoreInfo: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            HStack {
                Text(name) // يظهر الاسم مترجماً
                    .scaledFont(size: 17, weight: .semibold, relativeTo: .headline)
                    .foregroundColor(colorScheme == .light ? .black : .white)
                Spacer()
                Text("(\(reviewCount))") // الرقم الحقيقي
                    .scaledFont(size: 11, weight: .regular, relativeTo: .caption1)
                    .foregroundStyle(.secondary)
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill").foregroundColor(.yellow).font(.system(size: 9))
                }
            }
            Divider().opacity(0.6)
            Button(action: onMoreInfo) {
                HStack(spacing: 4) {
                    Text(String(localized: "view_neighborhood_button"))
                    Image(systemName: "arrow.left").font(.system(size: 11))
                }
                .scaledFont(size: 13, weight: .medium, relativeTo: .subheadline)
                .foregroundColor(colorScheme == .light ? .black : .white)
            }
        }
        .padding(25).frame(width: 360).background(Color("GreyBackground")).cornerRadius(18).shadow(color: .black.opacity(0.03), radius: 4)
    }
}

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Binding var name: String
    var email: String
    @Environment(\.dismiss) var dismiss
    
    @State private var showDeleteAccountConfirm = false
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(String(localized: "personal_info_header"))) {
                    TextField(String(localized: "name_placeholder"), text: $name)
                    Text(email).foregroundStyle(.secondary)
                }
                Section {
                    Button(role: .destructive) { try? Auth.auth().signOut(); dismiss() } label: {
                        HStack { Spacer(); Text(String(localized: "sign_out_button")).fontWeight(.semibold); Image(systemName: "log.out.fill"); Spacer() }
                    }
                    Button(role: .destructive) { showDeleteAccountConfirm = true } label: {
                        HStack { Spacer(); Text(String(localized: "delete_account_button")).fontWeight(.semibold); Image(systemName: "person.fill.xmark"); Spacer() }
                    }
                }
            }
            .navigationTitle(String(localized: "edit_profile_title")).navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button(String(localized: "done_button")) { viewModel.updateUserName(newName: name); dismiss() }.fontWeight(.bold) } }
        }
    }
}

struct CommentCard: View {
    @Binding var comment: ProfileViewModel.UserComment
    var userName: String
    
    func getLocalizedName(for nameAr: String) -> String {
        if let neighborhood = NeighborhoodData.all.first(where: { $0.nameAr == nameAr }) {
            return neighborhood.name
        }
        return nameAr
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack {
                Image(systemName: "person.circle.fill").resizable().frame(width: 28, height: 28).foregroundColor(Color("GreenPrimary"))
                VStack(alignment: .leading, spacing: 1) {
                    Text(userName).scaledFont(size: 11, weight: .regular, relativeTo: .caption1).foregroundColor(.gray.opacity(0.7))
                    Text(getLocalizedName(for: comment.neighborhoodName)) // مترجم
                        .scaledFont(size: 14, weight: .medium, relativeTo: .callout)
                        .foregroundStyle(.primary)
                }
                Spacer()
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: "star.fill").font(.system(size: 13))
                            .foregroundStyle(i <= Int(comment.rating) ? Color.yellow : Color.gray.opacity(0.3))
                    }
                }
            }.environment(\.layoutDirection, .leftToRight)
            Text(comment.text).scaledFont(size: 15, weight: .regular, relativeTo: .body).foregroundColor(.primary).multilineTextAlignment(.trailing).frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14).background(Color("GreyBackground")).clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct HeaderSection: View {
    let title: String
    let icon: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 16, weight: .medium)).foregroundColor(Color("GreenPrimary"))
            Text(title).scaledFont(size: 18, weight: .bold, relativeTo: .title3).foregroundStyle(.primary)
            Spacer()
        }
    }
}
#Preview {
    FavouritePage()
}
