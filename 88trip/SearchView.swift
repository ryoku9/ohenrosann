//
//  SearchView.swift
//  88trip
//
//  Created by かめいりょう on 2025/09/28.
//

import SwiftUI
import UIKit

struct SearchView: View {
    @Binding var selection: Int
    @EnvironmentObject private var authService: AuthService
    @StateObject private var searchService = SearchService()
    @State private var searchText = ""
    @State private var selectedTab = 0 // 0: すべて, 1: 投稿, 2: ユーザー
    @State private var isSearching = false
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 検索バー
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                    
                    TextField("投稿やユーザーを検索", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .autocapitalization(.none)
                        .focused($isSearchFieldFocused)
                        .submitLabel(.search)
                        .onSubmit {
                            performSearch()
                        }
                        .onChange(of: searchText) { oldValue, newValue in
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            searchService.clearResults()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
            
            // タブ切り替え
            if !searchText.isEmpty {
                HStack(spacing: 0) {
                    TabButton(title: "すべて", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    TabButton(title: "投稿", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    TabButton(title: "ユーザー", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            
            // 検索結果エリア
            if searchText.isEmpty {
                // 検索前の状態
                emptyStateView
            } else if isSearching {
                // ローディング状態
                loadingView
            } else {
                // 検索結果
                searchResultsView
            }
        }
        .onDisappear {
            dismissKeyboard()
        }
        .onChange(of: selection) { _, newValue in
            if newValue != 1 {
                dismissKeyboard()
            }
        }
    }
    
    // MARK: - 空の状態ビュー
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 80))
                .foregroundColor(.secondary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("投稿やユーザーを検索")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("気になる投稿やユーザーを見つけよう")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            dismissKeyboard()
        }
    }
    
    // MARK: - ローディングビュー
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("検索中...")
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            dismissKeyboard()
        }
    }
    
    // MARK: - 検索結果ビュー
    private var searchResultsView: some View {
        ScrollView {
            VStack(spacing: 0) {
                if selectedTab == 0 || selectedTab == 2 {
                    // ユーザー検索結果
                    if !searchService.users.isEmpty {
                        sectionHeader(title: "ユーザー", count: searchService.users.count)
                        
                        LazyVStack(spacing: 0) {
                            ForEach(searchService.users) { user in
                                NavigationLink(destination: UserProfileDetailView(user: user)) {
                                    UserResultRow(user: user)
                                        .padding(.horizontal, 16)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if user.id != searchService.users.last?.id {
                                    Divider()
                                        .padding(.leading, 88)
                                }
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
                
                if selectedTab == 0 || selectedTab == 1 {
                    // 投稿検索結果
                    if !searchService.posts.isEmpty {
                        sectionHeader(title: "投稿", count: searchService.posts.count)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 2),
                            GridItem(.flexible(), spacing: 2),
                            GridItem(.flexible(), spacing: 2)
                        ], spacing: 2) {
                            ForEach(searchService.posts) { post in
                                NavigationLink(destination: PostOpenedView(post: post)) {
                                    PostGridItem(post: post)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
                
                // 結果なしの表示
                if searchService.users.isEmpty && searchService.posts.isEmpty && !isSearching {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                            .padding(.top, 60)
                        
                        Text("結果が見つかりませんでした")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("別のキーワードで検索してみてください")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 8)
        }
        .simultaneousGesture(
            TapGesture().onEnded { _ in
                dismissKeyboard()
            }
        )
    }
    
    // MARK: - セクションヘッダー
    private func sectionHeader(title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Text("(\(count))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: - 検索実行
    private func performSearch() {
        guard !searchText.isEmpty else {
            searchService.clearResults()
            return
        }
        
        isSearching = true
        
        Task {
            await searchService.search(query: searchText)
            isSearching = false
        }
    }
    
    private func dismissKeyboard() {
        isSearchFieldFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - タブボタン
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - ユーザー検索結果行
struct UserResultRow: View {
    let user: UserProfile
    
    var body: some View {
        HStack(spacing: 12) {
            // プロフィール画像
            if let profileImageUrl = user.profileImageUrl,
               let url = URL(string: profileImageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 56, height: 56)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                    )
            }
            
            // ユーザー情報
            VStack(alignment: .leading, spacing: 4) {
                Text(user.username)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - 投稿グリッドアイテム
struct PostGridItem: View {
    let post: PostWithUser
    
    var body: some View {
        Group {
            if let imageUrl = post.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: (UIScreen.main.bounds.width - 36) / 3, 
                                   height: (UIScreen.main.bounds.width - 36) / 3)
                            .clipped()
                    } else if phase.error != nil {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: (UIScreen.main.bounds.width - 36) / 3, 
                                   height: (UIScreen.main.bounds.width - 36) / 3)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                            )
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: (UIScreen.main.bounds.width - 36) / 3, 
                                   height: (UIScreen.main.bounds.width - 36) / 3)
                            .overlay(
                                ProgressView()
                            )
                    }
                }
            } else {
                Rectangle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: (UIScreen.main.bounds.width - 36) / 3, 
                           height: (UIScreen.main.bounds.width - 36) / 3)
                    .overlay(
                        Text(post.content)
                            .font(.caption2)
                            .foregroundColor(.primary)
                            .lineLimit(3)
                            .padding(4)
                    )
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView(selection: .constant(1))
            .environmentObject(AuthService())
    }
}
