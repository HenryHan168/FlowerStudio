//
//  FlowerStudioApp.swift
//  FlowerStudio
//
//  Created by night on 2025/6/8.
//

import SwiftUI
import SwiftData

@main
struct FlowerStudioApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FlowerProduct.self,
            Order.self,
            StudioInfo.self,
            BusinessHour.self,
            SocialMediaLink.self,
            CartItem.self
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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

/// 初始化示例數據
private func initializeSampleData(container: ModelContainer) {
    let context = ModelContext(container)
    
    // 檢查是否已經有數據
    let descriptor = FetchDescriptor<FlowerProduct>()
    do {
        let existingProducts = try context.fetch(descriptor)
        if !existingProducts.isEmpty {
            return // 已有數據，不需要初始化
        }
    } catch {
        print("Failed to fetch existing products: \(error)")
    }
    
    // 建立工作室資訊
    let studioInfo = StudioInfo()
    context.insert(studioInfo)
    
    // 建立示例花藝作品
    let sampleProducts = [
        FlowerProduct(
            name: "經典玫瑰花束",
            productDescription: "12朵紅玫瑰配滿天星，表達深深的愛意，適合情人節、求婚等浪漫時刻。",
            price: 1200,
            category: .wedding,
            imageName: "rose_bouquet",
            isCustomizable: true,
            preparationDays: 1,
            isFeatured: true
        ),
        FlowerProduct(
            name: "生日快樂花束",
            productDescription: "繽紛多彩的混合花束，包含向日葵、康乃馨和小雛菊，為生日增添歡樂氣氛。",
            price: 800,
            category: .birthday,
            imageName: "birthday_bouquet",
            isCustomizable: true,
            preparationDays: 1,
            isFeatured: true
        ),
        FlowerProduct(
            name: "新年祝賀花籃",
            productDescription: "金桔、富貴竹配搭鮮花，寓意招財進寶，適合新年開業祝賀。",
            price: 2500,
            category: .festival,
            imageName: "new_year_basket",
            isCustomizable: false,
            preparationDays: 2,
            isFeatured: true
        ),
        FlowerProduct(
            name: "康乃馨感恩花束",
            productDescription: "粉色康乃馨花束，表達對母親的感謝之情，母親節首選。",
            price: 600,
            category: .congratulation,
            imageName: "carnation_bouquet",
            isCustomizable: true,
            preparationDays: 1,
            isFeatured: false
        ),
        FlowerProduct(
            name: "優雅白百合",
            productDescription: "純白百合花束，象徵純潔與莊嚴，適合各種正式場合。",
            price: 1000,
            category: .decoration,
            imageName: "lily_bouquet",
            isCustomizable: true,
            preparationDays: 1,
            isFeatured: false
        ),
        FlowerProduct(
            name: "多肉植物組合",
            productDescription: "精心搭配的多肉植物盆栽，易於照顧，為居家增添綠意。",
            price: 450,
            category: .potted,
            imageName: "succulent_pot",
            isCustomizable: false,
            preparationDays: 1,
            isFeatured: true
        )
    ]
    
    // 插入示例產品
    for product in sampleProducts {
        context.insert(product)
    }
    
    // 保存數據
    do {
        try context.save()
        print("Sample data initialized successfully")
    } catch {
        print("Failed to save sample data: \(error)")
    }
}
