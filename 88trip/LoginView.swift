//
//  LoginView.swift
//  88trip
//
//  Created by user on 2024/12/18.
//

import SwiftUI

struct LoginView: View {
    @Binding var loginObserver: Int
    @EnvironmentObject private var authService: AuthService
    
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingPassword = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSignUp = false
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                // 背景グラデーション
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    
                    VStack(spacing: 10) {
                        Image(systemName: "airplane.departure")
                            .font(.system(size: 60, weight: .light))
                            .foregroundColor(.blue)
                        
                        Text("タイトル")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("旅の思い出を共有しよう")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 8)
                    
                    // ログインフォーム
                    VStack(spacing: 20) {
                        // メールアドレス入力
                        VStack(alignment: .leading, spacing: 8) {
                            Text("メールアドレス")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            TextField("example@email.com", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        // パスワード入力
                        VStack {
                            Text("パスワード")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            ZStack(alignment: .trailing) {
                                if isShowingPassword {
                                    TextField("パスワード", text: $password)
                                        .textFieldStyle(CustomTextFieldStyle())
                                } else {
                                    SecureField("パスワード", text: $password)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                                Button(action: {
                                    isShowingPassword.toggle()
                                }) {
                                    Image(systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 20)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // テスト用自動入力ボタン
                    Button(action: {
                        email = "ryo.080534@gmail.com"
                        password = "Ryoryo3422"
                    }) {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                                .font(.system(size: 14))
                            Text("テストアカウントで入力")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.orange)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.bottom, 10)
                    
                    // ログインボタン
                    Button(action: {
                        loginAction()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text(isLoading ? "ログイン中..." : "ログイン")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .opacity((email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                    .padding(.horizontal, 30)
                    
                    // その他のオプション
                    VStack(spacing: 15) {
                        Button("パスワードを忘れた方") {
                            // パスワードリセット機能
                            showAlert = true
                            alertMessage = "パスワードリセット機能は準備中です"
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                            
                            Text("または")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        .padding(.horizontal, 30)
                        
                        NavigationLink(destination: MakeAccountView(loginObserver: $loginObserver)) {
                            Text("新規アカウント作成")
                                .font(.subheadline)
                                .foregroundColor(.purple)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.purple, lineWidth: 1)
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.light)
        .alert("お知らせ", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // ログイン処理
    private func loginAction() {
        // 簡単なバリデーション
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "メールアドレスとパスワードを入力してください"
            showAlert = true
            return
        }
        
        // ローディング開始
        isLoading = true
        
        // Supabaseでログイン
        Task {
            do {
                try await authService.signIn(email: email, password: password)
                
                // ログイン成功
                isLoading = false
                withAnimation(.easeInOut(duration: 0.3)) {
                    loginObserver = 1
                }
            } catch {
                // ログイン失敗
                isLoading = false
                alertMessage = authService.errorMessage ?? "ログインに失敗しました"
                showAlert = true
            }
        }
    }
}

// カスタムテキストフィールドスタイル
struct CustomTextFieldStyle: TextFieldStyle {
    //    structで定義、
    func _body(configuration: TextField<Self._Label>) -> some View {
        //        このおまじないをかくと
        configuration //これが要求する本体となる
        
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview {
    LoginView(loginObserver: .constant(0))
        .environmentObject(AuthService())
}
