//
//  ContentView.swift
//  FlowerStudio
//
//  Created by night on 2025/6/8.
//

import SwiftUI
import SwiftData

extension Notification.Name {
    static let switchToCart = Notification.Name("switchToCart")
    static let switchToOrders = Notification.Name("switchToOrders")
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var studioInfo: [StudioInfo]
    @State private var selectedTab = 0
    @StateObject private var contactManager = ContactManager.shared
    @StateObject private var userManager = UserManager.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            // 首頁
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("首頁")
                }
                .tag(0)
            
            // 花藝作品
            ProductListView()
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("花藝作品")
                }
                .tag(1)
            
            // 購物車（只對顧客顯示）
            if !userManager.hasMerchantAccess {
                CartView()
                    .tabItem {
                        Image(systemName: "cart.fill")
                        Text("購物車")
                    }
                    .tag(2)
            }
            
            // 我的訂單
            OrderListView()
                .tabItem {
                    Image(systemName: "bag.fill")
                    Text(userManager.hasMerchantAccess ? "所有訂單" : "我的訂單")
                }
                .tag(3)
            
            // 業主儀表板（只對業主顯示）
            if userManager.hasMerchantAccess {
                MerchantDashboardView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("業主管理")
                    }
                    .tag(4)
            }
            
            // 聯絡我們 & 更多功能
            MoreView()
                .tabItem {
                    Image(systemName: "ellipsis.circle.fill")
                    Text("更多")
                }
                .tag(5)
        }
        .accentColor(.pink)
        .onReceive(NotificationCenter.default.publisher(for: .switchToCart)) { _ in
            selectedTab = userManager.hasMerchantAccess ? 3 : 2 // 根據角色調整標籤頁索引
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchToOrders)) { _ in
            selectedTab = 3 // 切換到訂單頁面
        }
        .onAppear {
            contactManager.setModelContext(modelContext)
        }
    }
}

// MARK: - 首頁視圖
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var notificationManager: LocalNotificationManager
    @StateObject private var userManager = UserManager.shared
    @Query private var studioInfo: [StudioInfo]
    @Query(filter: #Predicate<FlowerProduct> { $0.isFeatured }) 
    private var featuredProducts: [FlowerProduct]
    
    var currentStudio: StudioInfo? {
        studioInfo.first
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // 頂部橫幅
                    headerSection
                    
                    // 工作室資訊
                    studioInfoSection
                    
                    // 精選作品
                    featuredProductsSection
                    
                    // 快速聯絡
                    quickContactSection
                }
            }
            .navigationTitle("花漾花藝工作室")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // 只在業主模式顯示測試按鈕
                if userManager.hasMerchantAccess {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("💼") {
                            notificationManager.sendTestMerchantNotification()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("🧪") {
                            notificationManager.sendTestNotification()
                        }
                    }
                } else {
                    // 顧客模式顯示身份標識
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Image(systemName: "person.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text("顧客")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
    
    // 頂部橫幅
    private var headerSection: some View {
        ZStack {
            LinearGradient(
                colors: [.pink.opacity(0.3), .purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)
            
            VStack(spacing: 16) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.pink)
                
                Text("花漾花藝工作室")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("專業花藝設計，為您的每個重要時刻增添美麗色彩")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
    
    // 工作室資訊區塊
    private var studioInfoSection: some View {
        VStack(spacing: 16) {
            if let studio = currentStudio {
                HStack(spacing: 20) {
                    VStack {
                        Image(systemName: "clock.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text(studio.currentBusinessStatus.displayText)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color(studio.currentBusinessStatus.color))
                    }
                    
                    Divider()
                        .frame(height: 40)
                    
                    VStack {
                        Image(systemName: "phone.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        Text(studio.formattedPhone)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    Divider()
                        .frame(height: 40)
                    
                    VStack {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                        Text("羅東鎮")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
    
    // 精選作品區塊
    private var featuredProductsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("精選作品")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Spacer()
                
                NavigationLink("查看全部", destination: ProductListView())
                    .font(.subheadline)
                    .foregroundColor(.pink)
                    .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(featuredProducts) { product in
                        FeaturedProductCard(product: product)
                }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
    
    // 快速聯絡區塊
    private var quickContactSection: some View {
        VStack(spacing: 16) {
            Text("需要協助？")
                .font(.title3)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                Button(action: makePhoneCall) {
                    VStack {
                        Image(systemName: "phone.fill")
                            .font(.title2)
                        Text("立即致電")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.green)
                    .cornerRadius(12)
                }
                
                Button(action: openMaps) {
                    VStack {
                        Image(systemName: "map.fill")
                            .font(.title2)
                        Text("店面導航")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                NavigationLink(destination: ProductListView()) {
                    VStack {
                        Image(systemName: "leaf.fill")
                            .font(.title2)
                        Text("瀏覽作品")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.pink)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.vertical)
    }
    
    // 撥打電話功能
    private func makePhoneCall() {
        if let studio = currentStudio,
           let url = URL(string: "tel://\(studio.phone)") {
            UIApplication.shared.open(url)
        }
    }
    
    // 開啟地圖導航
    private func openMaps() {
        if let studio = currentStudio {
            let encodedAddress = studio.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let url = URL(string: "maps://?q=\(encodedAddress)") {
                UIApplication.shared.open(url)
            }
        }
    }
}

// MARK: - 精選作品卡片
struct FeaturedProductCard: View {
    let product: FlowerProduct
    
    var body: some View {
        NavigationLink(destination: ProductDetailView(product: product)) {
            VStack(alignment: .leading, spacing: 8) {
                // 作品圖片區域
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            colors: [Color(product.category.color).opacity(0.3), 
                                    Color(product.category.color).opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 160, height: 120)
                    
                    // 載入網路圖片
                    if let imageURL = product.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 160, height: 120)
                                    .clipped()
                            case .failure(_):
                                // 載入失敗，顯示備用圖標
                                VStack(spacing: 6) {
                                    Image(systemName: "photo")
                                        .font(.title)
                                        .foregroundColor(.gray)
                                    Text("圖片載入失敗")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            case .empty:
                                // 載入中顯示的佔位符
                                VStack(spacing: 6) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color(product.category.color)))
                                    Text("載入中...")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .cornerRadius(12)
                        .onAppear {
                            print("🏠 首頁載入圖片: \(product.name) - \(imageURL)")
                        }
                    } else {
                        // 備用的SF Symbol圖標
                        VStack {
                            Image(systemName: product.category.iconName)
                                .font(.title)
                                .foregroundColor(Color(product.category.color))
                            Text(product.category.rawValue)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // 精選標籤
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                                .padding(4)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 1)
                        }
                        Spacer()
                    }
                    .padding(6)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    Text("NT$ \(Int(product.price))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                }
            }
            .frame(width: 160)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 更多功能視圖
struct MoreView: View {
    @StateObject private var userManager = UserManager.shared
    @State private var showingRoleSwitchAlert = false
    @State private var showingAboutAlert = false
    @State private var showingMerchantAuth = false
    @State private var showingAuthFailedAlert = false
    @State private var pinInput = ""
    @State private var passwordInput = ""
    @State private var authMethod: AuthMethod = .pin
    
    enum AuthMethod {
        case pin, password
    }
    
    var body: some View {
        NavigationView {
            List {
                // 使用者資訊區塊
                Section {
                    HStack {
                        Circle()
                            .fill(userManager.hasMerchantAccess ? Color.purple : Color.blue)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: userManager.hasMerchantAccess ? "crown.fill" : "person.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("當前身份")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(userManager.currentUserRole.displayName)
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            if userManager.hasMerchantAccess {
                                Text("已驗證")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Spacer()
                        
                        Button("切換") {
                            showingRoleSwitchAlert = true
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    }
                    .padding(.vertical, 8)
                }
                
                // 功能選項
                Section("功能") {
                    NavigationLink(destination: ContactView()) {
                        Label("聯絡我們", systemImage: "phone.fill")
                    }
                    
                    if userManager.hasMerchantAccess {
                        NavigationLink(destination: MerchantDashboardView()) {
                            Label("業主儀表板", systemImage: "chart.bar.fill")
                        }
                    }
                    
                    Button(action: {
                        showingAboutAlert = true
                    }) {
                        Label("關於應用", systemImage: "info.circle.fill")
                    }
                    .foregroundColor(.primary)
                }
                
                // 安全設定
                if userManager.hasMerchantAccess {
                    Section("安全設定") {
                        Button(action: {
                            userManager.logout()
                        }) {
                            Label("登出並清除認證", systemImage: "lock.fill")
                        }
                        .foregroundColor(.red)
                    }
                }
                
                // 開發測試功能（開發階段使用）
                Section("開發測試") {
                    Button("🧪 測試顧客通知") {
                        LocalNotificationManager.shared.sendTestNotification()
                    }
                    .foregroundColor(.blue)
                    
                    if userManager.hasMerchantAccess {
                        Button("💼 測試業主通知") {
                            LocalNotificationManager.shared.sendTestMerchantNotification()
                        }
                        .foregroundColor(.purple)
                    }
                }
            }
            .navigationTitle("更多")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("切換使用者身份", isPresented: $showingRoleSwitchAlert) {
            Button("切換為顧客") {
                userManager.switchToCustomer()
            }
            Button("切換為業主") {
                // 如果已經認證過，直接切換；否則需要驗證
                if userManager.isMerchantAuthenticated {
                    userManager.setUserRole(.merchant)
                } else {
                    showingMerchantAuth = true
                }
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("當前身份：\(userManager.currentUserRole.displayName)\n\n請選擇要切換的身份類型。")
        }
        .alert("關於花漾花藝工作室", isPresented: $showingAboutAlert) {
            Button("確定") { }
        } message: {
            Text("花漾花藝工作室 App v1.0\n\n專業花藝設計，為您的每個重要時刻增添美麗色彩。\n\n© 2024 花漾花藝工作室")
        }
        .alert("驗證失敗", isPresented: $showingAuthFailedAlert) {
            Button("重試") {
                showingMerchantAuth = true
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("PIN碼或密碼錯誤，請重試。")
        }
        .sheet(isPresented: $showingMerchantAuth) {
            MerchantAuthView(
                pinInput: $pinInput,
                passwordInput: $passwordInput,
                authMethod: $authMethod,
                onAuthenticate: { success in
                    if success {
                        showingMerchantAuth = false
                        pinInput = ""
                        passwordInput = ""
                    } else {
                        showingMerchantAuth = false
                        showingAuthFailedAlert = true
                        pinInput = ""
                        passwordInput = ""
                    }
                },
                onCancel: {
                    showingMerchantAuth = false
                    pinInput = ""
                    passwordInput = ""
                }
            )
        }
    }
}

// MARK: - 業主驗證視圖
struct MerchantAuthView: View {
    @StateObject private var userManager = UserManager.shared
    @Binding var pinInput: String
    @Binding var passwordInput: String
    @Binding var authMethod: MoreView.AuthMethod
    let onAuthenticate: (Bool) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 標題區塊
                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                    
                    Text("業主身份驗證")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("請輸入業主憑證以訪問管理功能")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // 驗證方式選擇
                Picker("驗證方式", selection: $authMethod) {
                    Text("PIN碼").tag(MoreView.AuthMethod.pin)
                    Text("密碼").tag(MoreView.AuthMethod.password)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // 輸入區塊
                VStack(spacing: 16) {
                    if authMethod == .pin {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("業主PIN碼")
                                .font(.headline)
                            
                            Text("請輸入訂購專線後4位數字")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            SecureField("PIN碼 (4位數字)", text: $pinInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .textContentType(.oneTimeCode)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("業主密碼")
                                .font(.headline)
                            
                            Text("請輸入業主密碼")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            SecureField("密碼", text: $passwordInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.password)
                        }
                    }
                }
                .padding(.horizontal)
                
                // 按鈕區塊
                VStack(spacing: 12) {
                    Button("驗證") {
                        let success: Bool
                        if authMethod == .pin {
                            success = userManager.authenticateMerchantWithPIN(pinInput)
                        } else {
                            success = userManager.authenticateMerchantWithPassword(passwordInput)
                        }
                        onAuthenticate(success)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        (authMethod == .pin ? !pinInput.isEmpty : !passwordInput.isEmpty) 
                        ? Color.purple : Color.gray
                    )
                    .cornerRadius(12)
                    .disabled(authMethod == .pin ? pinInput.isEmpty : passwordInput.isEmpty)
                    
                    Button("取消") {
                        onCancel()
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 提示訊息
                VStack(spacing: 8) {
                    Text("安全提示")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    Text("此驗證確保只有授權人員可以訪問業主管理功能")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [FlowerProduct.self, StudioInfo.self], inMemory: true)
}
