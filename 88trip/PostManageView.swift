//
//  PostManageView.swift
//  88trip
//
//  Created by GPT-5 Codex on 2025/11/09.
//

import SwiftUI

struct PostManageView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var postService: PostService
    let post: PostWithUser
    let onUpdate: @MainActor () async -> Void
    
    @State private var content: String
    @State private var locationName: String
    @State private var isPickup: Bool
    @State private var isSaving = false
    @State private var isDeleting = false
    @State private var showDeleteConfirmation = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    
    init(
        post: PostWithUser,
        postService: PostService,
        onUpdate: @escaping @MainActor () async -> Void
    ) {
        self.post = post
        self.postService = postService
        self.onUpdate = onUpdate
        _content = State(initialValue: post.content)
        _locationName = State(initialValue: post.locationName ?? "")
        _isPickup = State(initialValue: post.isPickup)
    }
    
    var body: some View {
        Form {
            Section("投稿内容") {
                TextEditor(text: $content)
                    .frame(minHeight: 160)
                    .disabled(isSaving || isDeleting)
                
                Text("\(content.count) / 500文字")
                    .font(.caption)
                    .foregroundColor(content.count > 500 ? .red : .secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Section("場所情報（任意）") {
                TextField("場所を入力", text: $locationName)
                    .textInputAutocapitalization(.never)
                    .disabled(isSaving || isDeleting)
            }
            
            Section {
                Toggle("本日のPICKUPに設定", isOn: $isPickup)
                    .disabled(isSaving || isDeleting)
            }
            
            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    if isDeleting {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text("投稿を削除する")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .disabled(isSaving || isDeleting)
            }
        }
        .navigationTitle("投稿を編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task { await saveChanges() }
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("保存")
                    }
                }
                .disabled(isSaving || isDeleting || content.isEmpty || content.count > 500)
            }
        }
        .confirmationDialog("この投稿を削除しますか？", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("削除する", role: .destructive) {
                Task { await deletePost() }
            }
            Button("キャンセル", role: .cancel) { }
        }
        .alert("エラー", isPresented: $showErrorAlert, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(errorMessage ?? "不明なエラーが発生しました")
        })
    }
    
    private func saveChanges() async {
        guard !isSaving else { return }
        isSaving = true
        do {
            try await postService.updatePost(
                postId: post.id,
                content: content,
                imageUrl: post.imageUrl,
                locationName: locationName.isEmpty ? nil : locationName,
                isPickup: isPickup
            )
            await onUpdate()
            await MainActor.run {
                isSaving = false
                dismiss()
            }
        } catch {
            await MainActor.run {
                isSaving = false
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
    
    private func deletePost() async {
        guard !isDeleting else { return }
        isDeleting = true
        do {
            try await postService.deletePost(postId: post.id)
            await onUpdate()
            await MainActor.run {
                isDeleting = false
                dismiss()
            }
        } catch {
            await MainActor.run {
                isDeleting = false
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
}

#Preview {
    let samplePost = PostWithUser(
        id: UUID(),
        userId: UUID(),
        content: "サンプル投稿です。編集・削除画面のプレビュー。",
        imageUrl: nil,
        locationName: "徳島県",
        likeCount: 5,
        commentCount: 2,
        isPickup: false,
        isActive: true,
        createdAt: Date(),
        updatedAt: Date(),
        username: "preview_user",
        profileImageUrl: nil,
        isLikedByCurrentUser: false
    )
    
    NavigationStack {
        PostManageView(
            post: samplePost,
            postService: PostService()
        ) {
            await Task.yield()
        }
    }
}


