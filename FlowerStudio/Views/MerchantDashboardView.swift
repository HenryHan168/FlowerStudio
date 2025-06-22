//
//  MerchantDashboardView.swift
//  FlowerStudio
//
//  Created by night on 2025/6/21.
//

import SwiftUI
import SwiftData

struct MerchantDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var notificationManager: LocalNotificationManager
    @Query(sort: \Order.createdAt, order: .reverse) private var allOrders: [Order]
    
    @State private var selectedStatus: OrderStatus = .pending
    @State private var showingStatusUpdateAlert = false
    @State private var selectedOrder: Order?
    
    // 按狀態分組的訂單
    private var ordersByStatus: [OrderStatus: [Order]] {
        Dictionary(grouping: allOrders) { $0.status }
    }
    
    // 今日訂單
    private var todayOrders: [Order] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return allOrders.filter { order in
            order.createdAt >= today && order.createdAt < tomorrow
        }
    }
    
    // 統計數據
    private var totalOrdersToday: Int { todayOrders.count }
    private var pendingOrdersCount: Int { ordersByStatus[.pending]?.count ?? 0 }
    private var processingOrdersCount: Int { ordersByStatus[.preparing]?.count ?? 0 }
    private var completedOrdersToday: Int {
        todayOrders.filter { $0.status == .completed }.count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 統計卡片
                    statisticsSection
                    
                    // 快速操作
                    quickActionsSection
                    
                    // 待處理訂單
                    pendingOrdersSection
                    
                    // 進行中訂單
                    processingOrdersSection
                }
                .padding()
            }
            .navigationTitle("業主儀表板")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("📊") {
                        sendDailySummaryNotification()
                    }
                }
            }
            .alert("更新訂單狀態", isPresented: $showingStatusUpdateAlert) {
                Button("準備中") {
                    updateOrderStatus(.preparing)
                }
                Button("製作完成") {
                    updateOrderStatus(.completed)
                }
                Button("已配送") {
                    updateOrderStatus(.delivered)
                }
                Button("取消", role: .cancel) { }
            } message: {
                if let order = selectedOrder {
                    Text("訂單 #\(order.orderNumber) 目前狀態：\(order.status.rawValue)")
                }
            }
        }
    }
    
    // 統計區塊
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("今日營運概況")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatisticCard(
                    title: "今日訂單",
                    value: "\(totalOrdersToday)",
                    icon: "bag.fill",
                    color: .blue
                )
                
                StatisticCard(
                    title: "待處理",
                    value: "\(pendingOrdersCount)",
                    icon: "clock.fill",
                    color: .orange
                )
                
                StatisticCard(
                    title: "製作中",
                    value: "\(processingOrdersCount)",
                    icon: "hammer.fill",
                    color: .purple
                )
                
                StatisticCard(
                    title: "今日完成",
                    value: "\(completedOrdersToday)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
        }
    }
    
    // 快速操作區塊
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("快速操作")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickActionButton(
                    title: "測試通知",
                    icon: "bell.fill",
                    color: .blue
                ) {
                    notificationManager.sendTestMerchantNotification()
                }
                
                QuickActionButton(
                    title: "每日提醒",
                    icon: "calendar.badge.clock",
                    color: .green
                ) {
                    sendDailyReminderNotification()
                }
                
                QuickActionButton(
                    title: "營業提醒",
                    icon: "storefront.fill",
                    color: .pink
                ) {
                    sendBusinessReminderNotification()
                }
                
                QuickActionButton(
                    title: "庫存提醒",
                    icon: "archivebox.fill",
                    color: .orange
                ) {
                    sendInventoryReminderNotification()
                }
            }
        }
    }
    
    // 待處理訂單區塊
    private var pendingOrdersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("待處理訂單")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if pendingOrdersCount > 0 {
                    Text("\(pendingOrdersCount) 筆")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            if let pendingOrders = ordersByStatus[.pending], !pendingOrders.isEmpty {
                ForEach(pendingOrders.prefix(5)) { order in
                    OrderRowView(order: order) {
                        selectedOrder = order
                        showingStatusUpdateAlert = true
                    }
                }
                
                if pendingOrders.count > 5 {
                    NavigationLink(destination: OrderListView()) {
                        Text("查看全部 \(pendingOrders.count) 筆待處理訂單")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            } else {
                Text("目前沒有待處理的訂單")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
    
    // 進行中訂單區塊
    private var processingOrdersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("製作中訂單")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if processingOrdersCount > 0 {
                    Text("\(processingOrdersCount) 筆")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            if let processingOrders = ordersByStatus[.preparing], !processingOrders.isEmpty {
                ForEach(processingOrders.prefix(3)) { order in
                    OrderRowView(order: order) {
                        selectedOrder = order
                        showingStatusUpdateAlert = true
                    }
                }
                
                if processingOrders.count > 3 {
                    NavigationLink(destination: OrderListView()) {
                        Text("查看全部 \(processingOrders.count) 筆製作中訂單")
                            .font(.subheadline)
                            .foregroundColor(.purple)
                    }
                }
            } else {
                Text("目前沒有製作中的訂單")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
    
    // 更新訂單狀態
    private func updateOrderStatus(_ newStatus: OrderStatus) {
        guard let order = selectedOrder else { return }
        
        order.status = newStatus
        order.updatedAt = Date()
        
        do {
            try modelContext.save()
            
            // 發送狀態更新通知給客戶
            notificationManager.sendOrderStatusNotification(
                orderNumber: order.orderNumber,
                status: newStatus.rawValue,
                customerName: order.customerName
            )
            
            print("✅ 訂單 \(order.orderNumber) 狀態已更新為 \(newStatus.rawValue)")
        } catch {
            print("❌ 更新訂單狀態失敗: \(error)")
        }
    }
    
    // 發送每日摘要通知
    private func sendDailySummaryNotification() {
        let message = "今日營運摘要：\(totalOrdersToday) 筆訂單，\(pendingOrdersCount) 筆待處理，\(processingOrdersCount) 筆製作中，\(completedOrdersToday) 筆已完成。"
        
        notificationManager.sendMerchantReminderNotification(
            title: "每日營運摘要",
            message: message
        )
    }
    
    // 發送每日提醒通知
    private func sendDailyReminderNotification() {
        notificationManager.sendMerchantReminderNotification(
            title: "每日工作提醒",
            message: "記得檢查今日的訂單進度，準備明日所需的花材，並確認客戶聯絡資訊！"
        )
    }
    
    // 發送營業提醒通知
    private func sendBusinessReminderNotification() {
        notificationManager.sendMerchantReminderNotification(
            title: "營業提醒",
            message: "記得更新營業時間，檢查店面環境，並準備迎接客戶！"
        )
    }
    
    // 發送庫存提醒通知
    private func sendInventoryReminderNotification() {
        notificationManager.sendMerchantReminderNotification(
            title: "庫存檢查提醒",
            message: "記得檢查花材庫存，補充不足的材料，並確認配送安排！"
        )
    }
}

// 統計卡片組件
struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// 快速操作按鈕組件
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .cornerRadius(12)
        }
    }
}

// 訂單行組件
struct OrderRowView: View {
    let order: Order
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("訂單 #\(order.orderNumber)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(order.customerName) - \(order.productName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(order.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(order.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(order.status.color))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    
                    Text("NT$ \(Int(order.totalAmount))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.pink)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MerchantDashboardView()
        .modelContainer(for: Order.self, inMemory: true)
        .environmentObject(LocalNotificationManager.shared)
} 