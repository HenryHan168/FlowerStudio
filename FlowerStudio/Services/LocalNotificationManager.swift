import Foundation
import UserNotifications
import SwiftUI

@MainActor
class LocalNotificationManager: NSObject, ObservableObject {
    static let shared = LocalNotificationManager()
    
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    print("✅ 本地推播通知授權成功")
                } else {
                    print("❌ 本地推播通知授權失敗: \(error?.localizedDescription ?? "未知錯誤")")
                }
            }
        }
    }
    
    /// 發送訂單確認通知（給客戶）
    func sendOrderConfirmationNotification(orderNumber: String, customerName: String) {
        guard isAuthorized else {
            print("⚠️ 推播通知未授權")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "🌸 訂單確認"
        content.body = "親愛的 \(customerName)，您的訂單 #\(orderNumber) 已成功建立！我們將盡快為您準備。"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "ORDER_CONFIRMATION"
        
        // 設定立即發送的觸發器
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "customer_order_\(orderNumber)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 客戶推播通知發送失敗: \(error.localizedDescription)")
            } else {
                print("✅ 客戶推播通知已發送: 訂單 #\(orderNumber)")
            }
        }
        
        // 同時發送業主通知
        sendMerchantNewOrderNotification(orderNumber: orderNumber, customerName: customerName)
    }
    
    /// 發送新訂單通知（給業主）
    func sendMerchantNewOrderNotification(orderNumber: String, customerName: String) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "💼 新訂單通知"
        content.body = "您有一筆新訂單！客戶：\(customerName)，訂單編號：#\(orderNumber)。請及時處理。"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "MERCHANT_NEW_ORDER"
        
        // 延遲 2 秒發送，避免與客戶通知衝突
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "merchant_order_\(orderNumber)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 業主推播通知發送失敗: \(error.localizedDescription)")
            } else {
                print("✅ 業主推播通知已發送: 新訂單 #\(orderNumber)")
            }
        }
    }
    
    /// 發送批量訂單通知（給業主）
    func sendMerchantBatchOrderNotification(orderCount: Int, customerName: String, orderNumbers: [String]) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "💼 批量新訂單通知"
        content.body = "您收到 \(orderCount) 筆新訂單！客戶：\(customerName)。訂單編號：\(orderNumbers.joined(separator: ", "))"
        content.sound = .default
        content.badge = NSNumber(value: orderCount)
        content.categoryIdentifier = "MERCHANT_BATCH_ORDER"
        
        // 延遲 2 秒發送
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "merchant_batch_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 業主批量推播通知發送失敗: \(error.localizedDescription)")
            } else {
                print("✅ 業主批量推播通知已發送: \(orderCount) 筆訂單")
            }
        }
    }
    
    /// 發送訂單狀態更新通知
    func sendOrderStatusNotification(orderNumber: String, status: String, customerName: String) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "📦 訂單狀態更新"
        content.body = "親愛的 \(customerName)，您的訂單 #\(orderNumber) 狀態已更新為：\(status)"
        content.sound = .default
        content.categoryIdentifier = "ORDER_STATUS_UPDATE"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "status_\(orderNumber)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 狀態通知發送失敗: \(error.localizedDescription)")
            } else {
                print("✅ 狀態通知已發送: \(status)")
            }
        }
    }
    
    /// 發送業主提醒通知
    func sendMerchantReminderNotification(title: String, message: String, delaySeconds: TimeInterval = 1) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "⏰ \(title)"
        content.body = message
        content.sound = .default
        content.categoryIdentifier = "MERCHANT_REMINDER"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delaySeconds, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "merchant_reminder_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 業主提醒通知發送失敗: \(error.localizedDescription)")
            } else {
                print("✅ 業主提醒通知已發送: \(title)")
            }
        }
    }
    
    /// 測試推播通知
    func sendTestNotification() {
        guard isAuthorized else {
            print("⚠️ 推播通知未授權，無法發送測試通知")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "🧪 測試通知"
        content.body = "這是一個測試推播通知，如果您看到這個訊息，表示推播功能正常運作！"
        content.sound = .default
        content.categoryIdentifier = "TEST_NOTIFICATION"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "test_notification_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 測試通知發送失敗: \(error.localizedDescription)")
            } else {
                print("✅ 測試通知已發送，請等待 2 秒後查看")
            }
        }
    }
    
    /// 測試業主通知
    func sendTestMerchantNotification() {
        guard isAuthorized else {
            print("⚠️ 推播通知未授權，無法發送測試通知")
            return
        }
        
        sendMerchantNewOrderNotification(orderNumber: "TEST001", customerName: "測試客戶")
        
        // 5 秒後發送提醒通知
        sendMerchantReminderNotification(
            title: "工作提醒",
            message: "記得檢查今日的訂單進度，確保按時完成製作！",
            delaySeconds: 5
        )
    }
} 