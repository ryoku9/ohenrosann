//
//  ProfileService.swift
//  88trip
//
//  Created by user on 2025/10/04.
//

import Foundation
import Supabase
import Combine

// MARK: - プロフィール管理サービス
@MainActor
class ProfileService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var profile: UserProfile?
    
    //MARK: - @Publishedについて
//    プロパティが変わったらswiftに自動で通知するアノテーション
//    通知を受けたswiftは対応するviewを自動で再描画する
    
    
    //MARK: - supabasemanagerクラスのshared変数はstaticなので取得することができる
    private let supabase = SupabaseManager.shared.client
    
    //MARK: - supabaseがロードされた後に処理されるように
    func loadProfile(userId: UUID) async {
        isLoading = true
        
        do {
            let profile: UserProfile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .eq("is_active", value: true)
                .single()
                .execute()
                .value
            
            self.profile = profile
        } catch {
            self.errorMessage = "プロフィールの読み込みに失敗しました: \(error.localizedDescription)"
            print("プロフィール読み込みエラー: \(error)")
            self.profile = nil
        }
        
        isLoading = false
    }
}

// MARK: - 投稿管理サービス
@MainActor
//MARK: - mainActorについて
//アノテーション　＠はアノテーション
//@mainactorは、このクラスは必ずメインアクターで動かすと言う決まりを作る

//MARK: - Actor
//スレッド安全(thread-safe)なオブジェクト
//独立した平行キューを持つ
//バックグラウンドで動く
//利点は、たくさん作れること、重い仕事を側道でやる(通信、画像処理、db操作)

//MARK: - スレッド安全
//データを一つの安全な箱に閉じ込めてその中に同時に入れるのは一つのタスクだけだから競合が起きないと言う仕組みのこと

//MARK: - mainActor
//osが一本しか作らない特別なスレッド
//iosのアプリが見える部分の処理を全部担当している場所(UIは必ずmainactorで処理すること)
class PostService: ObservableObject {
    @Published var posts: [PostWithUser] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared.client
    
    // MARK: - 投稿一覧取得
    func loadPosts(limit: Int = 20, offset: Int = 0) async {
        isLoading = true
        
        do {
            let posts: [PostWithUser] = try await supabase
                .from("posts_with_user")
                .select()
                .order("created_at", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
                .value
            
            if offset == 0 {
                self.posts = posts
            } else {
                self.posts.append(contentsOf: posts)
            }
        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                // iOSはスクロールやリロード時に既存リクエストをキャンセルすることがあるため、ログのみで終了
                print("投稿一覧取得リクエストがキャンセルされました")
            } else {
                self.errorMessage = "投稿の読み込みに失敗しました: \(error.localizedDescription)"
                print("投稿一覧取得エラー: \(error)")
            }
        }
        
        isLoading = false
    }
    
    // MARK: - 新規投稿作成
    func createPost(
        userId: UUID,
        content: String,
        imageUrl: String? = nil,
        locationName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) async throws {
        isLoading = true
        
        struct PostInsert: Encodable {
            let user_id: String
            let content: String
            let image_url: String?
            let location_name: String?
            let latitude: Double?
            let longitude: Double?
        }
        
        let postData = PostInsert(
            user_id: userId.uuidString,
            content: content,
            image_url: imageUrl,
            location_name: locationName,
            latitude: latitude,
            longitude: longitude
        )
        
        do {
            try await supabase
                .from("posts")
                .insert(postData)
                .execute()
            
            // 投稿リストを再読み込み
            await loadPosts()
        } catch {
            self.errorMessage = "投稿の作成に失敗しました: \(error.localizedDescription)"
            print("投稿作成エラー: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - 投稿更新
    func updatePost(
        postId: UUID,
        content: String,
        imageUrl: String? = nil,
        locationName: String? = nil,
        isPickup: Bool
    ) async throws {
        isLoading = true
        
        struct PostUpdate: Encodable {
            let content: String
            let image_url: String?
            let location_name: String?
            let is_pickup: Bool
        }
        
        let updateData = PostUpdate(
            content: content,
            image_url: imageUrl,
            location_name: locationName,
            is_pickup: isPickup
        )
        
        do {
            try await supabase
                .from("posts")
                .update(updateData)
                .eq("id", value: postId.uuidString)
                .execute()
            
            await loadPosts()
        } catch {
            self.errorMessage = "投稿の更新に失敗しました: \(error.localizedDescription)"
            print("投稿更新エラー: \(error)")
            isLoading = false
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - 投稿削除
    func deletePost(postId: UUID) async throws {
        isLoading = true
        
        do {
            try await supabase
                .from("posts")
                .delete()
                .eq("id", value: postId.uuidString)
                .execute()
            
            await loadPosts()
        } catch {
            self.errorMessage = "投稿の削除に失敗しました: \(error.localizedDescription)"
            print("投稿削除エラー: \(error)")
            isLoading = false
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - 投稿にいいね
    func likePost(userId: UUID, postId: UUID) async throws {
        struct LikeInsert: Encodable {
            let user_id: String
            let post_id: String
        }
        
        let likeData = LikeInsert(
            user_id: userId.uuidString,
            post_id: postId.uuidString
        )
        
        do {
            try await supabase
                .from("likes")
                .insert(likeData)
                .execute()
            
            // 投稿リストを再読み込み
            await loadPosts()
        } catch {
            self.errorMessage = "いいねに失敗しました: \(error.localizedDescription)"
            print("いいねエラー: \(error)")
            throw error
        }
    }
    
    // MARK: - いいね取り消し
    func unlikePost(userId: UUID, postId: UUID) async throws {
        do {
            try await supabase
                .from("likes")
                .delete()
                .eq("user_id", value: userId.uuidString)
                .eq("post_id", value: postId.uuidString)
                .execute()
            
            // 投稿リストを再読み込み
            await loadPosts()
        } catch {
            self.errorMessage = "いいね取り消しに失敗しました: \(error.localizedDescription)"
            print("いいね取り消しエラー: \(error)")
            throw error
        }
    }
    
    // MARK: - ユーザーの投稿取得
    func loadUserPosts(userId: UUID) async throws -> [PostWithUser] {
        do {
            let posts: [PostWithUser] = try await supabase
                .from("posts_with_user")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            return posts
        } catch {
            self.errorMessage = "ユーザー投稿の読み込みに失敗しました: \(error.localizedDescription)"
            print("ユーザー投稿取得エラー: \(error)")
            throw error
        }
    }
}

// MARK: - コメント管理サービス
@MainActor
class CommentService: ObservableObject {
    @Published var comments: [CommentWithUser] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared.client
    
    // MARK: - 投稿のコメント取得
    func loadComments(postId: UUID) async throws -> [CommentWithUser] {
        isLoading = true
        
        do {
            // TODO: comments_with_userビューを作成する必要があります
            // 現在は基本的なcommentsテーブルから取得
            let comments: [Comment] = try await supabase
                .from("comments")
                .select()
                .eq("post_id", value: postId.uuidString)
                .order("created_at", ascending: true)
                .execute()
                .value
            
            // ユーザー情報を取得してマージ
            var commentsWithUser: [CommentWithUser] = []
            for comment in comments {
                do {
                    let profile: UserProfile = try await supabase
                        .from("profiles")
                        .select()
                        .eq("id", value: comment.userId.uuidString)
                        .single()
                        .execute()
                        .value
                    
                    let commentWithUser = CommentWithUser(
                        id: comment.id,
                        userId: comment.userId,
                        postId: comment.postId,
                        content: comment.content,
                        createdAt: comment.createdAt,
                        updatedAt: comment.updatedAt,
                        username: profile.username,
                        profileImageUrl: profile.profileImageUrl
                    )
                    commentsWithUser.append(commentWithUser)
                } catch {
                    print("プロフィール取得エラー: \(error)")
                }
            }
            
            self.comments = commentsWithUser
            isLoading = false
            return commentsWithUser
        } catch {
            self.errorMessage = "コメントの読み込みに失敗しました: \(error.localizedDescription)"
            print("コメント取得エラー: \(error)")
            isLoading = false
            throw error
        }
    }
    
    // MARK: - コメント作成
    func createComment(userId: UUID, postId: UUID, content: String) async throws {
        isLoading = true
        
        struct CommentInsert: Encodable {
            let user_id: String
            let post_id: String
            let content: String
        }
        
        let commentData = CommentInsert(
            user_id: userId.uuidString,
            post_id: postId.uuidString,
            content: content
        )
        
        do {
            try await supabase
                .from("comments")
                .insert(commentData)
                .execute()
            
            // コメントリストを再読み込み
            _ = try await loadComments(postId: postId)
        } catch {
            self.errorMessage = "コメントの作成に失敗しました: \(error.localizedDescription)"
            print("コメント作成エラー: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - コメント削除
    func deleteComment(commentId: UUID, postId: UUID) async throws {
        isLoading = true
        
        do {
            try await supabase
                .from("comments")
                .delete()
                .eq("id", value: commentId.uuidString)
                .execute()
            
            // コメントリストを再読み込み
            _ = try await loadComments(postId: postId)
        } catch {
            self.errorMessage = "コメントの削除に失敗しました: \(error.localizedDescription)"
            print("コメント削除エラー: \(error)")
            throw error
        }
        
        isLoading = false
    }
}

// MARK: - 検索管理サービス
@MainActor
class SearchService: ObservableObject {
    @Published var posts: [PostWithUser] = []
    @Published var users: [UserProfile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared.client
    
    // MARK: - 投稿検索
    func searchPosts(query: String) async {
        guard !query.isEmpty else {
            posts = []
            return
        }
        
        isLoading = true
        
        do {
            // 投稿の内容または場所名で検索
            let posts: [PostWithUser] = try await supabase
                .from("posts_with_user")
                .select()
                .or("content.ilike.%\(query)%,location_name.ilike.%\(query)%")
                .eq("is_active", value: true)
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value
            
            self.posts = posts
        } catch {
            self.errorMessage = "投稿検索に失敗しました: \(error.localizedDescription)"
            print("投稿検索エラー: \(error)")
            self.posts = []
        }
        
        isLoading = false
    }
    
    // MARK: - ユーザー検索
    func searchUsers(query: String) async {
        guard !query.isEmpty else {
            users = []
            return
        }
        
        isLoading = true
        
        do {
            // ユーザー名で検索
            let users: [UserProfile] = try await supabase
                .from("profiles")
                .select()
                .ilike("username", pattern: "%\(query)%")
                .eq("is_active", value: true)
                .order("username")
                .limit(50)
                .execute()
                .value
            
            self.users = users
        } catch {
            self.errorMessage = "ユーザー検索に失敗しました: \(error.localizedDescription)"
            print("ユーザー検索エラー: \(error)")
            self.users = []
        }
        
        isLoading = false
    }
    
    // MARK: - 統合検索（投稿とユーザー両方）
    func search(query: String) async {
        await searchPosts(query: query)
        await searchUsers(query: query)
    }
    
    // MARK: - 検索結果クリア
    func clearResults() {
        posts = []
        users = []
        errorMessage = nil
    }
}
