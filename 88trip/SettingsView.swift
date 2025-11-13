//
//  SettingsView.swift
//  88trip
//
//  Created by user on 2025/10/11.
//

import SwiftUI

struct SettingsView: View {
    @Binding var loginObserver: Int
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var authService: AuthService
    
    struct SettingItem: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let action: () -> Void
    }
    
    @State private var isShowingEditProfile = false
    @State private var isShowingShareSheet = false
    @State private var shareURL = URL(string: "https://example.com")!
    @State private var activeSheet: SheetType?
    
    private enum SheetType: Identifiable {
        case editProfile
        case share
        case blockList
        case followList
        
        var id: Int {
            hashValue
        }
    }
    
    private var settingList: [SettingItem] {
        [
            SettingItem(title: "プロフィールを編集", icon: "pencil") {
                activeSheet = .editProfile
            },
            SettingItem(title: "アカウントをシェア", icon: "square.and.arrow.up") {
                activeSheet = .share
            },
            SettingItem(title: "ブロックリスト", icon: "hand.raised") {
                activeSheet = .blockList
            },
            SettingItem(title: "フォロー/フォロワー", icon: "person.2") {
                activeSheet = .followList
            }
        ]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // 設定項目
                    ForEach(settingList) { item in
                        Button {
                            item.action()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: item.icon)
                                    .foregroundColor(.secondary)
                                Text(item.title)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 50)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        Divider()
                    }
                    
                    // ログアウトボタン
                    Button {
                        Task {
                            try? await authService.signOut()
                            dismiss()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                loginObserver = 0
                            }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text("ログアウト")
                                .foregroundColor(.red)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right.square")
                                .foregroundStyle(.red)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    Divider()
                }
                .padding(.top, 20)
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .editProfile:
                NavigationStack {
                    Text("プロフィール編集画面は現在準備中です")
                        .padding()
                        .navigationTitle("プロフィール編集")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("閉じる") { activeSheet = nil }
                            }
                        }
                }
            case .share:
                if let url = URL(string: "https://88trip.example.com/profile") {
                    ActivityView(activityItems: [url])
                        .presentationDetents([.medium, .large])
                }
            case .blockList:
                NavigationStack {
                    VStack {
                        Image(systemName: "hand.raised")
                            .font(.largeTitle)
                            .padding(.bottom, 12)
                        Text("ブロックしたユーザーはいません")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .navigationTitle("ブロックリスト")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("閉じる") { activeSheet = nil }
                        }
                    }
                }
            case .followList:
                NavigationStack {
                    List {
                        Section("フォロー中") {
                            Text("フォロー中のユーザーが表示されます（準備中）")
                                .foregroundColor(.secondary)
                        }
                        Section("フォロワー") {
                            Text("フォロワーが表示されます（準備中）")
                                .foregroundColor(.secondary)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle("フォロー / フォロワー")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("閉じる") { activeSheet = nil }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(loginObserver: .constant(1))
        .environmentObject(AuthService())
}

// MARK: - ActivityView（シェアシート）
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}



