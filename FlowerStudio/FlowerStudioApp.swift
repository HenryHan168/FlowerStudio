//
//  FlowerStudioApp.swift
//  FlowerStudio
//
//  Created by night on 2025/6/8.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct FlowerStudioApp: App {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @StateObject private var notificationManager = LocalNotificationManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FlowerProduct.self,
            Order.self,
            StudioInfo.self,
            BusinessHour.self,
            SocialMediaLink.self,
            CartItem.self,
            Contact.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // 初始化示例數據
            initializeSampleData(container: container)
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        FirebaseApp.configure()
        print("🌸 FlowerStudio 應用程式已啟動")
        print("✅ Firebase 已配置")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(firebaseManager)
                .environmentObject(notificationManager)
        }
        .modelContainer(sharedModelContainer)
    }
}

/// 初始化示例數據
@MainActor
private func initializeSampleData(container: ModelContainer) {
    let context = ModelContext(container)
    
    print("🚀 開始初始化應用程式數據...")
    
    // 建立工作室資訊
    let studioInfoDescriptor = FetchDescriptor<StudioInfo>()
    do {
        let existingStudioInfo = try context.fetch(studioInfoDescriptor)
        if existingStudioInfo.isEmpty {
            let studioInfo = StudioInfo()
            context.insert(studioInfo)
            print("📝 工作室資訊已創建")
        }
    } catch {
        print("❌ 創建工作室資訊失敗: \(error)")
    }
    
    // 直接在這裡初始化花卉產品數據
    initializeFlowerProducts(context: context)
}

/// 直接初始化花卉產品數據
@MainActor
private func initializeFlowerProducts(context: ModelContext) {
    // 檢查是否已經有數據
    let descriptor = FetchDescriptor<FlowerProduct>()
    let existingProducts = (try? context.fetch(descriptor)) ?? []
    
    // 總是清理並重新載入數據以確保顯示最新的圖片
    print("🧹 清理所有舊花卉產品數據...")
    existingProducts.forEach { product in
        context.delete(product)
    }
    
    print("🔄 載入帶真實圖片的新花卉產品數據...")
    
    let sampleProducts = [
        // 婚禮花束
        FlowerProduct(
            name: "經典白玫瑰新娘花束",
            productDescription: "純白玫瑰與滿天星的經典組合，象徵純潔與永恆的愛情，是婚禮中不可或缺的美麗配件。",
            price: 2800,
            category: .wedding,
            imageName: "wedding_bouquet",
            imageURL: "https://images.unsplash.com/photo-1520763185298-1b434c919102?w=800&q=80",
            isCustomizable: true,
            preparationDays: 3,
            isFeatured: true
        ),
        FlowerProduct(
            name: "粉紅色系新娘捧花",
            productDescription: "溫柔的粉色玫瑰配上白色桔梗，營造浪漫溫馨的婚禮氛圍。",
            price: 3200,
            category: .wedding,
            imageName: "pink_wedding_bouquet",
            imageURL: "https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=800&q=80",
            isCustomizable: true,
            preparationDays: 3,
            isFeatured: true
        ),
        
        // 生日花束
        FlowerProduct(
            name: "繽紛生日花束",
            productDescription: "色彩豐富的混合花束，包含向日葵、康乃馨和玫瑰，為生日帶來滿滿的祝福與歡樂。",
            price: 1800,
            category: .birthday,
            imageName: "birthday_bouquet",
            imageURL: "https://images.unsplash.com/photo-1563241527-3004b7be0ffd?w=800&q=80",
            isCustomizable: true,
            preparationDays: 2,
            isFeatured: true
        ),
        FlowerProduct(
            name: "向日葵陽光花束",
            productDescription: "明亮的向日葵主題花束，搭配黃色玫瑰，象徵陽光般的祝福與希望。",
            price: 1600,
            category: .birthday,
            imageName: "sunflower_bouquet",
            imageURL: "https://images.unsplash.com/photo-1471194402529-8e0f5a675de6?w=800&q=80",
            isCustomizable: false,
            preparationDays: 1
        ),
        
        // 節慶花籃
        FlowerProduct(
            name: "新春賀歲花籃",
            productDescription: "紅色與金色的節慶花籃，搭配蘭花和牡丹，寓意富貴吉祥、新年快樂。",
            price: 3500,
            category: .festival,
            imageName: "new_year_basket",
            imageURL: "https://images.unsplash.com/photo-1574684891174-df6b02ab38d7?w=800&q=80",
            isCustomizable: true,
            preparationDays: 2,
            isFeatured: true
        ),
        FlowerProduct(
            name: "聖誕節慶花籃",
            productDescription: "紅色玫瑰與白色花材的聖誕主題花籃，搭配松枝和聖誕裝飾。",
            price: 2800,
            category: .festival,
            imageName: "christmas_basket",
            imageURL: "https://images.unsplash.com/photo-1502977249166-824b3a8a4d6d?w=800&q=80",
            isCustomizable: true,
            preparationDays: 2
        ),
        
        // 祝賀花籃
        FlowerProduct(
            name: "開業祝賀花籃",
            productDescription: "豪華的祝賀花籃，以蘭花和玫瑰為主，象徵事業興隆、財源廣進。",
            price: 4200,
            category: .congratulation,
            imageName: "congratulation_basket",
            imageURL: "https://images.unsplash.com/photo-1586159101006-e61ced59d0e9?w=800&q=80",
            isCustomizable: true,
            preparationDays: 2
        ),
        FlowerProduct(
            name: "升職慶賀花束",
            productDescription: "優雅的粉色與白色花束，祝賀升職成功，前程似錦。",
            price: 2500,
            category: .congratulation,
            imageName: "promotion_bouquet",
            imageURL: "https://images.unsplash.com/photo-1487070183336-b863922373d4?w=800&q=80",
            isCustomizable: false,
            preparationDays: 1
        ),
        
        // 追思花圈
        FlowerProduct(
            name: "白色百合花圈",
            productDescription: "純潔的白色百合花圈，表達對逝者的敬意與懷念。",
            price: 3800,
            category: .funeral,
            imageName: "white_lily_wreath",
            imageURL: "https://images.unsplash.com/photo-1518895949257-7621c3c786d7?w=800&q=80",
            isCustomizable: true,
            preparationDays: 1
        ),
        
        // 裝飾花藝
        FlowerProduct(
            name: "居家裝飾花束",
            productDescription: "適合居家擺設的混合花束，為您的家增添自然的美麗與芬芳。",
            price: 1200,
            category: .decoration,
            imageName: "home_decoration",
            imageURL: "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&q=80",
            isCustomizable: false,
            preparationDays: 1
        ),
        FlowerProduct(
            name: "辦公室桌花",
            productDescription: "簡約優雅的桌花設計，為辦公環境帶來清新的氣息。",
            price: 900,
            category: .decoration,
            imageName: "office_flower",
            imageURL: "https://images.unsplash.com/photo-1526047932273-341f2a7631f9?w=800&q=80",
            isCustomizable: false,
            preparationDays: 1
        ),
        
        // 盆栽植物
        FlowerProduct(
            name: "多肉植物組合",
            productDescription: "精心搭配的多肉植物組合，易於照料，適合新手園藝愛好者。",
            price: 800,
            category: .potted,
            imageName: "succulent_combo",
            imageURL: "https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=800&q=80",
            isCustomizable: false,
            preparationDays: 1
        ),
        FlowerProduct(
            name: "觀葉植物盆栽",
            productDescription: "綠意盎然的觀葉植物，淨化空氣，為室內帶來生機。",
            price: 1500,
            category: .potted,
            imageName: "green_plant",
            imageURL: "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&q=80",
            isCustomizable: false,
            preparationDays: 1
        )
    ]
    
    sampleProducts.forEach { product in
        context.insert(product)
        print("📸 已添加產品: \(product.name) - 圖片URL: \(product.imageURL ?? "無")")
    }
    
    do {
        try context.save()
        print("✅ 花卉產品數據初始化完成，共 \(sampleProducts.count) 個產品")
    } catch {
        print("❌ 保存花卉產品數據失敗: \(error)")
    }
}
