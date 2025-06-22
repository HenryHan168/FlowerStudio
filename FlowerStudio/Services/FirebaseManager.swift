//
//  FirebaseManager.swift
//  FlowerStudio
//
//  Created by night on 2025/6/8.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging
import SwiftUI
import SwiftData

@MainActor
class FirebaseManager: NSObject, ObservableObject {
    static let shared = FirebaseManager()
    
    private var db: Firestore?
    @Published var isConnected = false
    @Published var isFirebaseEnabled = false
    
    override init() {
        super.init()
        setupFirebase()
    }
    
    // MARK: - Firebase 初始化
    private func setupFirebase() {
        // 檢查是否有有效的 GoogleService-Info.plist
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let googleAppId = plist["GOOGLE_APP_ID"] as? String,
              !googleAppId.contains("YOUR_") else {
            print("⚠️ Firebase 未配置 - GoogleService-Info.plist 包含佔位符值或檔案不存在")
            self.isFirebaseEnabled = false
            return
        }
        
        // 配置 Firebase
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        // 初始化 Firestore
        self.db = Firestore.firestore()
        self.isFirebaseEnabled = true
        
        // 設定 Firebase Messaging
        setupMessaging()
        
        // 測試連接
        testConnection()
        
        print("✅ Firebase 已成功配置並啟用")
    }
    
    // MARK: - Firebase Messaging 設定
    private func setupMessaging() {
        guard isFirebaseEnabled else {
            print("⚠️ Firebase 未啟用，跳過 Messaging 設定")
            return
        }
        
        Messaging.messaging().delegate = self
        
        // 請求推送通知權限
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                if let error = error {
                    print("推送通知授權失敗: \(error)")
                } else {
                    print("推送通知授權結果: \(granted)")
                }
            }
        )
        
        // 註冊推送通知
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // MARK: - 測試連接
    private func testConnection() {
        guard let db = db, isFirebaseEnabled else {
            print("⚠️ Firebase 未啟用，跳過連接測試")
            self.isConnected = false
            return
        }
        
        db.collection("test").document("connection").setData([
            "timestamp": Timestamp(date: Date()),
            "status": "connected"
        ]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Firebase 連接測試失敗: \(error)")
                    self.isConnected = false
                } else {
                    print("Firebase 連接成功")
                    self.isConnected = true
                }
            }
        }
    }
    
    // MARK: - 訂單操作
    
    /// 上傳訂單到 Firebase
    func uploadOrder(_ order: Order) async throws {
        guard let db = db, isFirebaseEnabled else {
            print("⚠️ Firebase 未啟用，跳過訂單上傳: \(order.orderNumber)")
            return
        }
        
        let orderData: [String: Any] = [
            "id": order.id.uuidString,
            "orderNumber": order.orderNumber,
            "customerName": order.customerName,
            "customerPhone": order.customerPhone,
            "customerEmail": order.customerEmail ?? "",
            "productName": order.productName,
            "quantity": order.quantity,
            "unitPrice": order.unitPrice,
            "totalAmount": order.totalAmount,
            "customRequirements": order.customRequirements ?? "",
            "recipientName": order.recipientName,
            "recipientPhone": order.recipientPhone,
            "deliveryAddress": order.deliveryAddress ?? "",
            "deliveryMethod": order.deliveryMethod.rawValue,
            "preferredDate": Timestamp(date: order.preferredDate),
            "preferredTime": order.preferredTime,
            "status": order.status.rawValue,
            "notes": order.notes ?? "",
            "createdAt": Timestamp(date: order.createdAt),
            "updatedAt": Timestamp(date: order.updatedAt)
        ]
        
        try await db.collection("orders").document(order.id.uuidString).setData(orderData)
        print("訂單上傳成功: \(order.orderNumber)")
    }
    
    /// 批量上傳訂單
    func uploadOrders(_ orders: [Order]) async {
        for order in orders {
            do {
                try await uploadOrder(order)
            } catch {
                print("上傳訂單失敗 \(order.orderNumber): \(error)")
            }
        }
    }
    
    /// 更新訂單狀態
    func updateOrderStatus(orderId: String, status: OrderStatus) async throws {
        guard let db = db, isFirebaseEnabled else {
            print("⚠️ Firebase 未啟用，跳過訂單狀態更新: \(orderId)")
            return
        }
        
        try await db.collection("orders").document(orderId).updateData([
            "status": status.rawValue,
            "updatedAt": Timestamp(date: Date())
        ])
        print("訂單狀態更新成功: \(orderId) -> \(status.rawValue)")
    }
    
    /// 獲取所有訂單
    func fetchOrders() async throws -> [Order] {
        guard let db = db, isFirebaseEnabled else {
            print("⚠️ Firebase 未啟用，返回空訂單列表")
            return []
        }
        
        let snapshot = try await db.collection("orders")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            let data = document.data()
            return try? self.parseOrderFromFirestore(data)
        }
    }
    
    // MARK: - 產品操作
    
    /// 上傳產品數據
    func uploadProducts(_ products: [FlowerProduct]) async {
        guard let db = db, isFirebaseEnabled else {
            print("⚠️ Firebase 未啟用，跳過產品上傳")
            return
        }
        
        for product in products {
            do {
                let productData: [String: Any] = [
                    "id": product.id.uuidString,
                    "name": product.name,
                    "description": product.productDescription,
                    "price": product.price,
                    "category": product.category.rawValue,
                    "imageName": product.imageName,
                    "imageURL": product.imageURL,
                    "isFeatured": product.isFeatured,
                    "isCustomizable": product.isCustomizable,
                    "createdAt": Timestamp(date: product.createdAt),
                    "preparationDays": product.preparationDays
                ]
                
                try await db.collection("products").document(product.id.uuidString).setData(productData)
                print("產品上傳成功: \(product.name)")
            } catch {
                print("上傳產品失敗 \(product.name): \(error)")
            }
        }
    }
    
    // MARK: - 工作室資訊操作
    
    /// 上傳工作室資訊
    func uploadStudioInfo(_ studioInfo: StudioInfo) async throws {
        guard let db = db, isFirebaseEnabled else {
            print("⚠️ Firebase 未啟用，跳過工作室資訊上傳")
            return
        }
        
        let studioData: [String: Any] = [
            "name": studioInfo.name,
            "description": studioInfo.studioDescription,
            "phone": studioInfo.phone,
            "email": studioInfo.email ?? "",
            "address": studioInfo.address,
            "businessHours": studioInfo.businessHours.map { hour in
                [
                    "dayOfWeek": hour.dayOfWeek,
                    "openHour": hour.openHour,
                    "openMinute": hour.openMinute,
                    "closeHour": hour.closeHour,
                    "closeMinute": hour.closeMinute,
                    "isClosed": hour.isClosed
                ]
            },
            "socialMediaLinks": studioInfo.socialMediaLinks.map { link in
                [
                    "platform": link.platform.rawValue,
                    "url": link.url,
                    "displayName": link.displayName
                ]
            },
            "logoImageName": studioInfo.logoImageName,
            "deliveryAvailable": studioInfo.deliveryAvailable,
            "deliveryRange": studioInfo.deliveryRange ?? "",
            "minimumOrderAmount": studioInfo.minimumOrderAmount,
            "updatedAt": Timestamp(date: studioInfo.updatedAt)
        ]
        
        try await db.collection("studio_info").document("main").setData(studioData)
        print("工作室資訊上傳成功")
    }
    
    // MARK: - 推送通知
    
    /// 發送訂單狀態變更通知
    func sendOrderStatusNotification(orderNumber: String, status: OrderStatus) async {
        // 這裡可以實現推送通知邏輯
        print("發送訂單狀態通知: \(orderNumber) - \(status.rawValue)")
    }
    
    // MARK: - 工具方法
    
    private func parseOrderFromFirestore(_ data: [String: Any]) throws -> Order {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let orderNumber = data["orderNumber"] as? String,
              let customerName = data["customerName"] as? String,
              let customerPhone = data["customerPhone"] as? String,
              let productName = data["productName"] as? String,
              let quantity = data["quantity"] as? Int,
              let unitPrice = data["unitPrice"] as? Double,
              let totalAmount = data["totalAmount"] as? Double,
              let recipientName = data["recipientName"] as? String,
              let recipientPhone = data["recipientPhone"] as? String,
              let deliveryMethodRaw = data["deliveryMethod"] as? String,
              let deliveryMethod = DeliveryMethod(rawValue: deliveryMethodRaw),
              let preferredTimeRaw = data["preferredTime"] as? String,
              let statusRaw = data["status"] as? String,
              let status = OrderStatus(rawValue: statusRaw),
              let createdAtTimestamp = data["createdAt"] as? Timestamp,
              let updatedAtTimestamp = data["updatedAt"] as? Timestamp,
              let preferredDateTimestamp = data["preferredDate"] as? Timestamp else {
            throw NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "無法解析 Firestore 訂單數據"])
        }
        
        let order = Order(
            customerName: customerName,
            customerPhone: customerPhone,
            customerEmail: data["customerEmail"] as? String,
            productId: UUID(), // 這裡可能需要調整
            productName: productName,
            quantity: quantity,
            unitPrice: unitPrice,
            customRequirements: data["customRequirements"] as? String,
            recipientName: recipientName,
            recipientPhone: recipientPhone,
            deliveryAddress: data["deliveryAddress"] as? String,
            deliveryMethod: deliveryMethod,
            preferredDate: preferredDateTimestamp.dateValue(),
            preferredTime: preferredTimeRaw,
            notes: data["notes"] as? String
        )
        
        // 設置從 Firestore 獲取的屬性
        order.id = id
        order.orderNumber = orderNumber
        order.totalAmount = totalAmount
        order.status = status
        order.createdAt = createdAtTimestamp.dateValue()
        order.updatedAt = updatedAtTimestamp.dateValue()
        
        return order
    }
    
    /// 初始化示例數據
    func initializeSampleData(context: ModelContext) {
        // 檢查是否已經有數據
        let descriptor = FetchDescriptor<FlowerProduct>()
        let existingProducts = (try? context.fetch(descriptor)) ?? []
        
        // 總是清理並重新載入數據以確保顯示最新的圖片
        print("🧹 清理所有舊數據...")
        existingProducts.forEach { product in
            context.delete(product)
        }
        
        print("🔄 載入帶真實圖片的新示例數據...")
            let sampleProducts = [
                // 婚禮花束
                FlowerProduct(
                    name: "經典白玫瑰新娘花束",
                    productDescription: "純白玫瑰與滿天星的經典組合，象徵純潔與永恆的愛情，是婚禮中不可或缺的美麗配件。",
                    price: 2800,
                    category: .wedding,
                    imageName: "wedding_bouquet",
                    imageURL: "https://images.unsplash.com/photo-1520763185298-1b434c919102?w=800",
                    isCustomizable: true,
                    preparationDays: 3,
                    isFeatured: true
                ),
                FlowerProduct(
                    name: "粉紅色系新娘捧花",
                    productDescription: "溫柔的粉色玫瑰配上白色桔梗，營造浪漫溫馨的婚禮氛圍。",
                    price: 3200,
                    category: .wedding,
                    imageName: "pink_wedding_bouquet",
                    imageURL: "https://images.unsplash.com/photo-1606800052052-a242baa96f9d?w=800",
                    isCustomizable: true,
                    preparationDays: 3,
                    isFeatured: true
                ),
                
                // 生日花束
                FlowerProduct(
                    name: "繽紛生日花束",
                    productDescription: "色彩豐富的混合花束，包含向日葵、康乃馨和玫瑰，為生日帶來滿滿的祝福與歡樂。",
                    price: 1800,
                    category: .birthday,
                    imageName: "birthday_bouquet",
                    imageURL: "https://images.unsplash.com/photo-1563241527-3004b7be0ffd?w=800",
                    isCustomizable: true,
                    preparationDays: 2,
                    isFeatured: true
                ),
                FlowerProduct(
                    name: "向日葵陽光花束",
                    productDescription: "明亮的向日葵主題花束，搭配黃色玫瑰，象徵陽光般的祝福與希望。",
                    price: 1600,
                    category: .birthday,
                    imageName: "sunflower_bouquet",
                    imageURL: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800",
                    isCustomizable: false,
                    preparationDays: 1
                ),
                
                // 節慶花籃
                FlowerProduct(
                    name: "新春賀歲花籃",
                    productDescription: "紅色與金色的節慶花籃，搭配蘭花和牡丹，寓意富貴吉祥、新年快樂。",
                    price: 3500,
                    category: .festival,
                    imageName: "new_year_basket",
                    imageURL: "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800",
                    isCustomizable: true,
                    preparationDays: 2,
                    isFeatured: true
                ),
                FlowerProduct(
                    name: "聖誕節慶花籃",
                    productDescription: "紅色玫瑰與白色花材的聖誕主題花籃，搭配松枝和聖誕裝飾。",
                    price: 2800,
                    category: .festival,
                    imageName: "christmas_basket",
                    imageURL: "https://images.unsplash.com/photo-1544525582-5de4733b5373?w=800",
                    isCustomizable: true,
                    preparationDays: 2
                ),
                
                // 祝賀花籃
                FlowerProduct(
                    name: "開業祝賀花籃",
                    productDescription: "豪華的祝賀花籃，以蘭花和玫瑰為主，象徵事業興隆、財源廣進。",
                    price: 4200,
                    category: .congratulation,
                    imageName: "congratulation_basket",
                    imageURL: "https://images.unsplash.com/photo-1586159101006-e61ced59d0e9?w=800",
                    isCustomizable: true,
                    preparationDays: 2
                ),
                FlowerProduct(
                    name: "升職慶賀花束",
                    productDescription: "優雅的粉色與白色花束，祝賀升職成功，前程似錦。",
                    price: 2500,
                    category: .congratulation,
                    imageName: "promotion_bouquet",
                    imageURL: "https://images.unsplash.com/photo-1487070183336-b863922373d4?w=800",
                    isCustomizable: false,
                    preparationDays: 1
                ),
                
                // 追思花圈
                FlowerProduct(
                    name: "白色百合花圈",
                    productDescription: "純潔的白色百合花圈，表達對逝者的敬意與懷念。",
                    price: 3800,
                    category: .funeral,
                    imageName: "white_lily_wreath",
                    imageURL: "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800",
                    isCustomizable: true,
                    preparationDays: 1
                ),
                
                // 裝飾花藝
                FlowerProduct(
                    name: "居家裝飾花束",
                    productDescription: "適合居家擺設的混合花束，為您的家增添自然的美麗與芬芳。",
                    price: 1200,
                    category: .decoration,
                    imageName: "home_decoration",
                    imageURL: "https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=800",
                    isCustomizable: false,
                    preparationDays: 1
                ),
                FlowerProduct(
                    name: "辦公室桌花",
                    productDescription: "簡約優雅的桌花設計，為辦公環境帶來清新的氣息。",
                    price: 900,
                    category: .decoration,
                    imageName: "office_flower",
                    imageURL: "https://images.unsplash.com/photo-1571296669893-3d2d3b4f5388?w=800",
                    isCustomizable: false,
                    preparationDays: 1
                ),
                
                // 盆栽植物
                FlowerProduct(
                    name: "多肉植物組合",
                    productDescription: "精心搭配的多肉植物組合，易於照料，適合新手園藝愛好者。",
                    price: 800,
                    category: .potted,
                    imageName: "succulent_combo",
                    imageURL: "https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=800",
                    isCustomizable: false,
                    preparationDays: 1
                ),
                FlowerProduct(
                    name: "觀葉植物盆栽",
                    productDescription: "綠意盎然的觀葉植物，淨化空氣，為室內帶來生機。",
                    price: 1500,
                    category: .potted,
                    imageName: "green_plant",
                    imageURL: "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800",
                    isCustomizable: false,
                    preparationDays: 1
                )
            ]
            
            sampleProducts.forEach { product in
                context.insert(product)
            }
            
            try? context.save()
            print("✅ 示例花藝作品數據初始化完成")
    }
}

// MARK: - MessagingDelegate
extension FirebaseManager: MessagingDelegate {
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase 註冊 Token: \(fcmToken ?? "nil")")
        
        // 可以將 Token 發送到後端服務器
        if let token = fcmToken {
            // 保存 Token 到 UserDefaults 或發送到服務器
            UserDefaults.standard.set(token, forKey: "FCMToken")
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension FirebaseManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([[.banner, .sound]])
    }
    
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
} 