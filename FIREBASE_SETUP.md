# Firebase 設定指南 🔥

## 📋 功能概述
透過 Firebase 集成，商家可以：
- 即時接收新訂單通知
- 在 Firebase Console 中查看所有訂單
- 透過推播通知第一時間得知新訂單
- 更新訂單狀態和管理訂單

## 🚀 設定步驟

### 1. 建立 Firebase 專案
1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 點擊「建立專案」
3. 輸入專案名稱（例如：花漾花藝工作室）
4. 選擇是否啟用 Google Analytics（建議啟用）
5. 完成專案建立

### 2. 新增 iOS 應用程式
1. 在 Firebase 專案中點擊「新增應用程式」
2. 選擇 iOS 圖示
3. 輸入 Bundle ID：`com.flowerstudio.app`
4. 輸入應用程式暱稱：`FlowerStudio`
5. 下載 `GoogleService-Info.plist` 檔案

### 3. 將設定檔加入專案
1. 將下載的 `GoogleService-Info.plist` 檔案拖拽到 Xcode 專案中
2. 確保檔案已加入到專案目標中
3. 確認檔案在專案根目錄中

### 4. 安裝 Firebase SDK
在 Xcode 中：
1. File → Add Package Dependencies
2. 輸入 URL：`https://github.com/firebase/firebase-ios-sdk.git`
3. 選擇版本：使用最新版本
4. 選擇需要的 Firebase 產品：
   - FirebaseFirestore
   - FirebaseMessaging
   - FirebaseCore

**檢查安裝狀態：**
- 在 Xcode 專案導航器中，確認看到 Firebase 相關的套件
- 檢查 Package Dependencies 區域是否顯示 Firebase SDK

### 4.1 驗證 Firebase SDK 安裝
如果您在 import Firebase 時遇到錯誤，請確認：
1. Firebase SDK 已正確安裝
2. 在 Target 的 Frameworks and Libraries 中包含必要的 Firebase 模組
3. 清理並重建專案（Product → Clean Build Folder）

### 5. 修改 App 檔案
在 `FlowerStudioApp.swift` 中加入：

```swift
import Firebase

@main
struct FlowerStudioApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [/* 現有的模型 */])
        }
    }
}
```

### 6. 設定 Firestore 資料庫
1. 在 Firebase Console 中點擊「Firestore Database」
2. 點擊「建立資料庫」
3. 選擇「以測試模式開始」
4. 選擇資料庫位置（建議選擇 asia-east1）

### 7. 設定 Cloud Messaging (APNs)
#### 🔍 找到 APNs 設定位置：
**方法一：透過 Cloud Messaging**
1. 在 Firebase Console 中點擊左側選單「Cloud Messaging」
2. 切換到頂部的「Apple app certificates」分頁
3. 您會看到上傳 APNs 證書或密鑰的選項

**方法二：透過專案設定**
1. 點擊左上角 ⚙️ 齒輪圖示
2. 選擇「專案設定」(Project Settings)
3. 切換到「Cloud Messaging」分頁
4. 向下滾動找到「Apple app certificates」區域

#### 📱 設定 APNs 密鑰（推薦方式）：
1. 前往 [Apple Developer Console](https://developer.apple.com/account/resources/authkeys/list)
2. 點擊「+」建立新密鑰
3. 輸入密鑰名稱（例如：FlowerStudio APNs Key）
4. 勾選「Apple Push Notifications service (APNs)」
5. ⚠️ **重要**：點擊 APNs 右側的「Configure」按鈕
6. 在設定頁面中進行以下選擇：
   
   **Environment（環境）：**
   - 🎯 **推薦選擇：`Sandbox & Production`**
   - 這樣可以在開發和正式環境都使用同一個密鑰
   
   **Key Restriction（密鑰限制）：**
   - 🎯 **推薦選擇：`Team Scoped (All Topics)`**
   - 支援所有 App 和所有推播主題，最靈活的選項
   
7. 點擊「Save」完成設定
8. 點擊「Continue」繼續
9. 下載 `.p8` 檔案並記住 Key ID
10. 回到 Firebase Console，在 APNs 設定中：
    - 上傳 `.p8` 檔案
    - 輸入 Key ID
    - 輸入 Team ID（在 Apple Developer Console 右上角可找到）

#### 📱 或使用 APNs 證書（舊方式）：
1. 在 Apple Developer Console 建立 Push Notification 證書
2. 下載並安裝證書
3. 匯出為 `.p12` 格式
4. 在 Firebase 中上傳 `.p12` 檔案

### 8. 設定推播通知權限

#### 🔧 方法一：透過 Xcode 專案設定（推薦）
1. 開啟 Xcode 專案
2. 選擇左側的 `FlowerStudio` 專案名稱
3. 選擇 TARGETS 下的 `FlowerStudio`
4. 切換到 `Info` 分頁
5. 新增或編輯 `UIBackgroundModes`：
   - Key: `UIBackgroundModes`
   - Type: `Array`
   - 在 Array 中新增項目：`remote-notification`

#### 🔧 方法二：使用 Info.plist 檔案
在專案中的 `Info.plist` 檔案中加入：
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

**注意**：現代 SwiftUI 專案通常透過 Xcode 專案設定管理這些權限，建議優先使用方法一。

## 📊 資料庫結構

### Orders Collection
```
orders/
  ├── {orderId}/
      ├── id: String
      ├── orderNumber: String
      ├── customerName: String
      ├── customerPhone: String
      ├── customerEmail: String
      ├── productName: String
      ├── quantity: Number
      ├── unitPrice: Number
      ├── totalAmount: Number
      ├── customRequirements: String
      ├── recipientName: String
      ├── recipientPhone: String
      ├── deliveryMethod: String
      ├── deliveryAddress: String
      ├── preferredDate: Timestamp
      ├── preferredTime: String
      ├── notes: String
      ├── orderStatus: String
      ├── createdAt: Timestamp
      └── updatedAt: Timestamp
```

## 🔔 推播通知設定

### 商家端通知
當有新訂單時，系統會自動發送推播通知給商家，包含：
- 訂單編號
- 客戶姓名
- 訂單金額
- 訂單時間

### 通知主題
- 主題名稱：`merchant_notifications`
- 商家需要訂閱此主題才能收到通知

## 🛠 使用方式

### 客戶端（自動）
- 當客戶完成訂單時，系統會自動：
  1. 將訂單資料上傳到 Firestore
  2. 發送推播通知給商家
  3. 在本地保存訂單記錄

### 商家端
- 可以透過 Firebase Console 查看所有訂單
- 接收即時推播通知
- 可以更新訂單狀態

## 📱 測試訂單流程

1. 在 iOS 模擬器中測試應用程式
2. 加入商品到購物車
3. 完成訂單資訊填寫
4. 確認訂單
5. 檢查 Firebase Console 中是否出現訂單資料

## 🔐 安全規則

建議在 Firestore 中設定安全規則：

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 允許讀取和寫入訂單
    match /orders/{orderId} {
      allow read, write: if true; // 生產環境請加入適當的驗證
    }
  }
}
```

## 🛠 APNs 設定故障排除

### 常見問題與解決方法：

**❓ 看到紅色/黃色警告訊息**
- 點擊 APNs 服務右側的「Configure」按鈕
- 按照上述步驟選擇正確的 Environment 和 Key Restriction

**❓ 不知道選哪個環境**
- 選擇 `Sandbox & Production` 最安全，適用於所有情況

**❓ Key Restriction 選項不確定**
- 花藝工作室 App 建議選擇 `Team Scoped (All Topics)`
- 這個選項支援最完整的推播功能

**❓ 找不到 Team ID**
- 在 Apple Developer Console 右上角可以找到
- 格式通常是 10 位英數字組合

**❓ 下載的 .p8 檔案在哪裡使用**
- 在 Firebase Console → Cloud Messaging → Apple app certificates
- 上傳 .p8 檔案並填入對應的 Key ID 和 Team ID

## 📞 技術支援

如果在設定過程中遇到問題：
1. 檢查 Xcode Console 中的錯誤訊息
2. 確認 Firebase 專案設定正確
3. 驗證網路連線狀態
4. 參考 Firebase 官方文件
5. 檢查 APNs 密鑰設定是否正確

## 🎯 下一步

設定完成後，您的花藝工作室應用程式將能夠：
- ✅ 自動上傳訂單到雲端
- ✅ 即時通知商家新訂單
- ✅ 提供完整的訂單管理功能
- ✅ 保證訂單資料的安全性和可靠性

## 🧪 測試 Firebase 整合

### 📋 設定完成檢查清單
在開始測試前，請確認以下設定：

**Xcode 專案設定：**
- [ ] Firebase SDK 已安裝（File → Add Package Dependencies）
- [ ] GoogleService-Info.plist 已加入專案
- [ ] UIBackgroundModes 包含 remote-notification
- [ ] Bundle ID 與 Firebase 專案一致：`com.flowerstudio.app`

**Firebase Console 設定：**
- [ ] 已建立 Firebase 專案
- [ ] 已新增 iOS 應用程式
- [ ] 已設定 Firestore 資料庫（測試模式）
- [ ] 已上傳 APNs 密鑰或證書

**App 程式碼：**
- [ ] FlowerStudioApp.swift 包含 Firebase 初始化
- [ ] FirebaseManager 已更新為真實功能
- [ ] 推播通知權限已請求

### 🧪 測試步驟

1. **編譯並執行應用程式**
   ```bash
   # 在 Xcode 中按 Cmd+R 執行
   ```

2. **檢查 Console 輸出**
   - 應該看到：`✅ 已訂閱商家通知主題`
   - 應該看到：`✅ 推播通知權限已獲得`

3. **測試訂單流程**
   - 加入商品到購物車
   - 填寫訂單資訊
   - 確認訂單
   - 檢查 Console 是否顯示：`✅ 訂單已成功上傳到 Firestore`

4. **檢查 Firebase Console**
   - 前往 Firestore Database
   - 檢查 `orders` collection 是否有新訂單資料

### 🔧 常見問題排解

**❌ 編譯錯誤：找不到 Firebase 模組**
- 確認 Firebase SDK 已正確安裝
- 清理並重建專案（Product → Clean Build Folder）

**❌ 推播通知權限被拒絕**
- 在 iOS 設定中重新開啟通知權限
- 重新安裝應用程式

**❌ 訂單上傳失敗**
- 檢查網路連線
- 確認 Firestore 規則允許寫入
- 檢查 GoogleService-Info.plist 設定

### 📱 推播通知測試

目前的設定支援接收推播通知，但發送推播需要：
1. **Cloud Functions**（推薦）- 自動觸發推播
2. **FCM Admin SDK**（後端）- 手動發送推播
3. **Firebase Console**（手動）- 測試推播

## 🎉 恭喜！

您的花藝工作室 Firebase 整合已完成！現在可以：
- 🚀 接收真實的訂單資料
- 📊 在 Firebase Console 中管理訂單
- 🔔 準備好接收推播通知
- 📈 擴展更多 Firebase 功能

---

*這個設定將大幅提升您的花藝工作室的營運效率！* 🌸 