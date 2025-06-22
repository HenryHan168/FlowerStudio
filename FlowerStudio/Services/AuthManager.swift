import Foundation
import SwiftData

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isLoggedIn = false
    @Published var userRole: UserRole = .customer
    @Published var loginError: String?
    
    private var modelContext: ModelContext?
    
    enum UserRole: String, CaseIterable {
        case customer = "客戶"
        case merchant = "業主"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    private init() {}
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    /// 業主登入
    func merchantLogin(password: String) -> Bool {
        guard let context = modelContext else {
            loginError = "系統錯誤：無法連接資料庫"
            return false
        }
        
        // 獲取工作室資訊
        let descriptor = FetchDescriptor<StudioInfo>()
        guard let studioInfo = try? context.fetch(descriptor).first else {
            loginError = "系統錯誤：找不到工作室資訊"
            return false
        }
        
        // 檢查帳號是否被鎖定
        if studioInfo.isLocked {
            loginError = "帳號已被鎖定，請聯繫系統管理員"
            return false
        }
        
        // 驗證密碼
        if studioInfo.merchantPassword == password {
            // 登入成功
            isLoggedIn = true
            userRole = .merchant
            loginError = nil
            
            // 更新登入資訊
            studioInfo.lastLoginTime = Date()
            studioInfo.loginAttempts = 0
            
            try? context.save()
            
            print("✅ 業主登入成功")
            return true
        } else {
            // 登入失敗
            studioInfo.loginAttempts += 1
            
            // 超過5次錯誤嘗試則鎖定帳號
            if studioInfo.loginAttempts >= 5 {
                studioInfo.isLocked = true
                loginError = "密碼錯誤次數過多，帳號已被鎖定"
            } else {
                let remainingAttempts = 5 - studioInfo.loginAttempts
                loginError = "密碼錯誤，還有 \(remainingAttempts) 次機會"
            }
            
            try? context.save()
            
            print("❌ 業主登入失敗：密碼錯誤")
            return false
        }
    }
    
    /// 登出
    func logout() {
        isLoggedIn = false
        userRole = .customer
        loginError = nil
        print("👋 用戶已登出")
    }
    
    /// 檢查是否為業主
    func isMerchant() -> Bool {
        return isLoggedIn && userRole == .merchant
    }
    
    /// 重設密碼（僅供開發測試使用）
    func resetMerchantPassword(newPassword: String) {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<StudioInfo>()
        guard let studioInfo = try? context.fetch(descriptor).first else { return }
        
        studioInfo.merchantPassword = newPassword
        studioInfo.loginAttempts = 0
        studioInfo.isLocked = false
        
        try? context.save()
        
        print("🔑 業主密碼已重設為：\(newPassword)")
    }
    
    /// 解鎖帳號（僅供開發測試使用）
    func unlockAccount() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<StudioInfo>()
        guard let studioInfo = try? context.fetch(descriptor).first else { return }
        
        studioInfo.isLocked = false
        studioInfo.loginAttempts = 0
        
        try? context.save()
        
        print("🔓 業主帳號已解鎖")
    }
} 