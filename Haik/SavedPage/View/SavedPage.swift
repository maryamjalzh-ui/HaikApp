////  SavedPage.swift
////  Haik
////
////  Created by Maryam Jalal Alzahrani on 21/08/1447 AH.
////
//
//import SwiftUI
//import FirebaseFirestore
//import FirebaseAuth
//import Combine
//internal import _LocationEssentials
//
//struct FavouritePage: View {
//    @StateObject private var viewModel = ProfileViewModel()
//    @State private var isEditingProfile: Bool = false
//    @State private var showServices = false
//    @State private var selectedNeighborhoodName = ""
//    @State private var showDeleteAlert = false
//    @State private var commentToDelete: ProfileViewModel.UserComment?
//    @Environment(\.dismiss) private var dismiss
//    
//    // دالة لجلب بيانات الحي كاملة (الاسم المترجم وعدد التقييمات)
//    func getNeighborhood(for nameAr: String) -> Neighborhood? {
//        return NeighborhoodData.all.first(where: { $0.nameAr == nameAr })
//    }
//
//    @Environment(\.colorScheme) private var colorScheme
//  
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color("PageBackground").ignoresSafeArea()
//                
//                GeometryReader { geometry in
//                    VStack {
//                        Spacer()
//                        Image("Building")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: geometry.size.width)
//                            .allowsHitTesting(false)
//                    }
//                }
//                .ignoresSafeArea()
//                
//                ScrollView(.vertical, showsIndicators: false) {
//                    VStack(spacing: 0) {
//                        // Header
//                        HStack {
//                            Button { dismiss() } label: {
//                                Image(systemName: "chevron.backward")
//                                    .scaledFont(size: 16, weight: .regular, relativeTo: .headline)
//                                    .foregroundColor(Color("Green2Primary"))
//                                    .frame(width: 48, height: 48)
//                                    .background(Color("GreyBackground"))
//                                    .clipShape(Circle())
//                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
//                            }
//                            
//                            Spacer()
//                            
//                            Text(String(localized: "profile_page_title"))
//                                .scaledFont(size: 19, weight: .bold, relativeTo: .title3)
//                                .foregroundStyle(.primary)
//                            
//                            Spacer()
//                            
//                            Color.clear.frame(width: 48, height: 48)
//                        }
//                        .padding(.horizontal, 26)
//                        .padding(.top, 10)
//                        
//                        VStack(alignment: .center, spacing: 25) {
//                            Button(action: { isEditingProfile = true }) {
//                                HStack(spacing: 15) {
//                                    Image(systemName: "person.circle.fill")
//                                        .resizable()
//                                        .frame(width: 44, height: 44)
//                                        .foregroundColor(Color("GreenPrimary"))
//                                    
//                                    VStack(alignment: .leading, spacing: 2) {
//                                        Text(viewModel.userName)
//                                            .scaledFont(size: 18, weight: .bold, relativeTo: .headline)
//                                            .foregroundColor(colorScheme == .light ? .black : .white)
//                                        
//                                        Text(String(localized: "view_edit_profile"))
//                                            .scaledFont(size: 11, weight: .regular, relativeTo: .caption1)
//                                            .foregroundColor(colorScheme == .light ? .gray : .secondary)
//                                    }
//                                    
//                                    Spacer()
//                                    
//                                    Image(systemName: "chevron.left")
//                                        .font(.system(size: 12, weight: .medium))
//                                        .foregroundColor(colorScheme == .light ? .gray : .secondary)
//                                }
//                                .padding(25)
//                                .frame(width: 360)
//                                .background(Color("GreyBackground"))
//                                .cornerRadius(18)
//                                .shadow(color: Color.black.opacity(0.03), radius: 4)
//                            }
//                            
//                            HeaderSection(title: String(localized: "saved_neighborhoods_title"), icon: "heart")
//                                .frame(width: 360)
//                            
//                            savedNeighborhoodsSection
//                            
//                            HeaderSection(title: String(localized: "your_comments_title"), icon: "text.bubble")
//                                .frame(width: 360)
//                                .padding(.top, 10)
//                            
//                            commentsSection
//                        }
//                        .padding(.top, 10)
//                        .padding(.bottom, 30)
//                        .frame(maxWidth: .infinity)
//                    }
//                    .frame(maxWidth: .infinity, alignment: .top)
//                }
//            }
//            .navigationBarBackButtonHidden(true)
//            .toolbar(.hidden, for: .navigationBar)
//            .navigationDestination(isPresented: $showServices) {
//                if let neighborhood = getNeighborhood(for: selectedNeighborhoodName) {
//                    NeighborhoodServicesView(
//                        neighborhoodName: neighborhood.nameAr,
//                        displayName: neighborhood.name,
//                        coordinate: neighborhood.coordinate
//                    )
//                }
//            }
//            .sheet(isPresented: $isEditingProfile) {
//                EditProfileView(viewModel: viewModel, name: $viewModel.userName, email: viewModel.userEmail)
//            }
//            .alert(String(localized: "delete_confirm_title"), isPresented: $showDeleteAlert) {
//                Button(String(localized: "delete_button"), role: .destructive) {
//                    if let comment = commentToDelete {
//                        viewModel.deleteComment(comment)
//                    }
//                }
//                Button(String(localized: "cancel_button"), role: .cancel) {}
//            } message: {
//                Text(String(localized: "delete_confirm_message"))
//            }
//        }
//    }
//    private var savedNeighborhoodsSection: some View {
//        Group {
//            if viewModel.savedNeighborhoodNames.isEmpty {
//                Text(String(localized: "no_saved_neighborhoods"))
//                    .scaledFont(size: 12, weight: .regular, relativeTo: .caption1)
//                    .foregroundStyle(.secondary)
//                    .padding()
//            } else {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    LazyHStack(spacing: 16) {
//                        ForEach(viewModel.savedNeighborhoodNames, id: \.self) { nameAr in
//                            if let n = getNeighborhood(for: nameAr) {
//                                NeighborhoodCard(
//                                    name: n.name,
//                                    reviewCount: n.reviewCount
//                                ) {
//                                    selectedNeighborhoodName = nameAr
//                                    showServices = true
//                                }
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 4)
//                }
//                .frame(height: 190)
//            }
//        }
//    }
//
//    private var commentsSection: some View {
//        Group {
//            if viewModel.userComments.isEmpty {
//                Text(String(localized: "no_comments_posted_yet"))
//                    .scaledFont(size: 13, weight: .regular, relativeTo: .subheadline)
//                    .foregroundStyle(.secondary)
//                    .padding(.top, 20)
//            } else {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    LazyHStack(alignment: .top, spacing: 16) {
//                        ForEach($viewModel.userComments) { $comment in
//                            CommentCard(
//                                comment: $comment,
//                                userName: viewModel.userName,
//                                onDelete: {
//                                    commentToDelete = comment
//                                    showDeleteAlert = true
//                                }
//                            )
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 4)
//                }
//                .frame(height: 190)
//            }
//        }
//    }
//}
//
//// MARK: - Components
//
//struct NeighborhoodCard: View {
//    var name: String
//    var reviewCount: String
//    var onMoreInfo: () -> Void
//    @Environment(\.colorScheme) private var colorScheme
//    
//    var body: some View {
//        VStack(alignment: .trailing, spacing: 12) {
//            HStack {
//                Text(name)
//                    .scaledFont(size: 17, weight: .semibold, relativeTo: .headline)
//                    .foregroundColor(colorScheme == .light ? .black : .white)
//                    .lineLimit(1)
//                
//                Spacer()
//                
//                Text("(\(reviewCount))")
//                    .scaledFont(size: 11, weight: .regular, relativeTo: .caption1)
//                    .foregroundStyle(.secondary)
//                
//                ForEach(0..<5) { _ in
//                    Image(systemName: "star.fill")
//                        .foregroundColor(.yellow)
//                        .font(.system(size: 9))
//                }
//            }
//            
//            Divider().opacity(0.6)
//            
//            Button(action: onMoreInfo) {
//                HStack(spacing: 4) {
//                    Text(String(localized: "view_neighborhood_button"))
//                    Image(systemName: "arrow.left")
//                        .font(.system(size: 11))
//                }
//                .scaledFont(size: 13, weight: .medium, relativeTo: .subheadline)
//                .foregroundColor(colorScheme == .light ? .black : .white)
//            }
//        }
//        .padding(22)
//        .frame(width: 320, height: 155, alignment: .top)
//        .background(Color("GreyBackground"))
//        .cornerRadius(18)
//        .shadow(color: .black.opacity(0.03), radius: 4)
//    }
//}
//struct EditProfileView: View {
//    @ObservedObject var viewModel: ProfileViewModel
//    @Binding var name: String
//    var email: String
//    @Environment(\.dismiss) var dismiss
//    
//    @State private var showDeleteAccountConfirm = false
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section(header: Text(String(localized: "personal_info_header"))) {
//                    TextField(String(localized: "name_placeholder"), text: $name)
//                    Text(email).foregroundStyle(.secondary)
//                }
//                Section {
//                    Button(role: .destructive) { try? Auth.auth().signOut(); dismiss() } label: {
//                        HStack { Spacer(); Text(String(localized: "sign_out_button")).fontWeight(.semibold); Image(systemName: "log.out.fill"); Spacer() }
//                    }
//                    Button(role: .destructive) { showDeleteAccountConfirm = true } label: {
//                        HStack { Spacer(); Text(String(localized: "delete_account_button")).fontWeight(.semibold); Image(systemName: "person.fill.xmark"); Spacer() }
//                    }
//                }
//            }
//            .navigationTitle(String(localized: "edit_profile_title")).navigationBarTitleDisplayMode(.inline)
//            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button(String(localized: "done_button")) { viewModel.updateUserName(newName: name); dismiss() }.fontWeight(.bold) } }
//        }
//    }
//}
//
//struct CommentCard: View {
//    @Binding var comment: ProfileViewModel.UserComment
//    var userName: String
//    var onDelete: () -> Void
//    
//    @Environment(\.colorScheme) private var colorScheme
//    
//    func getLocalizedName(for nameAr: String) -> String {
//        if let neighborhood = NeighborhoodData.all.first(where: { $0.nameAr == nameAr }) {
//            return neighborhood.name
//        }
//        return nameAr
//    }
//
//    var body: some View {
//        VStack(alignment: .trailing, spacing: 12) {
//            HStack(alignment: .top) {
//                VStack(alignment: .trailing, spacing: 2) {
//                    Text(getLocalizedName(for: comment.neighborhoodName))
//                        .scaledFont(size: 17, weight: .semibold, relativeTo: .headline)
//                        .foregroundColor(colorScheme == .light ? .black : .white)
//                        .lineLimit(1)
//                    
//                    Text(userName)
//                        .scaledFont(size: 11, weight: .regular, relativeTo: .caption1)
//                        .foregroundColor(.secondary)
//                }
//                
//                Spacer()
//                
//                HStack(spacing: 4) {
//                    ForEach(1...5, id: \.self) { i in
//                        Image(systemName: "star.fill")
//                            .font(.system(size: 10))
//                            .foregroundStyle(i <= Int(comment.rating) ? Color.yellow : Color.gray.opacity(0.3))
//                    }
//                }
//            }
//            
//            Divider().opacity(0.6)
//            
//            Text(comment.text)
//                .scaledFont(size: 14, weight: .regular, relativeTo: .body)
//                .foregroundColor(.primary)
//                .multilineTextAlignment(.trailing)
//                .frame(maxWidth: .infinity, alignment: .trailing)
//                .lineLimit(3)
//
//            HStack {
//                Button(action: onDelete) {
//                    Image(systemName: "trash")
//                        .foregroundColor(.red)
//                }
//                Spacer()
//            }
//        }
//        .padding(22)
//        .frame(width: 320, height: 155, alignment: .top)
//        .background(Color("GreyBackground"))
//        .cornerRadius(18)
//        .shadow(color: .black.opacity(0.03), radius: 4)
//    }
//}
//struct HeaderSection: View {
//    let title: String
//    let icon: String
//    var body: some View {
//        HStack(spacing: 6) {
//            Image(systemName: icon).font(.system(size: 16, weight: .medium)).foregroundColor(Color("GreenPrimary"))
//            Text(title).scaledFont(size: 18, weight: .bold, relativeTo: .title3).foregroundStyle(.primary)
//            Spacer()
//        }
//    }
//}
//#Preview {
//    FavouritePage()
//}


//
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
    @Environment(\.colorScheme) private var colorScheme

    func getNeighborhood(for nameAr: String) -> Neighborhood? {
        NeighborhoodData.all.first(where: { $0.nameAr == nameAr })
    }

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
                            .opacity(0.18)
                    }
                }
                .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
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

                            savedNeighborhoodsSection

                            HeaderSection(title: String(localized: "your_comments_title"), icon: "text.bubble")
                                .frame(width: 360)
                                .padding(.top, 10)

                            commentsSection
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                }
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

    private var savedNeighborhoodsSection: some View {
        Group {
            if viewModel.savedNeighborhoodNames.isEmpty {
                Text(String(localized: "no_saved_neighborhoods"))
                    .scaledFont(size: 12, weight: .regular, relativeTo: .caption1)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(viewModel.savedNeighborhoodNames, id: \.self) { nameAr in
                            if let neighborhood = getNeighborhood(for: nameAr) {
                                let ratingData = viewModel.neighborhoodRatings[nameAr]

                                NeighborhoodCard(
                                    name: neighborhood.name,
                                    rating: ratingData?.avg ?? 0,
                                    reviewCount: ratingData?.count ?? 0
                                ) {
                                    selectedNeighborhoodName = nameAr
                                    showServices = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                }
                .frame(height: 190)
            }
        }
    }

    private var commentsSection: some View {
        Group {
            if viewModel.userComments.isEmpty {
                Text(String(localized: "no_comments_posted_yet"))
                    .scaledFont(size: 13, weight: .regular, relativeTo: .subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: 16) {
                        ForEach($viewModel.userComments) { $comment in
                            CommentCard(
                                viewModel: viewModel,
                                comment: $comment,
                                userName: viewModel.userName,
                                onDelete: {
                                    commentToDelete = comment
                                    showDeleteAlert = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                }
                .frame(height: 205)
            }
        }
    }
}

// MARK: - Components

struct NeighborhoodCard: View {
    var name: String
    var rating: Double
    var reviewCount: Int
    var onMoreInfo: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.layoutDirection) private var layoutDirection

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack {
                Text(name)
                    .scaledFont(size: 17, weight: .semibold)
                    .foregroundColor(colorScheme == .light ? .black : .white)

                Spacer()

                Text("(\(reviewCount))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(1...5, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .foregroundColor(i <= Int(rating.rounded()) ? .yellow : .gray.opacity(0.3))
                        .font(.system(size: 10))
                }
            }

            Divider().opacity(0.6)

            Button(action: onMoreInfo) {
                HStack(spacing: 4) {
                    Text(String(localized: "view_neighborhood_button"))
                    Image(systemName: layoutDirection == .rightToLeft ? "arrow.left" : "arrow.right")
                }
                .font(.subheadline)
                .foregroundColor(colorScheme == .light ? .black : .white)
            }
        }
        .padding(22)
        .frame(width: 320, height: 155)
        .background(Color("GreyBackground"))
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.03), radius: 4)
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
                    Button(role: .destructive) {
                        try? Auth.auth().signOut()
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text(String(localized: "sign_out_button")).fontWeight(.semibold)
                            Image(systemName: "log.out.fill")
                            Spacer()
                        }
                    }

                    Button(role: .destructive) {
                        showDeleteAccountConfirm = true
                    } label: {
                        HStack {
                            Spacer()
                            Text(String(localized: "delete_account_button")).fontWeight(.semibold)
                            Image(systemName: "person.fill.xmark")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "edit_profile_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "done_button")) {
                        viewModel.updateUserName(newName: name)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

struct CommentCard: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Binding var comment: ProfileViewModel.UserComment
    var userName: String
    var onDelete: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isFocused: Bool
    @State private var isEditing = false

    func getLocalizedName(for nameAr: String) -> String {
        if let neighborhood = NeighborhoodData.all.first(where: { $0.nameAr == nameAr }) {
            return neighborhood.name
        }
        return nameAr
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(getLocalizedName(for: comment.neighborhoodName))
                        .scaledFont(size: 17, weight: .semibold, relativeTo: .headline)
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .lineLimit(1)

                    Text(userName)
                        .scaledFont(size: 11, weight: .regular, relativeTo: .caption1)
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(i <= Int(comment.rating) ? Color.yellow : Color.gray.opacity(0.3))
                            .onTapGesture {
                                if isEditing {
                                    comment.rating = Double(i)
                                }
                            }
                    }
                }
            }

            Divider().opacity(0.6)

            if isEditing {
                TextField("", text: $comment.text, axis: .vertical)
                    .scaledFont(size: 14, weight: .regular, relativeTo: .body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .focused($isFocused)
                    .lineLimit(3...4)
            } else {
                Text(comment.text)
                    .scaledFont(size: 14, weight: .regular, relativeTo: .body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineLimit(3)
            }

            HStack {
                if isEditing {
                    Button(String(localized: "cancel_button")) {
                        isEditing = false
                        viewModel.fetchUserComments()
                    }
                    .foregroundColor(.gray)

                    Spacer()

                    Button(String(localized: "save_button")) {
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

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }

                    Spacer()
                }
            }
        }
        .padding(22)
        .frame(width: 320, height: 170, alignment: .top)
        .background(Color("GreyBackground"))
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.03), radius: 4)
        .animation(.easeInOut, value: isEditing)
    }
}

struct HeaderSection: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("GreenPrimary"))

            Text(title)
                .scaledFont(size: 18, weight: .bold, relativeTo: .title3)
                .foregroundStyle(.primary)

            Spacer()
        }
    }
}

#Preview {
    FavouritePage()
}
