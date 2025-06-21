import SwiftUI
// import FirebaseFirestore // 暫時註解掉，直到Firebase SDK安裝完成

// MARK: - 商家端訂單管理視圖
struct MerchantOrdersView: View {
    @State private var orders: [String] = []
    
    var body: some View {
        NavigationView {
            VStack {
                Text("商家端訂單管理")
                    .font(.title)
                Text("此功能需要Firebase設定")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("訂單管理")
        }
    }
}

#Preview {
    MerchantOrdersView()
} 