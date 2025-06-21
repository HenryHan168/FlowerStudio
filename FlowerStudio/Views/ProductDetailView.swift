//
//  ProductDetailView.swift
//  FlowerStudio
//
//  Created by night on 2025/6/8.
//

import SwiftUI
import SwiftData

struct ProductDetailView: View {
    let product: FlowerProduct
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingOrderView = false
    @State private var quantity = 1
    @State private var isFavorite = false
    @State private var showingAddToCartAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 產品圖片區域
                productImageSection
                
                // 產品基本資訊
                productInfoSection
                
                // 產品詳細描述
                productDescriptionSection
                
                // 訂購選項
                orderOptionsSection
                
                // 製作資訊
                productionInfoSection
            }
            .padding()
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .pink : .gray)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            // 底部訂購按鈕
            orderButton
        }
        .sheet(isPresented: $showingOrderView) {
            OrderFormView(product: product, quantity: quantity)
        }
        .alert("已加入購物車", isPresented: $showingAddToCartAlert) {
            Button("查看購物車") {
                dismiss()
                // 使用通知的方式來切換到購物車
                NotificationCenter.default.post(name: .switchToCart, object: nil)
            }
            Button("繼續購物") {
                // 繼續瀏覽
            }
        } message: {
            Text("\(product.name) x\(quantity) 已成功加入購物車")
        }
    }
    
    // 產品圖片區域
    private var productImageSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    colors: [
                        Color(product.category.color).opacity(0.3),
                        Color(product.category.color).opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 250)
            
            VStack(spacing: 16) {
                Image(systemName: product.category.iconName)
                    .font(.system(size: 80))
                    .foregroundColor(Color(product.category.color))
                
                Text(product.category.rawValue)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            // 精選和可客製標籤
            VStack {
                HStack {
                    if product.isFeatured {
                        Label("精選", systemImage: "star.fill")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    if product.isCustomizable {
                        Label("可客製", systemImage: "slider.horizontal.3")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
    
    // 產品基本資訊
    private var productInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(product.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("NT$ \(Int(product.price))")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
            }
            
            HStack(spacing: 16) {
                Label("\(product.preparationDays)天製作", systemImage: "clock")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Label(product.category.rawValue, systemImage: product.category.iconName)
                    .font(.subheadline)
                    .foregroundColor(Color(product.category.color))
            }
        }
    }
    
    // 產品詳細描述
    private var productDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("產品描述")
                .font(.headline)
            
            Text(product.productDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
    }
    
    // 訂購選項
    private var orderOptionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("訂購選項")
                .font(.headline)
            
            // 數量選擇
            HStack {
                Text("數量:")
                    .font(.subheadline)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: decreaseQuantity) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(quantity > 1 ? .pink : .gray)
                    }
                    .disabled(quantity <= 1)
                    
                    Text("\(quantity)")
                        .font(.headline)
                        .frame(minWidth: 30)
                    
                    Button(action: increaseQuantity) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.pink)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // 總價格
            HStack {
                Text("小計:")
                    .font(.headline)
                
                Spacer()
                
                Text("NT$ \(Int(product.price * Double(quantity)))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
            }
        }
    }
    
    // 製作資訊
    private var productionInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("製作資訊")
                .font(.headline)
            
            VStack(spacing: 8) {
                InfoRow(
                    icon: "clock",
                    title: "製作時間",
                    value: "\(product.preparationDays)個工作天",
                    color: .blue
                )
                
                InfoRow(
                    icon: "hand.raised",
                    title: "客製化服務",
                    value: product.isCustomizable ? "支援客製化" : "固定款式",
                    color: product.isCustomizable ? .orange : .gray
                )
                
                InfoRow(
                    icon: "phone",
                    title: "訂購專線",
                    value: "0920-663-393",
                    color: .green
                )
            }
        }
    }
    
    // 底部訂購按鈕
    private var orderButton: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Button("立即致電") {
                    makePhoneCall()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("加入購物車") {
                    addToCart()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding()
        .background(.regularMaterial)
    }
    
    // 數量控制功能
    private func decreaseQuantity() {
        if quantity > 1 {
            quantity -= 1
        }
    }
    
    private func increaseQuantity() {
        quantity += 1
    }
    
    // 收藏功能
    private func toggleFavorite() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isFavorite.toggle()
        }
    }
    
    // 撥打電話功能
    private func makePhoneCall() {
        if let url = URL(string: "tel://0920663393") {
            UIApplication.shared.open(url)
        }
    }
    
    // 加入購物車功能
    private func addToCart() {
        let cartItem = CartItem(
            productId: product.id,
            productName: product.name,
            productPrice: product.price,
            productCategory: product.category,
            productImageName: product.imageName,
            quantity: quantity
        )
        
        modelContext.insert(cartItem)
        
        do {
            try modelContext.save()
            showingAddToCartAlert = true
        } catch {
            print("Failed to add item to cart: \(error)")
        }
    }
}

// MARK: - 資訊行組件
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 按鈕樣式
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [.pink, .pink.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.pink)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.pink.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.pink, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - 訂購表單視圖
struct OrderFormView: View {
    let product: FlowerProduct
    let quantity: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var customerName = ""
    @State private var customerPhone = ""
    @State private var customerEmail = ""
    @State private var recipientName = ""
    @State private var recipientPhone = ""
    @State private var deliveryAddress = ""
    @State private var selectedDeliveryMethod: DeliveryMethod = .pickup
    @State private var preferredDate = Date().addingTimeInterval(86400) // 明天
    @State private var preferredTime = "09:00-12:00"
    @State private var customRequirements = ""
    @State private var notes = ""
    @State private var showingSuccessAlert = false
    @State private var orderNumber = ""
    
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
                    
                    // 特殊需求
                    specialRequirementsSection
                }
                .padding()
            }
            .navigationTitle("訂購確認")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("確認訂購") {
                        createOrder()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("訂購成功", isPresented: $showingSuccessAlert) {
                Button("查看訂單") {
                    dismiss()
                    // 這裡可以加入切換到訂單頁面的邏輯
                }
                Button("繼續購物") {
                    dismiss()
                }
            } message: {
                Text("您的訂單編號：\(orderNumber)\n我們會盡快與您聯絡確認訂單詳情。")
            }
        }
    }
    
    // 訂單摘要
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("訂單摘要")
                .font(.headline)
            
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(product.category.color).opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: product.category.iconName)
                            .font(.title2)
                            .foregroundColor(Color(product.category.color))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("數量: \(quantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("NT$ \(Int(product.price * Double(quantity)))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                }
                
                Spacer()
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
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("聯絡電話 *", text: $customerPhone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                
                TextField("電子郵件（選填）", text: $customerEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
            }
        }
    }
    
    // 收件人資訊
    private var recipientInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("收件人資訊")
                .font(.headline)
            
            VStack(spacing: 12) {
                TextField("收件人姓名 *", text: $recipientName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("收件人電話 *", text: $recipientPhone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
            }
        }
    }
    
    // 配送資訊
    private var deliveryInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("配送資訊")
                .font(.headline)
            
            VStack(spacing: 12) {
                Picker("配送方式", selection: $selectedDeliveryMethod) {
                    ForEach(DeliveryMethod.allCases, id: \.self) { method in
                        HStack {
                            Image(systemName: method.iconName)
                            Text(method.rawValue)
                        }
                        .tag(method)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if selectedDeliveryMethod == .delivery {
                    TextField("配送地址 *", text: $deliveryAddress, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3)
                }
                
                DatePicker("希望配送/取貨日期", selection: $preferredDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                
                Picker("時間段", selection: $preferredTime) {
                    ForEach(timeSlots, id: \.self) { time in
                        Text(time).tag(time)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
    }
    
    // 特殊需求
    private var specialRequirementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("特殊需求")
                .font(.headline)
            
            VStack(spacing: 12) {
                TextField("客製化要求（選填）", text: $customRequirements, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3)
                
                TextField("其他備註（選填）", text: $notes, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3)
            }
        }
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
    private func createOrder() {
        let newOrder = Order(
            customerName: customerName,
            customerPhone: customerPhone,
            customerEmail: customerEmail.isEmpty ? nil : customerEmail,
            productId: product.id,
            productName: product.name,
            quantity: quantity,
            unitPrice: product.price,
            customRequirements: customRequirements.isEmpty ? nil : customRequirements,
            recipientName: recipientName,
            recipientPhone: recipientPhone,
            deliveryAddress: selectedDeliveryMethod == .delivery ? deliveryAddress : nil,
            deliveryMethod: selectedDeliveryMethod,
            preferredDate: preferredDate,
            preferredTime: preferredTime,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(newOrder)
        
        do {
            try modelContext.save()
            orderNumber = newOrder.orderNumber
            
            // 上傳訂單到 Firebase（非阻塞）
            Task {
                await uploadOrderToFirebase(newOrder)
            }
            
            showingSuccessAlert = true
        } catch {
            print("Failed to save order: \(error)")
            // 這裡可以顯示錯誤訊息
        }
    }
    
    // 上傳訂單到Firebase
    private func uploadOrderToFirebase(_ order: Order) async {
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

#Preview {
    NavigationView {
        ProductDetailView(
            product: FlowerProduct(
                name: "經典玫瑰花束",
                productDescription: "12朵紅玫瑰配滿天星，表達深深的愛意，適合情人節、求婚等浪漫時刻。",
                price: 1200,
                category: .wedding,
                imageName: "rose_bouquet",
                isCustomizable: true,
                preparationDays: 1,
                isFeatured: true
            )
        )
    }
    .modelContainer(for: FlowerProduct.self, inMemory: true)
} 