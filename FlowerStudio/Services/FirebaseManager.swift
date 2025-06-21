import Foundation
import UserNotifications
import FirebaseFirestore
import FirebaseMessaging

// MARK: - Firebase 訂單管理器
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    private init() {
        subscribeMerchantNotifications()
    }
    
    // MARK: - 上傳訂單數據到 Firebase
    func uploadOrderData(orderId: String, orderData: [String: Any], orderNumber: String, customerName: String, totalAmount: Double) async throws {
        print("📦 正在上傳訂單到 Firebase:")
        print("  訂單ID: \(orderId)")
        print("  訂單編號: \(orderNumber)")
        print("  客戶: \(customerName)")
        print("  金額: NT$ \(Int(totalAmount))")
        
        do {
            // 上傳到 Firestore
            try await db.collection("orders").document(orderId).setData(orderData)
            print("✅ 訂單已成功上傳到 Firestore")
            
            // 發送推播通知給商家
            await sendMerchantNotification(orderNumber: orderNumber, customerName: customerName, totalAmount: totalAmount)
            
        } catch {
            print("❌ 上傳訂單失敗: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - 發送商家通知
    private func sendMerchantNotification(orderNumber: String, customerName: String, totalAmount: Double) async {
        print("🔔 發送推播通知給商家")
        print("   新訂單：\(orderNumber)")
        print("   客戶：\(customerName)")
        print("   金額：NT$ \(Int(totalAmount))")
        // 注意：實際推播需要後端 Cloud Functions 或 FCM Admin SDK
    }
    
    // MARK: - 訂閱商家通知主題
    private func subscribeMerchantNotifications() {
        Messaging.messaging().subscribe(toTopic: "merchant_notifications") { error in
            if let error = error {
                print("❌ 訂閱商家通知失敗: \(error)")
            } else {
                print("✅ 已訂閱商家通知主題")
            }
        }
    }
}

// MARK: - 商家端通知設定（簡化版本）
class MerchantNotificationManager: ObservableObject {
    @Published var isEnabled = false
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isEnabled = granted
                if granted {
                    print("✅ 通知權限已獲得")
                } else {
                    print("❌ 通知權限被拒絕")
                }
            }
        }
    }
} 