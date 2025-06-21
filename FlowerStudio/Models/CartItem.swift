//
//  CartItem.swift
//  FlowerStudio
//
//  Created by night on 2025/6/8.
//

import Foundation
import SwiftData

/// 購物車商品數據模型
@Model
final class CartItem {
    /// 購物車項目唯一識別碼
    var id: UUID
    /// 關聯的花藝作品ID
    var productId: UUID
    /// 作品名稱（冗餘存儲，提高查詢效率）
    var productName: String
    /// 作品價格（冗餘存儲，避免價格變動影響購物車）
    var productPrice: Double
    /// 作品分類
    var productCategory: ProductCategory
    /// 作品圖片名稱
    var productImageName: String
    /// 購買數量
    var quantity: Int
    /// 客製化要求
    var customRequirements: String?
    /// 加入購物車的時間
    var addedAt: Date
    /// 更新時間
    var updatedAt: Date
    
    init(
        productId: UUID,
        productName: String,
        productPrice: Double,
        productCategory: ProductCategory,
        productImageName: String,
        quantity: Int = 1,
        customRequirements: String? = nil
    ) {
        self.id = UUID()
        self.productId = productId
        self.productName = productName
        self.productPrice = productPrice
        self.productCategory = productCategory
        self.productImageName = productImageName
        self.quantity = quantity
        self.customRequirements = customRequirements
        self.addedAt = Date()
        self.updatedAt = Date()
    }
    
    /// 計算小計
    var subtotal: Double {
        return productPrice * Double(quantity)
    }
    
    /// 更新數量
    func updateQuantity(_ newQuantity: Int) {
        // 只有在數量大於0時才更新，否則應該被刪除
        if newQuantity > 0 {
            self.quantity = newQuantity
            self.updatedAt = Date()
        }
    }
    
    /// 更新客製化要求
    func updateCustomRequirements(_ requirements: String?) {
        self.customRequirements = requirements
        self.updatedAt = Date()
    }
} 