//
//  ProfileView.swift
//  88trip
//
//  Created by かめいりょう on 2025/09/27.
//


import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Binding var loginObserver: Int
    @EnvironmentObject private var authService: AuthService
    @StateObject private var profileService = ProfileService()
    @StateObject private var postService = PostService()
    
    @State private var userPosts: [PostWithUser] = []
    @State private var isShowingSettings = false
    @State private var isShowingImagePicker = false
    @State private var selectedProfileImageItem: PhotosPickerItem?
    @State private var isUploadingProfileImage = false
    @State private var imageUpdateErrorMessage: String?
    @State private var showImageErrorAlert = false
    
    private func chunkByCharacters(_ array: [String], limit: Int) -> [[String]] {
        var result: [[String]] = []
        var currentRow: [String] = []
        var currentCount = 0
        
        for word in array {
            let len = word.count
            if currentCount + len > limit {
                result.append(currentRow)
                currentRow = []
                currentCount = 0
            }
            currentRow.append(word)
            currentCount += len
        }
        
        if !currentRow.isEmpty {
            result.append(currentRow)
        }
        
        return result
    }
    
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isShowingImagePicker = true
                    } label: {
                        ZStack {
                            if let profileImageUrl = authService.currentProfile?.profileImageUrl,
                               let url = URL(string: profileImageUrl) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        placeholderProfileImage
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 120, height: 120)
                                    @unknown default:
                                        placeholderProfileImage
                                    }
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                            } else {
                                placeholderProfileImage
                            }
                            
                            if isUploadingProfileImage {
                                Circle()
                                    .fill(Color.black.opacity(0.4))
                                    .frame(width: 120, height: 120)
                                ProgressView()
                                    .tint(.white)
                            }
                        }
                    }
                    Spacer()
                }
                // Supabaseからのプロフィール情報を表示
                if let profile = authService.currentProfile {
                    Text(profile.username)
                        .font(.title2)
                        .fontWeight(.bold)
                } else {
                    ProgressView()
                        .padding()
                    Text("プロフィールを読み込み中...")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    VStack {
                        Text("フォロー")
                        Text("0")
                    }
                    VStack {
                        Text("フォロワー")
                        Text("0")
                    }
                }
                .padding(.top, 20)
                
                // 投稿一覧
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("投稿")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("\(userPosts.count)件")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    if userPosts.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            Text("まだ投稿がありません")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        //lazybgridで画像の枠を作って、そこにforeachでうめていく
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 2),
                            GridItem(.flexible(), spacing: 2),
                            GridItem(.flexible(), spacing: 2)
                        ], spacing: 2){
                            ForEach(userPosts) { post in
                                NavigationLink(
                                    destination: PostManageView(
                                        post: post,
                                        postService: postService
                                    ) {
                                        await loadUserPosts()
                                    }
                                ) {
                                    if let imageUrl = post.imageUrl {
                                        AsyncImage(url: URL(string: imageUrl)) { phase in
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: (UIScreen.main.bounds.width - 4) / 3, height: (UIScreen.main.bounds.width - 4) / 3)
                                                    .clipped()
                                            } else if phase.error != nil {
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: (UIScreen.main.bounds.width - 4) / 3, height: (UIScreen.main.bounds.width - 4) / 3)
                                                    .overlay(
                                                        Image(systemName: "photo")
                                                            .foregroundColor(.white)
                                                    )
                                            } else {
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: (UIScreen.main.bounds.width - 4) / 3, height: (UIScreen.main.bounds.width - 4) / 3)
                                                    .overlay(
                                                        ProgressView()
                                                    )
                                            }
                                        }
                                    } else {
                                        Rectangle()
                                            .fill(Color.blue.opacity(0.2))
                                            .frame(width: (UIScreen.main.bounds.width - 4) / 3, height: (UIScreen.main.bounds.width - 4) / 3)
                                            .overlay(
                                                Text(post.content)
                                                    .font(.caption)
                                                    .foregroundColor(.primary)
                                                    .lineLimit(3)
                                                    .padding(8)
                                            )
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.top, 20)
            }
            .padding(.top, 35)
            .padding(.bottom, 30)
            .overlay(alignment: .topTrailing) {
                Button {
                    isShowingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .padding(10)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .padding(12)
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView(loginObserver: $loginObserver)
                .environmentObject(authService)
        }
        .photosPicker(isPresented: $isShowingImagePicker, selection: $selectedProfileImageItem, matching: .images)
        .onChange(of: selectedProfileImageItem) { _, newValue in
            Task {
                await handleSelectedProfileImage(newValue)
            }
        }
        .onAppear {
            Task {
                await authService.checkCurrentUser()
                await loadUserPosts()
            }
        }
        .alert("エラー", isPresented: $showImageErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(imageUpdateErrorMessage ?? "プロフィール画像の更新に失敗しました")
        }
    }
    
    private var placeholderProfileImage: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 120, height: 120)
            .overlay(
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 48))
            )
    }
    
    @MainActor
    private func loadUserPosts() async {
        guard let userId = authService.currentProfile?.id else { return }
        
        do {
            userPosts = try await postService.loadUserPosts(userId: userId)
        } catch {
            print("投稿の読み込みエラー: \(error)")
            userPosts = []
        }
    }
    
    private func handleSelectedProfileImage(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw SupabaseError.unknownError("画像データの読み込みに失敗しました")
            }
            await MainActor.run {
                isUploadingProfileImage = true
            }
            try await authService.updateProfileImage(with: data)
        } catch {
            await MainActor.run {
                imageUpdateErrorMessage = error.localizedDescription
                showImageErrorAlert = true
            }
        }
        await MainActor.run {
            isUploadingProfileImage = false
        }
    }
}

#Preview() {
    ProfileView(loginObserver: .constant(1))
        .environmentObject(AuthService())
}

// MARK: - 他ユーザープロフィール表示
struct UserProfileDetailView: View {
    private let initialUser: UserProfile
    
    @EnvironmentObject private var authService: AuthService
    @StateObject private var postService = PostService()
    @State private var userProfile: UserProfile
    @State private var posts: [PostWithUser] = []
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage: String?
    
    init(user: UserProfile) {
        self.initialUser = user
        _userProfile = State(initialValue: user)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader
                postsSection
            }
            .padding(.top, 32)
            .padding(.bottom, 24)
        }
        .navigationTitle(userProfile.username)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadProfile()
            await loadPosts()
        }
        .refreshable {
            await loadProfile()
            await loadPosts()
        }
        .alert("エラー", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "情報の取得に失敗しました")
        }
    }
    
    @ViewBuilder
    private var profileHeader: some View {
        VStack(spacing: 16) {
            if let urlString = userProfile.profileImageUrl,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholderProfileImage
                    case .empty:
                        ProgressView()
                            .frame(width: 120, height: 120)
                    @unknown default:
                        placeholderProfileImage
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
            } else {
                placeholderProfileImage
            }
            
            Text(userProfile.username)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(userProfile.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var postsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("投稿")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Text("\(posts.count)件")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if posts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("まだ投稿がありません")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 2),
                    GridItem(.flexible(), spacing: 2),
                    GridItem(.flexible(), spacing: 2)
                ], spacing: 2) {
                    ForEach(posts) { post in
                        NavigationLink(destination: PostOpenedView(post: post)) {
                            if let imageUrl = post.imageUrl,
                               let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .foregroundColor(.white)
                                            )
                                    case .empty:
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .overlay(ProgressView())
                                    @unknown default:
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                    }
                                }
                                .frame(width: (UIScreen.main.bounds.width - 4) / 3, height: (UIScreen.main.bounds.width - 4) / 3)
                                .clipped()
                            } else {
                                Rectangle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: (UIScreen.main.bounds.width - 4) / 3, height: (UIScreen.main.bounds.width - 4) / 3)
                                    .overlay(
                                        Text(post.content)
                                            .font(.caption2)
                                            .foregroundColor(.primary)
                                            .lineLimit(3)
                                            .padding(8)
                                    )
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var placeholderProfileImage: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 120, height: 120)
            .overlay(
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 48))
            )
    }
    
    private func loadProfile() async {
        do {
            let profile = try await authService.getUserProfile(userId: initialUser.id)
            await MainActor.run {
                userProfile = profile
            }
        } catch {
            await MainActor.run {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
    
    private func loadPosts() async {
        await MainActor.run { isLoading = true }
        do {
            let fetchedPosts = try await postService.loadUserPosts(userId: initialUser.userId)
            await MainActor.run {
                posts = fetchedPosts
                isLoading = false
            }
        } catch {
            await MainActor.run {
                alertMessage = error.localizedDescription
                showAlert = true
                isLoading = false
            }
        }
    }
}
