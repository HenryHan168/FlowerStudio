//
//  OrderListView.swift
//  FlowerStudio
//
//  Created by night on 2025/6/8.
//

import SwiftUI
import SwiftData

struct OrderListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Order.createdAt, order: .reverse) private var orders: [Order]
    @State private var selectedStatus: OrderStatus?
    
    // 篩選後的訂單
    var filteredOrders: [Order] {
        if let status = selectedStatus {
            return orders.filter { $0.status == status }
        }
        return orders
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 狀態篩選欄
                if !orders.isEmpty {
                    statusFilterBar
                }
                
                // 訂單列表
                if filteredOrders.isEmpty {
                    emptyStateView
                } else {
                    ordersList
                }
            }
            .navigationTitle("我的訂單")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // 狀態篩選欄
    private var statusFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // 全部訂單按鈕
                StatusFilterButton(
                    title: "全部",
                    count: orders.count,
                    isSelected: selectedStatus == nil,
                    color: .gray
                ) {
                    selectedStatus = nil
                }
                
                // 各個狀態按鈕
                ForEach(OrderStatus.allCases, id: \.self) { status in
                    let count = orders.filter { $0.status == status }.count
                    if count > 0 {
                        StatusFilterButton(
                            title: status.rawValue,
                            count: count,
                            isSelected: selectedStatus == status,
                            color: Color(status.color)
                        ) {
                            selectedStatus = status == selectedStatus ? nil : status
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    // 訂單列表
    private var ordersList: some View {
        List {
            ForEach(filteredOrders) { order in
                OrderCard(order: order)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 4)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // 空狀態視圖
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "bag.badge.questionmark")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("尚無訂單記錄")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("開始瀏覽我們的花藝作品，創造美好回憶")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            NavigationLink(destination: ProductListView()) {
                Text("瀏覽花藝作品")
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
    

}

// MARK: - 狀態篩選按鈕
struct StatusFilterButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("(\(count))")
                    .font(.caption2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? color : Color(.systemBackground)
            )
            .foregroundColor(
                isSelected ? .white : color
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 訂單卡片
struct OrderCard: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 訂單頭部
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("訂單編號: \(order.orderNumber)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(order.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 訂單狀態標籤
                HStack {
                    Image(systemName: order.status.iconName)
                        .font(.caption)
                    Text(order.status.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(order.status.color).opacity(0.2))
                .foregroundColor(Color(order.status.color))
                .cornerRadius(12)
            }
            
            // 產品資訊
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.pink.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.title2)
                            .foregroundColor(.pink)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.productName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("數量: \(order.quantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("NT$ \(Int(order.totalAmount))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                }
                
                Spacer()
            }
            
            // 配送資訊
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: order.deliveryMethod.iconName)
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(order.deliveryMethod.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(order.preferredDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(order.preferredTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let address = order.deliveryAddress {
                    HStack {
                        Image(systemName: "location")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            

        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    

}

#Preview {
    OrderListView()
        .modelContainer(for: Order.self, inMemory: true)
} 