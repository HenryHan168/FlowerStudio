//
//  Order.swift
//  FlowerStudio
//
//  Created by night on 2025/6/8.
//

import Foundation
import SwiftData

/// 訂單數據模型
@Model
final class Order {
    /// 訂單唯一識別碼
    var id: UUID
    /// 訂單編號
    var orderNumber: String
    /// 客戶姓名
    var customerName: String
    /// 客戶電話
    var customerPhone: String
    /// 客戶電子郵件
    var customerEmail: String?
    /// 訂購的花藝作品ID
    var productId: UUID
    /// 作品名稱（冗餘存儲，避免產品刪除影響訂單）
    var productName: String
    /// 訂購數量
    var quantity: Int
    /// 單價
    var unitPrice: Double
    /// 總金額
    var totalAmount: Double
    /// 客製化要求
    var customRequirements: String?
    /// 收件人姓名
    var recipientName: String
    /// 收件人電話
    var recipientPhone: String
    /// 配送地址
    var deliveryAddress: String?
    /// 配送方式
    var deliveryMethod: DeliveryMethod
    /// 希望配送/取貨日期
    var preferredDate: Date
    /// 希望配送/取貨時間
    var preferredTime: String
    /// 訂單狀態
    var status: OrderStatus
    /// 特殊備註
    var notes: String?
    /// 訂單創建時間
    var createdAt: Date
    /// 訂單更新時間
    var updatedAt: Date
    
    init(
        customerName: String,
        customerPhone: String,
        customerEmail: String? = nil,
        productId: UUID,
        productName: String,
        quantity: Int,
        unitPrice: Double,
        customRequirements: String? = nil,
        recipientName: String,
        recipientPhone: String,
        deliveryAddress: String? = nil,
        deliveryMethod: DeliveryMethod,
        preferredDate: Date,
        preferredTime: String,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.orderNumber = Self.generateOrderNumber()
        self.customerName = customerName
        self.customerPhone = customerPhone
        self.customerEmail = customerEmail
        self.productId = productId
        self.productName = productName
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.totalAmount = Double(quantity) * unitPrice
        self.customRequirements = customRequirements
        self.recipientName = recipientName
        self.recipientPhone = recipientPhone
        self.deliveryAddress = deliveryAddress
        self.deliveryMethod = deliveryMethod
        self.preferredDate = preferredDate
        self.preferredTime = preferredTime
        self.status = .pending
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// 生成訂單編號
    private static func generateOrderNumber() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: Date())
        let randomNumber = Int.random(in: 1000...9999)
        return "FL\(dateString)\(randomNumber)"
    }
    
    /// 更新訂單狀態
    func updateStatus(_ newStatus: OrderStatus) {
        self.status = newStatus
        self.updatedAt = Date()
    }
}

/// 配送方式枚舉
enum DeliveryMethod: String, CaseIterable, Codable {
    case pickup = "到店取貨"
    case delivery = "外送配送"
    
    var iconName: String {
        switch self {
        case .pickup:
            return "bag.fill"
        case .delivery:
            return "truck.box.fill"
        }
    }
}

/// 訂單狀態枚舉
enum OrderStatus: String, CaseIterable, Codable {
    case pending = "待確認"
    case confirmed = "已確認"
    case preparing = "製作中"
    case ready = "待取貨"
    case delivered = "已送達"
    case completed = "已完成"
    case cancelled = "已取消"
    
    var color: String {
        switch self {
        case .pending:
            return "orange"
        case .confirmed:
            return "blue"
        case .preparing:
            return "purple"
        case .ready:
            return "green"
        case .delivered:
            return "teal"
        case .completed:
            return "gray"
        case .cancelled:
            return "red"
        }
    }
    
    var iconName: String {
        switch self {
        case .pending:
            return "clock.fill"
        case .confirmed:
            return "checkmark.circle.fill"
        case .preparing:
            return "hammer.fill"
        case .ready:
            return "gift.fill"
        case .delivered:
            return "truck.box.fill"
        case .completed:
            return "checkmark.seal.fill"
        case .cancelled:
            return "xmark.circle.fill"
        }
    }
} 