//
//  FlowerProduct.swift
//  FlowerStudio
//
//  Created by night on 2025/6/8.
//

import Foundation
import SwiftData

/// 花藝作品數據模型
@Model
final class FlowerProduct {
    /// 作品唯一識別碼
    var id: UUID
    /// 作品名稱
    var name: String
    /// 作品描述
    var productDescription: String
    /// 價格
    var price: Double
    /// 作品分類
    var category: ProductCategory
    /// 圖片名稱（存儲在Assets中）
    var imageName: String
    /// 是否可客製化
    var isCustomizable: Bool
    /// 製作天數
    var preparationDays: Int
    /// 創建時間
    var createdAt: Date
    /// 是否為精選作品
    var isFeatured: Bool
    
    init(
        name: String,
        productDescription: String,
        price: Double,
        category: ProductCategory,
        imageName: String,
        isCustomizable: Bool = false,
        preparationDays: Int = 1,
        isFeatured: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.productDescription = productDescription
        self.price = price
        self.category = category
        self.imageName = imageName
        self.isCustomizable = isCustomizable
        self.preparationDays = preparationDays
        self.createdAt = Date()
        self.isFeatured = isFeatured
    }
}

/// 花藝作品分類枚舉
enum ProductCategory: String, CaseIterable, Codable {
    case wedding = "婚禮花束"
    case birthday = "生日花束"
    case festival = "節慶花籃"
    case congratulation = "祝賀花籃"
    case funeral = "追思花圈"
    case decoration = "裝飾花藝"
    case potted = "盆栽植物"
    
    /// 分類對應的SF Symbol圖標
    var iconName: String {
        switch self {
        case .wedding:
            return "heart.fill"
        case .birthday:
            return "gift.fill"
        case .festival:
            return "star.fill"
        case .congratulation:
            return "hand.thumbsup.fill"
        case .funeral:
            return "leaf.fill"
        case .decoration:
            return "house.fill"
        case .potted:
            return "plant.pot.fill"
        }
    }
    
    /// 分類對應的顏色
    var color: String {
        switch self {
        case .wedding:
            return "pink"
        case .birthday:
            return "yellow"
        case .festival:
            return "red"
        case .congratulation:
            return "green"
        case .funeral:
            return "gray"
        case .decoration:
            return "purple"
        case .potted:
            return "brown"
        }
    }
} 