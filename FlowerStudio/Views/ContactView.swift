//
//  ContactView.swift
//  FlowerStudio
//
//  Created by night on 2025/6/8.
//

import SwiftUI
import SwiftData
import MapKit

struct ContactView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var studioInfo: [StudioInfo]
    
    var currentStudio: StudioInfo? {
        studioInfo.first
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 工作室頭部資訊
                    studioHeaderSection
                    
                    // 聯絡方式
                    contactMethodsSection
                    
                    // 地圖和地址
                    locationSection
                    
                    // 營業時間
                    businessHoursSection
                    
                    // 服務說明
                    serviceInfoSection
                }
                .padding()
            }
            .navigationTitle("聯絡我們")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // 工作室頭部資訊
    private var studioHeaderSection: some View {
        VStack(spacing: 16) {
            // Logo和名稱
            VStack(spacing: 12) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.pink)
                
                if let studio = currentStudio {
                    Text(studio.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(studio.studioDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // 營業狀態
            if let studio = currentStudio {
                HStack {
                    Circle()
                        .fill(Color(studio.currentBusinessStatus.color))
                        .frame(width: 8, height: 8)
                    
                    Text(studio.currentBusinessStatus.displayText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(studio.currentBusinessStatus.color))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(studio.currentBusinessStatus.color).opacity(0.1))
                .cornerRadius(16)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.pink.opacity(0.1), .purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    // 聯絡方式
    private var contactMethodsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("聯絡方式")
                .font(.title2)
                .fontWeight(.bold)
            
            if let studio = currentStudio {
                VStack(spacing: 12) {
                    ContactMethodCard(
                        icon: "phone.fill",
                        title: "訂購專線",
                        content: studio.formattedPhone,
                        description: "點擊立即撥打",
                        color: .green
                    ) {
                        makePhoneCall()
                    }
                    
                    if let email = studio.email {
                        ContactMethodCard(
                            icon: "envelope.fill",
                            title: "電子郵件",
                            content: email,
                            description: "點擊發送郵件",
                            color: .blue
                        ) {
                            sendEmail(to: email)
                        }
                    }
                    
                    ContactMethodCard(
                        icon: "message.fill",
                        title: "LINE諮詢",
                        content: "@flowerstudio",
                        description: "點擊加入好友",
                        color: Color(red: 0.0, green: 0.7, blue: 0.3)
                    ) {
                        openLineContact()
                    }
                }
            }
        }
    }
    
    // 地圖和地址
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("店面位置")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                // 地圖
                Map {
                    Marker("花漾花藝工作室", coordinate: CLLocationCoordinate2D(latitude: 24.678, longitude: 121.775))
                        .tint(.pink)
                }
                .mapStyle(.standard)
                .frame(height: 200)
                .cornerRadius(12)
                
                // 地址資訊
                if let studio = currentStudio {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.red)
                            Text("地址")
                                .font(.headline)
                            Spacer()
                        }
                        
                        Text(studio.address)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Button("開啟地圖導航") {
                            openMapsNavigation()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // 營業時間
    private var businessHoursSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("營業時間")
                .font(.title2)
                .fontWeight(.bold)
            
            if let studio = currentStudio {
                VStack(spacing: 8) {
                    ForEach(studio.businessHours.sorted(by: { $0.dayOfWeek < $1.dayOfWeek }), id: \.dayOfWeek) { hour in
                        BusinessHourRow(businessHour: hour)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    // 服務說明
    private var serviceInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("服務說明")
                .font(.title2)
                .fontWeight(.bold)
            
            if let studio = currentStudio {
                VStack(spacing: 12) {
                    ServiceInfoCard(
                        icon: "truck.box.fill",
                        title: "配送服務",
                        content: studio.deliveryAvailable ? "提供配送" : "僅提供取貨",
                        description: studio.deliveryRange ?? "請洽詢詳細範圍"
                    )
                    
                    ServiceInfoCard(
                        icon: "dollarsign.circle.fill",
                        title: "最低訂購金額",
                        content: "NT$ \(Int(studio.minimumOrderAmount))",
                        description: "未達最低金額將酌收手續費"
                    )
                    
                    ServiceInfoCard(
                        icon: "clock.fill",
                        title: "製作時間",
                        content: "1-3個工作天",
                        description: "依作品複雜度而定，急件請事先洽詢"
                    )
                }
            }
        }
    }
    
    // 聯絡功能
    private func makePhoneCall() {
        if let studio = currentStudio,
           let url = URL(string: "tel://\(studio.phone)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func sendEmail(to email: String) {
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openLineContact() {
        // 實際使用時需要真實的LINE連結
        if let url = URL(string: "https://line.me/ti/p/@flowerstudio") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openMapsNavigation() {
        if let studio = currentStudio {
            let encodedAddress = studio.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let url = URL(string: "maps://?q=\(encodedAddress)") {
                UIApplication.shared.open(url)
            }
        }
    }
}

// MARK: - 聯絡方式卡片
struct ContactMethodCard: View {
    let icon: String
    let title: String
    let content: String
    let description: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(content)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(color)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 營業時間行
struct BusinessHourRow: View {
    let businessHour: BusinessHour
    
    var body: some View {
        HStack {
            Text(businessHour.dayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 40, alignment: .leading)
            
            Spacer()
            
            Text(businessHour.timeString)
                .font(.subheadline)
                .foregroundColor(businessHour.isClosed ? .red : .secondary)
                .fontWeight(businessHour.isClosed ? .medium : .regular)
        }
    }
}

// MARK: - 服務資訊卡片
struct ServiceInfoCard: View {
    let icon: String
    let title: String
    let content: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.pink)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(content)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.pink)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}



#Preview {
    ContactView()
        .modelContainer(for: StudioInfo.self, inMemory: true)
} 