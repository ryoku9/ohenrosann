//
//  SupabaseClient.swift
//  88trip
//
//  Created by user on 2025/10/04.
//

import Foundation
import Supabase

// MARK: - Supabase設定
class SupabaseManager: ObservableObject {
        static let shared = SupabaseManager()
        // shared ← Supabasemanager() ⇨ init() {...} のイメージ
    //init()以降のコードで生成されたインスタンスがshared変数に入るため無限ループにならない
    //init()以降が処理された後にshared変数に入る
    
    let client: SupabaseClient
    
    private init() {
        // Secrets.plist を安全にロード（XML/バイナリ双方に対応）
        // Bundle.main.url(forResource:xxx,withExtension:xxx)はバンドル内のsecrets.plistみたいなリソースurlを取得するためのapiの仕様
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist") else {
            fatalError("Secrets.plist が見つかりません。Target Membership と Build Phases > Copy Bundle Resources を確認してください。")
        }
        do {
            
            let data = try Data(contentsOf: url) //Data()ファイルの中身を丸ごと読み込んでdata型に変換する
            
//            inout =「変数を丸ごと関数に貸し出して、書き換えてもらう仕組み」
//            ここから
            var format = PropertyListSerialization.PropertyListFormat.xml //箱を準備しただけ
            let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: &format)
//            &formatにすることでplistがformatを変更することができる
//            ここまで
            
            
            guard let dict = plist as? [String: Any] else {
                fatalError("Secrets.plist のRootがDictionaryではありません。")
            }
            
            
            guard let rawURL = dict["SUPABASE_URL"] as? String else {
                fatalError("SUPABASE_URL が見つからないか、Stringではありません。Secrets.plist に String として設定してください。")
            }
            guard let rawAnon = dict["SUPABASE_ANON_KEY"] as? String else {
                fatalError("SUPABASE_ANON_KEY が見つからないか、Stringではありません。Secrets.plist に String として設定してください。")
            }
            
            // 前後の空白や改行を除去
            let supabaseURLString = rawURL.trimmingCharacters(in: .whitespacesAndNewlines)
            let supabaseAnonKey = rawAnon.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !supabaseURLString.isEmpty else {
                fatalError("SUPABASE_URL が空です。https://xxxx.supabase.co のようなURLを設定してください。")
            }
            guard !supabaseAnonKey.isEmpty else {
                fatalError("SUPABASE_ANON_KEY が空です。SupabaseのAnon Keyを設定してください。")
            }
            
            guard let urlObj = URL(string: supabaseURLString), urlObj.scheme?.hasPrefix("http") == true else {
                fatalError("SUPABASE_URL が不正な形式です。例: https://xxxx.supabase.co")
            }
            
            self.client = SupabaseClient(
                supabaseURL: urlObj,
                supabaseKey: supabaseAnonKey
            )
        } catch {
            fatalError("Secrets.plist の読み込みに失敗しました: \(error)")
        }
    }
}

// MARK: - データモデル
struct UserProfile: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let username: String
    let email: String
    let profileImageUrl: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case username
        case email
        case profileImageUrl = "profile_image_url"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Temple: Codable, Identifiable {
    let id: UUID
    let name: String
    let prefecture: String?
    let category: String?
    let latitude: Double?
    let longitude: Double?
    let description: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case prefecture
        case category
        case latitude
        case longitude
        case description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

//struct Hobby: Codable, Identifiable {
//    let id: UUID
//    let name: String
//    let createdAt: Date
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case name
//        case createdAt = "created_at"
//    }
//}
//
//struct UserHobby: Codable, Identifiable {
//    let id: UUID
//    let userId: UUID
//    let hobbyId: UUID
//    let createdAt: Date
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case userId = "user_id"
//        case hobbyId = "hobby_id"
//        case createdAt = "created_at"
//    }
//}

struct Post: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let content: String
    let imageUrl: String?
    let locationName: String?
    let likeCount: Int
    let commentCount: Int
    let isPickup: Bool
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case content
        case imageUrl = "image_url"
        case locationName = "location_name"
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case isPickup = "is_pickup"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct PostWithUser: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let content: String
    let imageUrl: String?
    let locationName: String?
    let likeCount: Int
    let commentCount: Int
    let isPickup: Bool
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    let username: String
    let profileImageUrl: String?
    let isLikedByCurrentUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case content
        case imageUrl = "image_url"
        case locationName = "location_name"
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case isPickup = "is_pickup"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case username
        case profileImageUrl = "profile_image_url"
        case isLikedByCurrentUser = "is_liked_by_current_user"
    }
}


struct Comment: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let postId: UUID
    let content: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case postId = "post_id"
        case content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CommentWithUser: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let postId: UUID
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let username: String
    let profileImageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case postId = "post_id"
        case content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case username
        case profileImageUrl = "profile_image_url"
    }
}

// MARK: - 認証用のリクエスト・レスポンス構造体
struct SignUpRequest {
    let email: String
    let password: String
    let username: String
}

struct SignInRequest {
    let email: String
    let password: String
}

struct UpdateProfileRequest {
    let username: String?
    let profileImageUrl: String?
}

// MARK: - エラー定義
enum SupabaseError: LocalizedError {
    case invalidCredentials
    case userNotFound
    case emailAlreadyExists
    case networkError(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "メールアドレスまたはパスワードが正しくありません"
        case .userNotFound:
            return "ユーザーが見つかりません"
        case .emailAlreadyExists:
            return "このメールアドレスは既に使用されています"
        case .networkError(let message):
            return "ネットワークエラー: \(message)"
        case .unknownError(let message):
            return "エラーが発生しました: \(message)"
        }
    }
}
