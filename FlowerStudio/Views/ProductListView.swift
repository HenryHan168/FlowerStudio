//
//  ProductListView.swift
//  FlowerStudio
//
//  Created by night on 2025/6/8.
//

import SwiftUI
import SwiftData

struct ProductListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allProducts: [FlowerProduct]
    @State private var selectedCategory: ProductCategory?
    @State private var searchText = ""
    @State private var showingFilters = false
    
    // 篩選後的產品
    var filteredProducts: [FlowerProduct] {
        var products = allProducts
        
        // 分類篩選
        if let category = selectedCategory {
            products = products.filter { $0.category == category }
        }
        
        // 搜索篩選
        if !searchText.isEmpty {
            products = products.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.productDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return products.sorted { $0.isFeatured && !$1.isFeatured }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索欄
                searchBar
                
                // 分類篩選欄
                categoryFilterBar
                
                // 產品列表
                productGrid
            }
            .navigationTitle("花藝作品")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("篩選") {
                        showingFilters = true
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(selectedCategory: $selectedCategory)
            }
        }
    }
    
    // 搜索欄
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("搜索花藝作品...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // 分類篩選欄
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // 全部分類按鈕
                CategoryButton(
                    title: "全部",
                    iconName: "square.grid.2x2",
                    isSelected: selectedCategory == nil,
                    color: "gray"
                ) {
                    selectedCategory = nil
                }
                
                // 各個分類按鈕
                ForEach(ProductCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        title: category.rawValue,
                        iconName: category.iconName,
                        isSelected: selectedCategory == category,
                        color: category.color
                    ) {
                        selectedCategory = category == selectedCategory ? nil : category
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    // 產品網格
    private var productGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(filteredProducts) { product in
                    ProductCard(product: product)
                }
            }
            .padding()
        }
    }
}

// MARK: - 分類按鈕
struct CategoryButton: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let color: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color(color) : Color(.systemBackground)
            )
            .foregroundColor(
                isSelected ? .white : Color(color)
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(color), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 產品卡片
struct ProductCard: View {
    let product: FlowerProduct
    
    var body: some View {
        NavigationLink(destination: ProductDetailView(product: product)) {
            VStack(alignment: .leading, spacing: 12) {
                // 產品圖片區域
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            colors: [
                                Color(product.category.color).opacity(0.3),
                                Color(product.category.color).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 140)
                    
                    VStack(spacing: 8) {
                        Image(systemName: product.category.iconName)
                            .font(.title)
                            .foregroundColor(Color(product.category.color))
                        
                        Text(product.category.rawValue)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    // 精選標籤
                    if product.isFeatured {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                    .padding(6)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            Spacer()
                        }
                        .padding(8)
                    }
                }
                
                // 產品資訊
                VStack(alignment: .leading, spacing: 6) {
                    Text(product.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    Text(product.productDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                    
                    HStack {
                        Text("NT$ \(Int(product.price))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.pink)
                        
                        Spacer()
                        
                        if product.isCustomizable {
                            Text("可客製")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(4)
                        }
                    }
                    
                    // 製作天數
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(product.preparationDays)天製作")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 篩選視圖
struct FilterView: View {
    @Binding var selectedCategory: ProductCategory?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("產品分類") {
                    Button("全部分類") {
                        selectedCategory = nil
                        dismiss()
                    }
                    .foregroundColor(selectedCategory == nil ? .pink : .primary)
                    
                    ForEach(ProductCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: category.iconName)
                                    .foregroundColor(Color(category.color))
                                Text(category.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedCategory == category {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.pink)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("篩選條件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProductListView()
        .modelContainer(for: FlowerProduct.self, inMemory: true)
} 