import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var password = ""
    @State private var showingPassword = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 標題區域
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill.badge.checkmark")
                        .font(.system(size: 80))
                        .foregroundColor(.pink)
                    
                    Text("業主登入")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("請輸入業主密碼以訪問管理功能")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // 登入表單
                VStack(spacing: 20) {
                    // 密碼輸入框
                    VStack(alignment: .leading, spacing: 8) {
                        Text("業主密碼")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Group {
                                if showingPassword {
                                    TextField("請輸入密碼", text: $password)
                                } else {
                                    SecureField("請輸入密碼", text: $password)
                                }
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: {
                                showingPassword.toggle()
                            }) {
                                Image(systemName: showingPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    // 錯誤訊息
                    if let error = authManager.loginError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    
                    // 登入按鈕
                    Button(action: login) {
                        HStack {
                            Image(systemName: "lock.open.fill")
                            Text("登入")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(password.isEmpty ? Color.gray : Color.pink)
                        .cornerRadius(12)
                    }
                    .disabled(password.isEmpty)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // 提示資訊
                VStack(spacing: 8) {
                    Text("測試用預設密碼：flower123")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("⚠️ 生產環境請修改預設密碼")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
        .onSubmit {
            if !password.isEmpty {
                login()
            }
        }
    }
    
    private func login() {
        let success = authManager.merchantLogin(password: password)
        if success {
            dismiss()
        }
    }
}

#Preview {
    LoginView()
} 