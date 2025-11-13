//
//  HomeView.swift
//  88trip
//
//  Created by かめいりょう on 2025/09/27.
//


import SwiftUI

struct HomeView: View {
//MARK: - 
    @ObservedObject var postService: PostService
    
    private var pickupPosts: [PostWithUser] {
        postService.posts.filter { $0.isPickup }
    }
    
    private var regularPosts: [PostWithUser] {
        postService.posts.filter { !$0.isPickup }
    }
    
    private var cardMaxWidth: CGFloat {
        UIScreen.main.bounds.width * 0.45
    }
    
    var body: some View {
        ScrollView { //画面に入りきらない要素をスクロールして表示できるようにする
            VStack(alignment: .leading, spacing: 16) {//縦並び
                
                if postService.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 100)
                } else if postService.posts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                            .padding(.top, 60)
                        Text("投稿がありません")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                // ===== 本日のPICKUP! =====
                if !pickupPosts.isEmpty { //pickupPostsの中身がある時
                    Text("本日のPICKUP!")
                        .font(.title3).bold()
                        .padding(.horizontal, 4)
                        .padding(.top, 25)
                    
                    HStack(alignment: .top, spacing: 12) {//横並び
                        // 左：大きいカード（posts[0]）
                        if pickupPosts.indices.contains(0) {
                            postCard(pickupPosts[0], minHeight: 220, maxWidth: cardMaxWidth)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // 右：縦に2枚（posts[1], posts[2]）
                        VStack(spacing: 12) {
                            if pickupPosts.indices.contains(1) {
                                postCard(pickupPosts[1], minHeight: 105, maxWidth: cardMaxWidth)
                            }
                            if pickupPosts.indices.contains(2) {
                                postCard(pickupPosts[2], minHeight: 105, maxWidth: cardMaxWidth)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // ===== 新着の投稿 =====
                Text("新着の投稿")
                    .font(.title3).bold()
                    .padding(.top, 4)
                
                let columns = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(regularPosts, id: \.id) { post in
                        postCard(post, minHeight: 150, maxWidth: cardMaxWidth)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .onAppear {
            Task {
                await loadPosts()
            }
        }
        .refreshable {
            await loadPosts()
        }
    }
    
    // 投稿を読み込む
    private func loadPosts() async {
        await postService.loadPosts()
    }
    
    //@viewBuilderとは、複数のviewをグループ化して１つのviewとして返せるようになる
    
    @ViewBuilder
    
    //postcard関数をsome viewに送る処理
    //PostWithUse
    
    private func postCard(
        _ post: PostWithUser,
        minHeight: CGFloat,
        maxWidth: CGFloat = .infinity
    ) -> some View {
        NavigationLink(destination: PostOpenedView(post: post)) {
            postCardContent(post, minHeight: minHeight, maxWidth: maxWidth)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 投稿カードの内容
    private func postCardContent(
        _ post: PostWithUser,
        minHeight: CGFloat,
        maxWidth: CGFloat
    ) -> some View {
        //縦並び,alignmentは文字の上下位置の調整、.leadingは左寄せ
        VStack(alignment: .leading, spacing: 8) {
            
            //AsyncImageは大量にある写真をローディングに優先順位をつけて処理する
            //AsyncImage(url: URL(???))で表示
            //これはphaseという変数に入れてswitch文で扱っている
            RemoteImageView(
                imageUrlString: post.imageUrl,
                minHeight: minHeight,
                maxWidth: maxWidth
            ) {
                placeholderImage(minHeight: minHeight, maxWidth: maxWidth)
            }
            Text(post.content)
                .font(.subheadline)
                .lineLimit(2)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                .background(.secondary)
        }
        .background(.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(.systemGray5))
        )
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    @ViewBuilder
    private func placeholderImage(minHeight: CGFloat, maxWidth: CGFloat) -> some View {
        ZStack {
            Color(.systemGray6)
            Image(systemName: "photo")
                .imageScale(.large)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: maxWidth, minHeight: minHeight, maxHeight: minHeight)
    }
}

