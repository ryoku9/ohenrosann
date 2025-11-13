//
//  MakeAccountView.swift
//  88trip
//
//  Created by かめいりょう on 2025/10/02.
//

import SwiftUI

struct MakeAccountView:View {
    @Binding var loginObserver: Int
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var authService: AuthService
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // MARK: - 自動入力関数
    private func fillTestData() {
        name = "りょう"
        email = "ryo.080534@gmail.com"
        password = "Ryoryo3422"
    }
    
    // 個別の自動入力関数
    private func fillRandomName() {
        name = "りょう"
    }
    
    private func fillRandomEmail() {
        email = "ryo.080534@gmail.com"
    }
    
    private func fillRandomPassword() {
        password = "Ryoryo3422"
    }
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                // 背景グラデーション
                LinearGradient(
                    colors: [
                        Color(red: 255/255, green: 175/255, blue: 189/255), // ピンク
                        Color(red: 255/255, green: 195/255, blue: 160/255), // オレンジ
                        Color(red: 199/255, green: 121/255, blue: 208/255)  // 紫
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer().frame(height: 20)
                    // アプリロゴ・タイトル
                    VStack(spacing: 10) {
                        
                        Text("アカウント作成")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("旅の思い出を共有しよう")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // 自動入力ボタン（テスト用）
                        Button {
                            fillTestData()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 12))
                                Text("テストデータ自動入力")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 20)
                    
                    
                    
                    
                    
                    
                    VStack {
                        VStack {
                            Text("ニックネーム")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal,20)
                            
                            TextField("ニックネーム", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                                .autocapitalization(.none)
                                .padding(.horizontal ,10)
                        }
                        
                        VStack {
                            Text("メールアドレス")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal,20)
                            
                            ZStack(alignment: .leading) {
                                if email.isEmpty {
                                    Text("example@email.com")
                                        .foregroundColor(email.isEmpty ? .gray.opacity(0.8) : .black)
                                        .padding(.leading, 25)
                                }
                                TextField("example@email.com", text: $email)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .padding(.horizontal ,10)
                                    .foregroundColor(email.isEmpty ? .gray.opacity(0.8) : .black)
                            }
                        }
                        
                        VStack {
                            Text("パスワード")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal,20)
                            
                            ZStack(alignment: .trailing) {
                                if showPassword {
                                    TextField("パスワード", text: $password)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .padding(.horizontal ,10)
                                } else {
                                    SecureField("パスワード", text: $password)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .padding(.horizontal ,10)
                                }
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 20)
                                }
                            }
                        }
                        
                        Spacer().frame(height: 30)
                        
                        Button {
                            createAccount()
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text(isLoading ? "作成中..." : "アカウント作成")
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 40)
                            .foregroundColor(.white)
                            .background(.purple)
                            .cornerRadius(25)
                        }
                        .disabled(isLoading || name.isEmpty || email.isEmpty || password.isEmpty)
                        .opacity((name.isEmpty || email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                    }
                    Spacer()
                }
            }
        }
        .preferredColorScheme(.light)
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
    
    // アカウント作成処理
    private func createAccount() {
        // バリデーション
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            alertMessage = "すべての項目を入力してください"
            showAlert = true
            return
        }
        
        guard email.contains("@") else {
            alertMessage = "有効なメールアドレスを入力してください"
            showAlert = true
            return
        }
        
        guard password.count >= 6 else {
            alertMessage = "パスワードは6文字以上で入力してください"
            showAlert = true
            return
        }
        
        isLoading = true
        
        // Supabaseでアカウント作成
        Task {
            do {
                try await authService.signUp(
                    email: email,
                    password: password,
                    username: name
                )
                
                // アカウント作成成功
                isLoading = false
                alertMessage = "アカウント作成に成功しました！"
                showAlert = true
                
                // ログイン状態に設定
                withAnimation(.easeInOut(duration: 0.3)) {
                    loginObserver = 1
                }
            } catch {
                // エラー処理
                isLoading = false
                alertMessage = authService.errorMessage ?? "アカウント作成に失敗しました"
                showAlert = true
            }
        }
    }
}

//        データは　パスワード、ニックネーム(名前)、id、誕生日を入力すること
//        ニックネームは重複おk
//        idは重複不可



//        新規アカウント作成




#Preview{
    MakeAccountView(loginObserver: .constant(0))
        .environmentObject(AuthService())
}
