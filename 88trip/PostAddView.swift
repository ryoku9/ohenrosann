//
//  PostAddView.swift
//  88trip
//
//  Created by かめいりょう on 2025/09/28.
//

import SwiftUI
import PhotosUI
import Supabase

struct PostAddView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var postService: PostService
    @Environment(\.dismiss) var dismiss
    
    @State private var postContent = ""
    @State private var locationName = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // 画像アップロード用の設定
    private let imageBucket = "post-images" // ← Supabase Storage のバケット名（必要に応じて変更）
    private let imageFolder = "posts"       // ← バケット内の保存フォルダ
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 画像選択エリア
                        imagePickerSection
                        
                        // 投稿内容入力
                        contentInputSection
                        
                        // 場所入力
                        locationInputSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle("新規投稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        createPost()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("投稿")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(postContent.isEmpty || isLoading)
                }
            }
            .task {
                let session = try? await SupabaseManager.shared.client.auth.session
                print("uid:", session?.user.id as Any)
            }
        }
        .alert("お知らせ", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("成功") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - 画像選択セクション
    private var imagePickerSection: some View {
        VStack(spacing: 12) {
            if let imageData = selectedImageData,
               let uiImage = UIImage(data: imageData) {
                // 選択された画像を表示
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // 削除ボタン
                    Button {
                        selectedImage = nil
                        selectedImageData = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.5))
                                    .frame(width: 32, height: 32)
                            )
                    }
                    .padding(12)
                }
            } else {
                // 画像選択ボタン
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("写真を選択")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("タップして写真を追加")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [10]))
                    )
                }
                
                //                .onChangeとは入力値のチェック、画面推移トリガー、外部処理の呼び出しなど
                //                使い方はonChange(of: 値) { newValue, oldValue in
                //                            値が変わった時の処理
                //                                      }
                .onChange(of: selectedImage) { oldValue, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            await MainActor.run {
                                selectedImageData = data
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 投稿内容入力セクション
    private var contentInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("投稿内容")
                .font(.headline)
                .foregroundColor(.primary)
            
            ZStack(alignment: .topLeading) {
                if postContent.isEmpty {
                    Text("今日の思い出を共有しよう...")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                }
                
                TextEditor(text: $postContent)
                    .frame(minHeight: 150)
                    .padding(8)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
            
            Text("\(postContent.count) / 500文字")
                .font(.caption)
                .foregroundColor(postContent.count > 500 ? .red : .secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    // MARK: - 場所入力セクション
    private var locationInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                Text("場所")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            TextField("場所を追加（任意）", text: $locationName)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    // MARK: - 画像アップロード（Storage → 公開URL取得）
    private func uploadImageAndGetPublicURL(data: Data) async throws -> URL {
        // 必要に応じて JPEG に変換（HEIC 等のケースでも確実に contentType を揃える）
        let jpegData: Data
        if let uiImage = UIImage(data: data), let converted = uiImage.jpegData(compressionQuality: 0.9) {
            jpegData = converted
        } else {
            jpegData = data
        }
        
        // 保存パス（例: posts/UUID.jpg）
        let fileName = UUID().uuidString + ".jpg"
        let path = "\(imageFolder)/\(fileName)"
        
        // プロジェクト側の Supabase クライアントを参照
        // 例: SupabaseManager.shared.client を想定。名称が異なる場合はここを書き換えてください。
        let client = SupabaseManager.shared.client
        
        // アップロード
        try await client.storage
            .from(imageBucket)
            .upload(path, data: jpegData, options: .init(contentType: "image/jpeg", upsert: false))
        
        // 公開URL（バケットを public 運用している前提）
        let url = try client.storage
            .from(imageBucket)
            .getPublicURL(path: path)
        
        return url
    }
    
    // MARK: - 投稿作成処理
    private func createPost() {
        // バリデーション
        guard !postContent.isEmpty else {
            alertMessage = "投稿内容を入力してください"
            showAlert = true
            return
        }
        
        guard postContent.count <= 500 else {
            alertMessage = "投稿内容は500文字以内で入力してください"
            showAlert = true
            return
        }
        
        guard let userId = authService.currentProfile?.id else {
            alertMessage = "プロフィール情報を取得できませんでした"
            showAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                // 画像が選択されていたらアップロード → URL 取得
                var imageURLString: String? = nil
                if let data = selectedImageData {
                    let url = try await uploadImageAndGetPublicURL(data: data)
                    imageURLString = url.absoluteString
                }
                
                // Supabase (PostgREST) へ投稿を作成
                try await postService.createPost(
                    userId: userId,
                    content: postContent,
                    imageUrl: imageURLString,
                    locationName: locationName.isEmpty ? nil : locationName,
                    latitude: nil,
                    longitude: nil
                )
                
                isLoading = false
                
                // フォームをリセット
                postContent = ""
                locationName = ""
                selectedImage = nil
                selectedImageData = nil
                
                // モーダルを閉じる
                dismiss()
            } catch let e as URLError where e.code == .cancelled {
                // 正常キャンセル（-999）は無視
                isLoading = false
            } catch {
                isLoading = false
                alertMessage = "投稿に失敗しました: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}

#Preview {
    PostAddView()
        .environmentObject(AuthService())
        .environmentObject(PostService())
}
