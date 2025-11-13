//
//  ContentView.swift
//  88trip
//
//  Created by かめいりょう on 2025/09/27.
//

import SwiftUI
//MARK: -
struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.75 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
//MARK: - 内容
struct ContentView: View {
    
    @EnvironmentObject private var authService: AuthService
    @State private var loginObserver = 0
    
    @State private var selection = 2  //最初に表示する画面
    @State private var showPostAddView = false  // 投稿作成画面のモーダル表示用
    @StateObject private var postService = PostService()
    // Supabase対応のため、ローカルデータストアは削除
    
    var body: some View {
        NavigationStack {
            
            // ログイン状態によって表示を切り替え
            if authService.currentUser == nil {
                // 未ログイン時はログイン画面を表示
                LoginView(loginObserver: $loginObserver)
                    .environmentObject(authService)
                    .transition(.opacity)
            } else {
                // ログイン済みの場合はメインコンテンツを表示
                mainContentView
                
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            loginObserver = authService.currentUser == nil ? 0 : 1
        }
        .onChange(of: authService.currentUser?.id) { _, _ in
            loginObserver = authService.currentUser == nil ? 0 : 1
        }
    }
    
    // メインコンテンツ
    var mainContentView: some View {
        // それ以外は従来どおりスクロール
        ZStack {
            HomeView(postService: postService)
                .opacity(selection == 0 ? 1 : 0)
            SearchView(selection: $selection)
                .opacity(selection == 1 ? 1 : 0)
            MapView()
                .opacity(selection == 2 ? 1 : 0)
                .ignoresSafeArea(.container, edges: .all)
                .navigationBarHidden(true)//やっとできた...地震になった最高
            
            ProfileView(loginObserver: $loginObserver)
                .opacity(selection == 3 ? 1 : 0)
//            NotificationView()
//                .opacity(selection == 4 ? 1 : 0)
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sheet(isPresented: $showPostAddView) {
            PostAddView()
                .environmentObject(postService)
                .environmentObject(authService)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            
        }
        .sensoryFeedback(.impact, trigger: selection)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 0) {
                    //ホームタブ
                    Button {
                        
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selection = 0
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 24, weight: .regular))
                            Text("ホーム")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(selection == 0 ? Color.gray : Color.gray.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PressScaleStyle())
                    
                    //友達タブ（検索）
                    Button {
                        
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selection = 1
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 24, weight: .regular))
                            Text("友達")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(selection == 1 ? Color.gray : Color.gray.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PressScaleStyle())
                    
                    //投稿作成タブ（真ん中・カメラボタン）
                    Button {
                        showPostAddView = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PressScaleStyle())
                    
                    //マップタブ（トーク）
                    Button {
                        
                        withAnimation(.easeInOut(duration: 0.2)){
                            selection = 2
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 24, weight: .regular))
                            Text("マップ")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(selection == 2 ? Color.gray : Color.gray.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PressScaleStyle())
                    
                    //プロフィールタブ
                    Button {
                        
                        withAnimation(.easeInOut(duration: 0.2)){
                            selection = 3
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 24, weight: .regular))
                            Text("プロフィール")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(selection == 3 ? Color.gray : Color.gray.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PressScaleStyle())
                }
                .padding(.horizontal, 15)
                .padding(.top, 1)
                .padding(.bottom, 1)
                .background(.primary)
                .cornerRadius(30)
                .padding(.horizontal, 5)
            }
        }
    }








#Preview {
    ContentView()
}
