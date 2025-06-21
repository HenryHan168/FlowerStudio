//
//  StudioInfo.swift
//  FlowerStudio
//
//  Created by night on 2025/6/8.
//

import Foundation
import SwiftData

/// 工作室資訊數據模型
@Model
final class StudioInfo {
    /// 工作室名稱
    var name: String
    /// 工作室描述
    var studioDescription: String
    /// 聯絡電話
    var phone: String
    /// 電子郵件
    var email: String?
    /// 地址
    var address: String
    /// 營業時間
    var businessHours: [BusinessHour]
    /// 工作室logo圖片名稱
    var logoImageName: String
    /// 社群媒體連結
    var socialMediaLinks: [SocialMediaLink]
    /// 是否提供配送服務
    var deliveryAvailable: Bool
    /// 配送範圍描述
    var deliveryRange: String?
    /// 最小訂購金額
    var minimumOrderAmount: Double
    /// 創建時間
    var createdAt: Date
    /// 更新時間
    var updatedAt: Date
    
    init(
        name: String = "花漾花藝工作室",
        studioDescription: String = "專業花藝設計，為您的每個重要時刻增添美麗色彩",
        phone: String = "0920663393",
        email: String? = nil,
        address: String = "宜蘭縣羅東鎮中山路四段20巷12號",
        logoImageName: String = "studio_logo",
        deliveryAvailable: Bool = true,
        deliveryRange: String? = "宜蘭縣羅東鎮及周邊地區",
        minimumOrderAmount: Double = 500.0
    ) {
        self.name = name
        self.studioDescription = studioDescription
        self.phone = phone
        self.email = email
        self.address = address
        self.businessHours = BusinessHour.defaultHours()
        self.logoImageName = logoImageName
        self.socialMediaLinks = []
        self.deliveryAvailable = deliveryAvailable
        self.deliveryRange = deliveryRange
        self.minimumOrderAmount = minimumOrderAmount
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// 更新工作室資訊
    func updateInfo() {
        self.updatedAt = Date()
    }
    
    /// 獲取格式化的聯絡電話
    var formattedPhone: String {
        // 將電話號碼格式化為 (09) 2066-3393
        let cleanPhone = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if cleanPhone.count == 10 {
            let area = String(cleanPhone.prefix(2))
            let middle = String(cleanPhone.dropFirst(2).prefix(4))
            let last = String(cleanPhone.suffix(4))
            return "(\(area)) \(middle)-\(last)"
        }
        return phone
    }
    
    /// 獲取當前營業狀態
    var currentBusinessStatus: BusinessStatus {
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now) // 1 = Sunday, 2 = Monday, ...
        let currentTime = calendar.dateComponents([.hour, .minute], from: now)
        
        // 找到今天的營業時間
        if let todayHours = businessHours.first(where: { $0.dayOfWeek == weekday }) {
            if todayHours.isClosed {
                return .closed
            }
            
            let currentMinutes = (currentTime.hour ?? 0) * 60 + (currentTime.minute ?? 0)
            let openMinutes = todayHours.openHour * 60 + todayHours.openMinute
            let closeMinutes = todayHours.closeHour * 60 + todayHours.closeMinute
            
            if currentMinutes >= openMinutes && currentMinutes < closeMinutes {
                return .open
            } else {
                return .closed
            }
        }
        
        return .closed
    }
}

/// 營業時間數據模型
@Model
final class BusinessHour {
    /// 星期幾 (1 = 週日, 2 = 週一, ..., 7 = 週六)
    var dayOfWeek: Int
    /// 開始營業小時
    var openHour: Int
    /// 開始營業分鐘
    var openMinute: Int
    /// 結束營業小時
    var closeHour: Int
    /// 結束營業分鐘
    var closeMinute: Int
    /// 是否休息日
    var isClosed: Bool
    
    init(dayOfWeek: Int, openHour: Int = 9, openMinute: Int = 0, closeHour: Int = 18, closeMinute: Int = 0, isClosed: Bool = false) {
        self.dayOfWeek = dayOfWeek
        self.openHour = openHour
        self.openMinute = openMinute
        self.closeHour = closeHour
        self.closeMinute = closeMinute
        self.isClosed = isClosed
    }
    
    /// 獲取星期名稱
    var dayName: String {
        let days = ["", "週日", "週一", "週二", "週三", "週四", "週五", "週六"]
        return days[dayOfWeek]
    }
    
    /// 獲取營業時間字符串
    var timeString: String {
        if isClosed {
            return "休息"
        }
        return String(format: "%02d:%02d - %02d:%02d", openHour, openMinute, closeHour, closeMinute)
    }
    
    /// 預設營業時間
    static func defaultHours() -> [BusinessHour] {
        return [
            BusinessHour(dayOfWeek: 1, isClosed: true), // 週日休息
            BusinessHour(dayOfWeek: 2, openHour: 9, closeHour: 18), // 週一 9:00-18:00
            BusinessHour(dayOfWeek: 3, openHour: 9, closeHour: 18), // 週二 9:00-18:00
            BusinessHour(dayOfWeek: 4, openHour: 9, closeHour: 18), // 週三 9:00-18:00
            BusinessHour(dayOfWeek: 5, openHour: 9, closeHour: 18), // 週四 9:00-18:00
            BusinessHour(dayOfWeek: 6, openHour: 9, closeHour: 18), // 週五 9:00-18:00
            BusinessHour(dayOfWeek: 7, openHour: 9, closeHour: 17)  // 週六 9:00-17:00
        ]
    }
}

/// 社群媒體連結數據模型
@Model
final class SocialMediaLink {
    /// 平台名稱
    var platform: SocialPlatform
    /// 連結URL
    var url: String
    /// 顯示名稱
    var displayName: String
    
    init(platform: SocialPlatform, url: String, displayName: String) {
        self.platform = platform
        self.url = url
        self.displayName = displayName
    }
}

/// 社群媒體平台枚舉
enum SocialPlatform: String, CaseIterable, Codable {
    case facebook = "Facebook"
    case instagram = "Instagram"
    case line = "LINE"
    
    var iconName: String {
        switch self {
        case .facebook:
            return "f.square.fill"
        case .instagram:
            return "camera.fill"
        case .line:
            return "message.fill"
        }
    }
}

/// 營業狀態枚舉
enum BusinessStatus {
    case open
    case closed
    
    var displayText: String {
        switch self {
        case .open:
            return "營業中"
        case .closed:
            return "休息中"
        }
    }
    
    var color: String {
        switch self {
        case .open:
            return "green"
        case .closed:
            return "red"
        }
    }
} 