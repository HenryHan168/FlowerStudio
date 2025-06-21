//
//  CartView.swift
//  FlowerStudio
//
//  Created by night on 2025/6/8.
//

import SwiftUI
import SwiftData

struct CartView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CartItem.addedAt, order: .reverse) private var cartItems: [CartItem]
    @State private var showingCheckout = false
    
    // 計算總價
    private var totalAmount: Double {
        cartItems.reduce(0) { $0 + $1.subtotal }
    }
    
    // 計算總數量
    private var totalQuantity: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if cartItems.isEmpty {
                    emptyCartView
                } else {
                    cartContentView
                }
            }
            .navigationTitle("購物車")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !cartItems.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("清空") {
                            clearCart()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingCheckout) {
                CheckoutView(cartItems: cartItems, totalAmount: totalAmount)
            }
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "cart.badge.questionmark")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("購物車是空的")
                .font(.title2)
                .fontWeight(.semibold)
            
            NavigationLink(destination: ProductListView()) {
                Text("開始購物")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.pink)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
    }
    
    // 購物車內容視圖
    private var cartContentView: some View {
        VStack(spacing: 0) {
            // 購物車商品列表
            List {
                ForEach(cartItems, id: \.id) { item in
                    CartItemRowDirect(
                        cartItem: item,
                        modelContext: modelContext
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 4)
                }
            }
            .listStyle(PlainListStyle())
            
            // 底部總計和結帳按鈕
            cartSummaryView
        }
    }
    
    // 購物車總計視圖
    private var cartSummaryView: some View {
        VStack(spacing: 16) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("總計 (\(totalQuantity)件商品)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("NT$ \(Int(totalAmount))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                }
                
                Spacer()
                
                Button("前往結帳") {
                    showingCheckout = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(width: 120)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(.regularMaterial)
    }
    
    // 基於ID更新商品數量（安全方法）
    private func updateQuantityById(itemId: UUID, quantity: Int) {
        withAnimation {
            // 重新從數據庫中查找對象，確保是最新的
            if let item = cartItems.first(where: { $0.id == itemId }) {
                if quantity <= 0 {
                    // 數量為0或負數時，刪除商品
                    modelContext.delete(item)
                } else {
                    // 直接更新數量
                    item.quantity = quantity
                    item.updatedAt = Date()
                }
                try? modelContext.save()
            }
        }
    }
    
    // 基於ID移除商品（安全方法）
    private func removeItemById(itemId: UUID) {
        withAnimation {
            if let item = cartItems.first(where: { $0.id == itemId }) {
                modelContext.delete(item)
                try? modelContext.save()
            }
        }
    }
    
    // 更新商品數量（保留舊方法以備後用）
    private func updateQuantity(for item: CartItem, quantity: Int) {
        withAnimation {
            if quantity <= 0 {
                // 數量為0或負數時，刪除商品
                modelContext.delete(item)
            } else {
                // 直接更新數量，避免調用可能有問題的方法
                item.quantity = quantity
                item.updatedAt = Date()
            }
            try? modelContext.save()
        }
    }
    
    // 移除商品（保留舊方法以備後用）
    private func removeItem(_ item: CartItem) {
        withAnimation {
            modelContext.delete(item)
            try? modelContext.save()
        }
    }
    
    // 清空購物車
    private func clearCart() {
        withAnimation {
            for item in cartItems {
                modelContext.delete(item)
            }
            try? modelContext.save()
        }
    }
}

// MARK: - 購物車商品行（直接版本）
struct CartItemRowDirect: View {
    let cartItem: CartItem
    let modelContext: ModelContext
    
    var body: some View {
        VStack(spacing: 16) {
            // 上半部：商品資訊 + 圖片
            HStack(spacing: 16) {
                // 商品圖片
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(cartItem.productCategory.color).opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: cartItem.productCategory.iconName)
                            .font(.title)
                            .foregroundColor(Color(cartItem.productCategory.color))
                    )
                
                // 商品基本資訊
                VStack(alignment: .leading, spacing: 8) {
                    Text(cartItem.productName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    Text("NT$ \(Int(cartItem.productPrice))")
                        .font(.headline)
                        .foregroundColor(.pink)
                    
                    if let requirements = cartItem.customRequirements, !requirements.isEmpty {
                        Text("客製化: \(requirements)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
            
            // 數量控制區域 - 緊湊設計
            VStack(alignment: .leading, spacing: 12) {
                Text("數量")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    // 減少按鈕
                    Button(action: {
                        print("🟠 點擊減少按鈕: \(cartItem.productName)")
                        if cartItem.quantity > 1 {
                            cartItem.quantity -= 1
                            cartItem.updatedAt = Date()
                            try? modelContext.save()
                            print("🟠 減少成功: 數量 = \(cartItem.quantity)")
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(cartItem.quantity > 1 ? .white : .gray)
                            .frame(width: 32, height: 32)
                            .background(cartItem.quantity > 1 ? Color.pink : Color(.systemGray4))
                            .clipShape(Circle())
                    }
                    .disabled(cartItem.quantity <= 1)
                    
                    // 數量顯示
                    Text("\(cartItem.quantity)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(minWidth: 40)
                        .multilineTextAlignment(.center)
                    
                    // 增加按鈕
                    Button(action: {
                        print("🟢 點擊增加按鈕: \(cartItem.productName)")
                        cartItem.quantity += 1
                        cartItem.updatedAt = Date()
                        try? modelContext.save()
                        print("🟢 增加成功: 數量 = \(cartItem.quantity)")
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.pink)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // 小計金額 - 右對齊
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("小計")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("NT$ \(Int(cartItem.subtotal))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(12)
            
            // 移除按鈕 - 完全獨立區域
            Button(action: {
                print("🔴 點擊移除按鈕: \(cartItem.productName)")
                removeItem()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trash.fill")
                        .font(.caption)
                    Text("移除此商品")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.red)
                .cornerRadius(20)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // 增加數量 - 最簡化版本
    private func increaseQuantity() {
        print("🟢 點擊了+按鈕: \(cartItem.productName), ID: \(cartItem.id)")
        
        // 直接操作，不使用動畫
        cartItem.quantity += 1
        cartItem.updatedAt = Date()
        
        print("🟡 數量更新為: \(cartItem.quantity)")
        
        // 嘗試保存
        do {
            try modelContext.save()
            print("🟢 保存成功: \(cartItem.productName), 最終數量: \(cartItem.quantity)")
        } catch {
            print("🔴 保存失敗: \(error)")
        }
        
        // 額外檢查：1秒後再次檢查是否還存在
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("🔍 1秒後檢查 - 商品是否還存在: \(cartItem.productName), 數量: \(cartItem.quantity)")
        }
    }
    
    // 減少數量 - 最簡化版本
    private func decreaseQuantity() {
        print("🟠 點擊了-按鈕: \(cartItem.productName), 當前數量: \(cartItem.quantity)")
        
        if cartItem.quantity > 1 {
            cartItem.quantity -= 1
            cartItem.updatedAt = Date()
            
            do {
                try modelContext.save()
                print("🟠 減少保存成功: \(cartItem.productName), 新數量: \(cartItem.quantity)")
            } catch {
                print("🔴 減少保存失敗: \(error)")
            }
        } else {
            print("⚠️ 數量為1，不能再減少")
        }
    }
    
    // 移除商品 - 最簡化版本
    private func removeItem() {
        print("🔴 點擊了移除按鈕: \(cartItem.productName)")
        
        modelContext.delete(cartItem)
        
        do {
            try modelContext.save()
            print("🔴 移除成功: \(cartItem.productName)")
        } catch {
            print("🔴 移除失敗: \(error)")
        }
    }
}

// MARK: - 購物車商品行（回調版本，保留以備後用）
struct CartItemRow: View {
    let cartItem: CartItem
    let onQuantityChange: (Int) -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // 商品圖片
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(cartItem.productCategory.color).opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: cartItem.productCategory.iconName)
                        .font(.title)
                        .foregroundColor(Color(cartItem.productCategory.color))
                )
            
            // 商品資訊
            VStack(alignment: .leading, spacing: 8) {
                Text(cartItem.productName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text("NT$ \(Int(cartItem.productPrice))")
                    .font(.headline)
                    .foregroundColor(.pink)
                
                if let requirements = cartItem.customRequirements, !requirements.isEmpty {
                    Text("客製化: \(requirements)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // 數量控制
                HStack(spacing: 12) {
                    // 減少數量按鈕
                    Button(action: { 
                        if cartItem.quantity > 1 {
                            onQuantityChange(cartItem.quantity - 1)
                        }
                    }) {
                        Image(systemName: "minus.circle")
                            .font(.title3)
                            .foregroundColor(cartItem.quantity > 1 ? .pink : .gray)
                    }
                    .disabled(cartItem.quantity <= 1)
                    
                    Text("\(cartItem.quantity)")
                        .font(.headline)
                        .frame(minWidth: 30)
                    
                    // 增加數量按鈕
                    Button(action: { 
                        onQuantityChange(cartItem.quantity + 1) 
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.title3)
                            .foregroundColor(.pink)
                    }
                    
                    Spacer()
                    
                    Button("移除", action: onRemove)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            // 小計
            Text("NT$ \(Int(cartItem.subtotal))")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - 結帳視圖
struct CheckoutView: View {
    let cartItems: [CartItem]
    let totalAmount: Double
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var customerName = ""
    @State private var customerPhone = ""
    @State private var customerEmail = ""
    @State private var recipientName = ""
    @State private var recipientPhone = ""
    @State private var deliveryAddress = ""
    @State private var selectedDeliveryMethod: DeliveryMethod = .pickup
    @State private var preferredDate = Date().addingTimeInterval(86400)
    @State private var preferredTime = "09:00-12:00"
    @State private var notes = ""
    @State private var showingSuccessAlert = false
    @State private var orderNumbers: [String] = []
    
    private let timeSlots = ["09:00-12:00", "12:00-15:00", "15:00-18:00", "18:00-21:00"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 訂單摘要
                    orderSummarySection
                    
                    // 客戶資訊
                    customerInfoSection
                    
                    // 收件人資訊
                    recipientInfoSection
                    
                    // 配送資訊
                    deliveryInfoSection
                    
                    // 備註
                    notesSection
                }
                .padding()
            }
            .navigationTitle("結帳")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("返回購物車") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("確認訂購") {
                        createOrders()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("訂購成功", isPresented: $showingSuccessAlert) {
                Button("查看訂單") {
                    // 發送通知切換到訂單頁面
                    NotificationCenter.default.post(name: .switchToOrders, object: nil)
                    dismiss()
                }
                Button("繼續購物") {
                    dismiss()
                }
            } message: {
                Text("您的訂單已成功建立\n訂單編號：\(orderNumbers.joined(separator: ", "))")
            }
        }
    }
    
    // 訂單摘要
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("訂單摘要")
                .font(.headline)
            
            ForEach(cartItems) { item in
                HStack {
                    Text(item.productName)
                        .font(.subheadline)
                    Spacer()
                    Text("x\(item.quantity)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("NT$ \(Int(item.subtotal))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            Divider()
            
            HStack {
                Text("總計")
                    .font(.headline)
                Spacer()
                Text("NT$ \(Int(totalAmount))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // 客戶資訊
    private var customerInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("客戶資訊")
                .font(.headline)
            
            VStack(spacing: 12) {
                TextField("姓名 *", text: $customerName)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                
                TextField("聯絡電話 *", text: $customerPhone)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .keyboardType(.phonePad)
                
                TextField("電子郵件（選填）", text: $customerEmail)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .keyboardType(.emailAddress)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // 收件人資訊
    private var recipientInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("收件人資訊")
                .font(.headline)
            
            VStack(spacing: 12) {
                TextField("收件人姓名 *", text: $recipientName)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                
                TextField("收件人電話 *", text: $recipientPhone)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .keyboardType(.phonePad)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // 配送資訊
    private var deliveryInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("配送資訊")
                .font(.headline)
            
            VStack(spacing: 12) {
                // 配送方式下拉選項
                VStack(alignment: .leading, spacing: 8) {
                    Text("配送方式")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("配送方式", selection: $selectedDeliveryMethod) {
                        ForEach(DeliveryMethod.allCases, id: \.self) { method in
                            HStack {
                                Image(systemName: method.iconName)
                                    .foregroundColor(.pink)
                                Text(method.rawValue)
                            }
                            .tag(method)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.pink)
                }
                
                // 只有選擇外送時才顯示配送地址
                if selectedDeliveryMethod == .delivery {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("配送地址")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("請輸入完整配送地址 *", text: $deliveryAddress, axis: .vertical)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .lineLimit(3...5)
                    }
                }
                
                // 日期選擇
                VStack(alignment: .leading, spacing: 8) {
                    Text(selectedDeliveryMethod == .pickup ? "希望取貨日期" : "希望配送日期")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    DatePicker("", selection: $preferredDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .accentColor(.pink)
                }
                
                // 時間段選擇
                VStack(alignment: .leading, spacing: 8) {
                    Text("時間段")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("時間段", selection: $preferredTime) {
                        ForEach(timeSlots, id: \.self) { time in
                            Text(time).tag(time)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.pink)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // 備註
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("備註")
                .font(.headline)
            
            TextField("其他備註（選填）", text: $notes, axis: .vertical)
                .padding(12)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .lineLimit(3)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // 表單驗證
    private var isFormValid: Bool {
        !customerName.isEmpty &&
        !customerPhone.isEmpty &&
        !recipientName.isEmpty &&
        !recipientPhone.isEmpty &&
        (selectedDeliveryMethod == .pickup || !deliveryAddress.isEmpty)
    }
    
    // 創建訂單
    private func createOrders() {
        orderNumbers.removeAll()
        var newOrders: [Order] = []
        
        for cartItem in cartItems {
            let newOrder = Order(
                customerName: customerName,
                customerPhone: customerPhone,
                customerEmail: customerEmail.isEmpty ? nil : customerEmail,
                productId: cartItem.productId,
                productName: cartItem.productName,
                quantity: cartItem.quantity,
                unitPrice: cartItem.productPrice,
                customRequirements: cartItem.customRequirements,
                recipientName: recipientName,
                recipientPhone: recipientPhone,
                deliveryAddress: selectedDeliveryMethod == .delivery ? deliveryAddress : nil,
                deliveryMethod: selectedDeliveryMethod,
                preferredDate: preferredDate,
                preferredTime: preferredTime,
                notes: notes.isEmpty ? nil : notes
            )
            
            modelContext.insert(newOrder)
            orderNumbers.append(newOrder.orderNumber)
            newOrders.append(newOrder)
        }
        
        // 清空購物車
        for cartItem in cartItems {
            modelContext.delete(cartItem)
        }
        
        do {
            try modelContext.save()
            
            // 上傳訂單到 Firebase（非阻塞）
            Task {
                await uploadOrdersToFirebase(newOrders)
            }
            
            showingSuccessAlert = true
        } catch {
            print("Failed to save orders: \(error)")
        }
    }
    
    // 上傳訂單到Firebase
    private func uploadOrdersToFirebase(_ orders: [Order]) async {
        for order in orders {
            do {
                // 將Order轉換為Firebase格式
                let firebaseOrderData: [String: Any] = [
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
                    "deliveryMethod": order.deliveryMethod.rawValue,
                    "deliveryAddress": order.deliveryAddress ?? "",
                    "preferredDate": order.preferredDate,
                    "preferredTime": order.preferredTime,
                    "notes": order.notes ?? "",
                    "orderStatus": order.status.rawValue,
                    "createdAt": order.createdAt,
                    "updatedAt": order.updatedAt
                ]
                
                // 上傳到Firebase
                try await FirebaseManager.shared.uploadOrderData(
                    orderId: order.id.uuidString,
                    orderData: firebaseOrderData,
                    orderNumber: order.orderNumber,
                    customerName: order.customerName,
                    totalAmount: order.totalAmount
                )
                
                print("✅ 訂單 \(order.orderNumber) 已成功上傳到 Firebase")
            } catch {
                print("❌ 上傳訂單 \(order.orderNumber) 到 Firebase 失敗: \(error)")
            }
        }
    }
}

#Preview {
    CartView()
        .modelContainer(for: CartItem.self, inMemory: true)
} 