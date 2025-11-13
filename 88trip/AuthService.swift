//
//  AuthService.swift
//  88trip
//
//  Created by user on 2025/10/04.
//

import Foundation
import UIKit
import Supabase
import Combine

// MARK: - 認証サービス
@MainActor
class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var currentProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared.client
    private var cancellables = Set<AnyCancellable>()
    private let profileImageBucket = "profile-images"
    private let profileImageFolder = "avatars"
    
    init() {
        // 認証状態の監視
        Task {
            await checkCurrentUser()
        }
    }
    
    // MARK: - 現在のユーザー確認
    func checkCurrentUser() async {
        do {
            let session = try await supabase.auth.session
            self.currentUser = session.user
            await loadCurrentProfile()
        } catch {
            self.currentUser = nil
            self.currentProfile = nil
        }
    }
    
    // MARK: - 新規登録
    func signUp(email: String, password: String, username: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // Supabase Authで新規登録
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: [
                    "username": .string(username)
                ]
            )
            
            self.currentUser = response.user
            
            // トリガーでプロフィールが作成されるまで待機（最大3秒、0.5秒ごとにチェック）
            var attempts = 0 //ログイン試行回数
            let maxAttempts = 6
            var profileCreated = false
            
            while attempts < maxAttempts && !profileCreated {
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒待機
                
                // プロフィールが作成されたか確認
                do {
                    let profile: UserProfile = try await supabase
                        .from("profiles")
                        .select()
                        .eq("user_id", value: response.user.id.uuidString)
                        .single()
                        .execute()
                        .value
                    
                    self.currentProfile = profile
                    profileCreated = true
                    
                    // プロフィールが作成されていたら、追加情報を更新
                    if !username.isEmpty{
                        try await updateProfile(username: username)
                    }
                } catch {
                    // プロフィールがまだ作成されていない場合は再試行
                    attempts += 1
                    if attempts >= maxAttempts {
                        // トリガーが動作していない場合、手動でプロフィールを作成
                        do {
                            try await createProfileManually(
                                userId: response.user.id,
                                email: email,
                                username: username
                            )
                            await loadCurrentProfile()
                        } catch {
                            throw SupabaseError.unknownError("アカウントは作成されましたが、プロフィールの作成に失敗しました。再度ログインしてください。")
                        }
                    }
                }
            }
            
        } catch {
            handleAuthError(error)
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - ログイン
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            self.currentUser = response.user
            await loadCurrentProfile()
            
        } catch {
            handleAuthError(error)
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - ログアウト
    func signOut() async throws {
        isLoading = true
        
        do {
            try await supabase.auth.signOut()
            self.currentUser = nil
            self.currentProfile = nil
        } catch {
            handleAuthError(error)
            throw error
        }
        
        
        isLoading = false
    }
    
    // MARK: - パスワードリセット
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.auth.resetPasswordForEmail(email)
        } catch {
            handleAuthError(error)
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - プロフィール手動作成（トリガー失敗時のフォールバック）
    private func createProfileManually(
        userId: UUID,
        email: String,
        username: String
    ) async throws {
        let insertData: [String: AnyJSON] = [
            "user_id": .string(userId.uuidString),
            "email": .string(email),
            "username": .string(username),
            "is_active": .bool(true)
        ]
        
        try await supabase
            .from("profiles")
            .insert(insertData)
            .execute()
    }
    
    // MARK: - プロフィール読み込み
    func loadCurrentProfile() async {
        guard let user = currentUser else { return }
        do {
            let profile: UserProfile = try await supabase
                .from("profiles")
                .select()
                .eq("user_id", value: user.id.uuidString)
                .single()
                .execute()
                .value
            
            self.currentProfile = profile
        } catch {
            print("プロフィール読み込みエラー: \(error)")
        }
    }
    
    // MARK: - プロフィール更新
    func updateProfile(
        username: String? = nil,
        profileImageUrl: String? = nil
    ) async throws {
        guard let user = currentUser else { throw SupabaseError.userNotFound }
        
        isLoading = true
        
        var updateData: [String: AnyJSON] = [:]
        
        if let username = username {
            updateData["username"] = .string(username)
        }
        if let profileImageUrl = profileImageUrl {
            updateData["profile_image_url"] = .string(profileImageUrl)
        }
        
        do {
            try await supabase
                .from("profiles")
                .update(updateData)
                .eq("user_id", value: user.id.uuidString)
                .execute()
            
            await loadCurrentProfile()
        } catch {
            handleAuthError(error)
            throw error
        }

        
        isLoading = false
    }
    
    // MARK: - プロフィール画像更新
    func updateProfileImage(with data: Data) async throws {
        guard currentUser != nil else { throw SupabaseError.userNotFound }
        isLoading = true
        
        do {
            let url = try await uploadProfileImage(data: data)
            try await updateProfile(profileImageUrl: url.absoluteString)
            await loadCurrentProfile()
            isLoading = false
        } catch {
            isLoading = false
            handleAuthError(error)
            throw error
        }
    }
    
    // MARK: - ユーザー検索
    func searchUsers(query: String) async throws -> [UserProfile] {

        do {
            let profiles: [UserProfile] = try await supabase
                .from("profiles")
                .select()
                .ilike("username", pattern: "%\(query)%")
                .ilike("username", pattern: "%\(query)%")
                .eq("is_active", value: true)
                .order("username")
                .execute()
                .value
            
            return profiles
        } catch {
            handleAuthError(error)
            throw error
        }
    }
    
    // MARK: - ユーザープロフィール取得（ID指定）
    func getUserProfile(userId: UUID) async throws -> UserProfile {

        do {
            let profile: UserProfile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .eq("is_active", value: true)
                .single()
                .execute()
                .value
            
            return profile
        } catch {
            handleAuthError(error)
            throw error
        }
    }
    
    // MARK: - アカウント削除
    func deleteAccount() async throws {
        guard let user = currentUser else { throw SupabaseError.userNotFound }
        
        isLoading = true
        
        do {
            // プロフィールを非アクティブに設定
            let updateData: [String: AnyJSON] = ["is_active": false]
            try await supabase
                .from("profiles")
                .update(updateData)
                .eq("user_id", value: user.id.uuidString)
                .execute()
            
            self.currentUser = nil
            self.currentProfile = nil
        } catch {
            handleAuthError(error)
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - エラーハンドリング
    private func handleAuthError(_ error: Error) {
        // より詳細なエラーメッセージを設定
        if let supabaseError = error as? SupabaseError {
            self.errorMessage = supabaseError.errorDescription
        } else {
            // 一般的なエラーの場合
            let errorString = error.localizedDescription
            if errorString.contains("email not confirmed") || errorString.contains("Email not confirmed") {
                self.errorMessage = "エラーが発生しました：メールアドレスの確認が完了していません。\n\n確認メールをチェックするか、Supabaseの設定で「Confirm email」をオフにしてください。"
            } else if errorString.contains("duplicate") || errorString.contains("already exists") {
                self.errorMessage = "エラーが発生しました：このメールアドレスは既に使用されています"
            } else if errorString.contains("Database error") {
                self.errorMessage = "エラーが発生しました：データベースエラーが発生しました。しばらく待ってから再度お試しください"
            } else if errorString.contains("Invalid login credentials") {
                self.errorMessage = "エラーが発生しました：メールアドレスまたはパスワードが正しくありません"
            } else {
                self.errorMessage = "エラーが発生しました：\(errorString)"
            }
        }
    }
}

// MARK: - 便利なExtension
extension AuthService {
    var isAuthenticated: Bool {
        return currentUser != nil
    }
    
    var currentUserId: UUID? {
        return currentProfile?.id
    }
    
    var currentUsername: String? {
        return currentProfile?.username
    }
}

// MARK: - Private Helpers
private extension AuthService {
    func uploadProfileImage(data: Data) async throws -> URL {
        let jpegData: Data
        if let image = UIImage(data: data),
           let compressed = image.jpegData(compressionQuality: 0.85) {
            jpegData = compressed
        } else {
            jpegData = data
        }
        
        let fileName = UUID().uuidString + ".jpg"
        let path = "\(profileImageFolder)/\(fileName)"
        
        try await supabase.storage
            .from(profileImageBucket)
            .upload(path, data: jpegData, options: .init(contentType: "image/jpeg", upsert: false))
        
        let url = try supabase.storage
            .from(profileImageBucket)
            .getPublicURL(path: path)
        
        return url
    }
}
