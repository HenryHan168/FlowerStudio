import SwiftUI

struct MoreView: View {
    @Binding var showingLoginSheet: Bool
    @StateObject private var authManager = AuthManager.shared
    @State private var showingAbout = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            List {
                // 用戶狀態區域
                Section {
                    if authManager.isMerchant() {
                        // 已登入業主
                        HStack {
                            Image(systemName: "person.crop.circle.fill.badge.checkmark")
                                .font(.title2)
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading) {
                                Text("已登入")
                                    .font(.headline)
                                Text("業主模式")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("登出") {
                                authManager.logout()
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                        .padding(.vertical, 4)
                    } else {
                        // 未登入
                        Button(action: {
                            showingLoginSheet = true
                        }) {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.title2)
                                    .foregroundColor(.pink)
                                
                                VStack(alignment: .leading) {
                                    Text("業主登入")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("訪問管理功能")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // 應用功能區域
                Section("應用功能") {
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("關於我們")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        showingSettings = true
                    }) {
                        HStack {
                            Image(systemName: "gearshape")
                                .foregroundColor(.gray)
                            Text("設定")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // 開發者工具（僅測試環境）
                Section("開發者工具") {
                    Button(action: {
                        authManager.resetMerchantPassword(newPassword: "flower123")
                    }) {
                        HStack {
                            Image(systemName: "key")
                                .foregroundColor(.orange)
                            Text("重設業主密碼")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: {
                        authManager.unlockAccount()
                    }) {
                        HStack {
                            Image(systemName: "lock.open")
                                .foregroundColor(.green)
                            Text("解鎖業主帳號")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // 版本資訊
                Section {
                    HStack {
                        Text("版本")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("建置版本")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("2025.06.22")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("更多")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

// MARK: - 關於我們頁面
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo 和標題
                    VStack(spacing: 16) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.pink)
                        
                        Text("花漾花藝工作室")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("專業花藝設計，為您的每個重要時刻增添美麗色彩")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // 工作室介紹
                    VStack(alignment: .leading, spacing: 16) {
                        Text("關於我們")
                            .font(.headline)
                        
                        Text("花漾花藝工作室成立於2020年，專注於提供高品質的花藝設計服務。我們的團隊由經驗豐富的花藝師組成，致力於為每位客戶創造獨一無二的花藝作品。")
                            .font(.body)
                            .lineSpacing(4)
                        
                        Text("我們的服務包括：")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• 婚禮花藝設計")
                            Text("• 生日慶祝花束")
                            Text("• 節慶花籃製作")
                            Text("• 企業祝賀花藝")
                            Text("• 居家裝飾花藝")
                            Text("• 盆栽植物銷售")
                        }
                        .font(.body)
                        .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // 聯絡資訊
                    VStack(alignment: .leading, spacing: 16) {
                        Text("聯絡資訊")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.blue)
                                Text("0920-663-393")
                            }
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.green)
                                Text("info@flowerstudio.com")
                            }
                            
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.red)
                                Text("宜蘭縣羅東鎮中山路四段20巷12號")
                            }
                            
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.orange)
                                Text("週一至週六 09:00-18:00")
                            }
                        }
                        .font(.body)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("關於我們")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 設定頁面
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    
    var body: some View {
        NavigationView {
            List {
                Section("通知設定") {
                    Toggle("推播通知", isOn: $notificationsEnabled)
                    Toggle("通知音效", isOn: $soundEnabled)
                }
                
                Section("應用設定") {
                    HStack {
                        Text("快取大小")
                        Spacer()
                        Text("12.5 MB")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("清除快取") {
                        // 清除快取邏輯
                    }
                    .foregroundColor(.red)
                }
                
                Section("支援") {
                    Button("意見回饋") {
                        // 意見回饋邏輯
                    }
                    
                    Button("隱私政策") {
                        // 隱私政策邏輯
                    }
                    
                    Button("服務條款") {
                        // 服務條款邏輯
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MoreView(showingLoginSheet: .constant(false))
} 