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
    @StateObject private var authManager = AuthManager.shared
    @State private var showingLoginSheet = false

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
            
            // 購物車
            CartView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("購物車")
                }
                .tag(2)
            
            // 我的訂單
            OrderListView()
                .tabItem {
                    Image(systemName: "bag.fill")
                    Text("我的訂單")
                }
                .tag(3)
            
            // 業主管理/More頁面
            if authManager.isMerchant() {
                MerchantDashboardView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("業主管理")
                    }
                    .tag(4)
            } else {
                MoreView(showingLoginSheet: $showingLoginSheet)
                    .tabItem {
                        Image(systemName: "ellipsis")
                        Text("More")
                    }
                    .tag(4)
            }
            
            // 聯絡我們
            ContactView()
                .tabItem {
                    Image(systemName: "phone.fill")
                    Text("聯絡我們")
                }
                .tag(5)
        }
        .accentColor(.pink)
        .sheet(isPresented: $showingLoginSheet) {
            LoginView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchToCart)) { _ in
            selectedTab = 2 // 切換到購物車標籤頁
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchToOrders)) { _ in
            selectedTab = 3 // 切換到訂單頁面
        }
        .onAppear {
            contactManager.setModelContext(modelContext)
            authManager.setModelContext(modelContext)
        }
    }
}

// MARK: - 首頁視圖
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var notificationManager: LocalNotificationManager
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

// MARK: - 臨時視圖（待實現）







#Preview {
    ContentView()
        .modelContainer(for: [FlowerProduct.self, StudioInfo.self], inMemory: true)
}
