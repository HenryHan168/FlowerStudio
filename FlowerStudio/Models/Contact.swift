//
//  Contact.swift
//  FlowerStudio
//
//  Created by night on 2025/6/21.
//

import Foundation
import SwiftData

/// 常用聯絡人數據模型
@Model
final class Contact {
    /// 聯絡人唯一識別碼
    var id: UUID
    /// 聯絡人姓名
    var name: String
    /// 聯絡人電話
    var phone: String
    /// 聯絡人電子郵件
    var email: String?
    /// 聯絡人地址
    var address: String?
    /// 聯絡人類型
    var type: ContactType
    /// 是否為預設聯絡人
    var isDefault: Bool
    /// 使用次數（用於排序）
    var usageCount: Int
    /// 最後使用時間
    var lastUsedAt: Date?
    /// 創建時間
    var createdAt: Date
    /// 更新時間
    var updatedAt: Date
    
    init(
        name: String,
        phone: String,
        email: String? = nil,
        address: String? = nil,
        type: ContactType,
        isDefault: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.phone = phone
        self.email = email
        self.address = address
        self.type = type
        self.isDefault = isDefault
        self.usageCount = 0
        self.lastUsedAt = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// 更新使用記錄
    func updateUsage() {
        self.usageCount += 1
        self.lastUsedAt = Date()
        self.updatedAt = Date()
    }
    
    /// 更新聯絡人資訊
    func update(
        name: String? = nil,
        phone: String? = nil,
        email: String? = nil,
        address: String? = nil,
        type: ContactType? = nil,
        isDefault: Bool? = nil
    ) {
        if let name = name { self.name = name }
        if let phone = phone { self.phone = phone }
        if let email = email { self.email = email }
        if let address = address { self.address = address }
        if let type = type { self.type = type }
        if let isDefault = isDefault { self.isDefault = isDefault }
        self.updatedAt = Date()
    }
}

/// 聯絡人類型枚舉
enum ContactType: String, CaseIterable, Codable {
    case customer = "訂購人"
    case recipient = "收件人"
    case both = "訂購人/收件人"
    
    var iconName: String {
        switch self {
        case .customer:
            return "person.fill"
        case .recipient:
            return "gift.fill"
        case .both:
            return "person.2.fill"
        }
    }
    
    var color: String {
        switch self {
        case .customer:
            return "blue"
        case .recipient:
            return "green"
        case .both:
            return "purple"
        }
    }
} 