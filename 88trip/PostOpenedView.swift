//
//  PostOpenedView.swift
//  88trip
//
//  Created by かめいりょう on 2025/10/12.
//

import SwiftUI

struct PostOpenedView: View {
    let post: PostWithUser
    @EnvironmentObject private var authService: AuthService
    @StateObject private var postService = PostService()
    @StateObject private var commentService = CommentService()
    @Environment(\.dismiss) var dismiss
    
    @State private var commentText = ""
    @State private var comments: [CommentWithUser] = []
    @State private var isLiked = false
    @State private var likeCount = 0
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoadingComments = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // ヘッダー：ユーザー情報
                userHeaderSection
                
                // 投稿画像
                if let imageUrl = post.imageUrl {
                    postImageSection(imageUrl: imageUrl)
                }
                
                // アクションボタン（いいね、コメント、シェア）
                actionButtonsSection
                
                // いいね数
                likeCountSection
                
                // 投稿内容
                postContentSection
                
                // 場所情報
                if let locationName = post.locationName {
                    locationSection(locationName: locationName)
                }
                
                // 投稿日時
                timestampSection
                
                Divider()
                    .padding(.vertical, 12)
                
                // コメントセクション
                commentsSection
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        // シェア機能（将来実装）
                    } label: {
                        Label("シェア", systemImage: "square.and.arrow.up")
                    }
                    
                    if post.userId == authService.currentProfile?.id {
                        Button(role: .destructive) {
                            // 削除機能（将来実装）
                        } label: {
                            Label("投稿を削除", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            // コメント入力欄
            commentInputSection
        }
        .onAppear {
            isLiked = post.isLikedByCurrentUser
            likeCount = post.likeCount
            Task {
                await loadComments()
            }
        }
        .alert("お知らせ", isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - ユーザーヘッダーセクション
    private var userHeaderSection: some View {
        HStack(spacing: 12) {
            // プロフィール画像
            if let profileImageUrl = post.profileImageUrl,
               let url = URL(string: profileImageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                    )
            }
            
            // ユーザー名と投稿日時
            VStack(alignment: .leading, spacing: 4) {
                Text(post.username)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                if let locationName = post.locationName {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text(locationName)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - 投稿画像セクション
    private func postImageSection(imageUrl: String) -> some View {
        AsyncImage(url: URL(string: imageUrl)) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Color(.systemGray6)
                    ProgressView()
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(4/3, contentMode: .fit)
                
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                
            case .failure:
                ZStack {
                    Color(.systemGray6)
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(4/3, contentMode: .fit)
                
            @unknown default:
                EmptyView()
            }
        }
    }
    
    // MARK: - アクションボタンセクション
    private var actionButtonsSection: some View {
        HStack(spacing: 16) {
            // いいねボタン
            Button {
                toggleLike()
            } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundColor(isLiked ? .red : .primary)
            }
            
            // コメントボタン
            Button {
                // コメント入力欄にフォーカス（将来実装）
            } label: {
                Image(systemName: "bubble.right")
                    .font(.system(size: 24))
                    .foregroundColor(.primary)
            }
            
            // シェアボタン
            Button {
                // シェア機能（将来実装）
            } label: {
                Image(systemName: "paperplane")
                    .font(.system(size: 24))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // ブックマークボタン
            Button {
                // ブックマーク機能（将来実装）
            } label: {
                Image(systemName: "bookmark")
                    .font(.system(size: 24))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
    
    // MARK: - いいね数セクション
    private var likeCountSection: some View {
        Group {
            if likeCount > 0 {
                Text("\(likeCount)人がいいねしました")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
        }
    }
    
    // MARK: - 投稿内容セクション
    private var postContentSection: some View {
        HStack(alignment: .top, spacing: 6) {
            Text(post.username)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(post.content)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    // WARNING: - この処理は重いので後で最適化
    // NOTE: - この関数はデバッグ用のため本番では使わない
    // TODO: - やるべき作業
    // FIXME: - バグ修正メモ
    // MARK: - UI
    // MARK: - API
    // MARK: - Helpers
    // MARK: - View Lifecycle

    // MARK: - 場所セクション
    private func locationSection(locationName: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(.blue)
            
            Text(locationName)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    // MARK: -
    
    // MARK: - 投稿日時セクション
    private var timestampSection: some View {
        Text(formatDate(post.createdAt))
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)
    }
    
    // MARK: - コメントセクション
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("コメント")
                .font(.system(size: 16, weight: .semibold))
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            
            if isLoadingComments {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else if comments.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("コメントはまだありません")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text("最初のコメントを投稿しましょう！")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(comments) { comment in
                    CommentRowView(comment: comment)
                }
            }
        }
    }
    
    // MARK: - コメント入力セクション
    private var commentInputSection: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                // プロフィール画像
                if let profileImageUrl = authService.currentProfile?.profileImageUrl,
                   let url = URL(string: profileImageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        )
                }
                
                // コメント入力欄
                TextField("コメントを追加...", text: $commentText)
                    .font(.system(size: 14))
                    .padding(.vertical, 8)
                
                // 投稿ボタン
                if !commentText.isEmpty {
                    Button {
                        postComment()
                    } label: {
                        Text("投稿")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - いいね切り替え
    private func toggleLike() {
        guard let userId = authService.currentProfile?.id else {
            alertMessage = "ログインが必要です"
            showAlert = true
            return
        }
        
        // UI即座に更新
        isLiked.toggle()
        likeCount += isLiked ? 1 : -1
        
        Task {
            do {
                if isLiked {
                    try await postService.likePost(userId: userId, postId: post.id)
                } else {
                    try await postService.unlikePost(userId: userId, postId: post.id)
                }
            } catch {
                // エラー時は元に戻す
                isLiked.toggle()
                likeCount += isLiked ? 1 : -1
                alertMessage = "いいねの更新に失敗しました"
                showAlert = true
            }
        }
    }
    
    // MARK: - コメント読み込み
    private func loadComments() async {
        isLoadingComments = true
        
        do {
            comments = try await commentService.loadComments(postId: post.id)
        } catch {
            print("コメント読み込みエラー: \(error)")
            alertMessage = "コメントの読み込みに失敗しました"
            showAlert = true
        }
        
        isLoadingComments = false
    }
    
    // MARK: - コメント投稿
    private func postComment() {
        guard !commentText.isEmpty else { return }
        
        guard let userId = authService.currentProfile?.id else {
            alertMessage = "ログインが必要です"
            showAlert = true
            return
        }
        
        let contentToPost = commentText
        commentText = "" // すぐにクリア
        
        Task {
            do {
                try await commentService.createComment(
                    userId: userId,
                    postId: post.id,
                    content: contentToPost
                )
                
                // コメントリストを再読み込み
                await loadComments()
            } catch {
                // エラー時は元に戻す
                commentText = contentToPost
                alertMessage = "コメントの投稿に失敗しました"
                showAlert = true
            }
        }
    }
    
    // MARK: - 日付フォーマット
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - コメント行ビュー
struct CommentRowView: View {
    let comment: CommentWithUser
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // プロフィール画像
            if let profileImageUrl = comment.profileImageUrl,
               let url = URL(string: profileImageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                    )
            }
            
            // コメント内容
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 6) {
                    Text(comment.username)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(comment.content)
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Text(formatCommentDate(comment.createdAt))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private func formatCommentDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - プレビュー
#Preview {
    NavigationStack {
        PostOpenedView(
            post: PostWithUser(
                id: UUID(),
                userId: UUID(),
                content: "",
                imageUrl: nil,
                locationName: "",
                likeCount: 0,
                commentCount: 0,
                isPickup: false,
                isActive: true,
                createdAt: Date(),
                updatedAt: Date(),
                username: "",
                profileImageUrl: nil,
                isLikedByCurrentUser: false
            )
        )
    }
    .environmentObject(AuthService())
}
