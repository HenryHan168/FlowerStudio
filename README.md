# 花漾花藝工作室 iOS 應用程式

## 專案簡介
花漾花藝工作室是一個專業的花藝訂購iOS應用程式，提供用戶瀏覽花卉作品、線上訂購和聯絡服務的完整體驗。應用程式整合了 Firebase 後端服務，支援即時推播通知功能。

## 店家資訊
- **店名**: 花漾花藝工作室
- **訂購專線**: 0920663393
- **地址**: 宜蘭縣羅東鎮中山路四段20巷12號
- **Bundle ID**: com.flowerstudio.app
- **Firebase 專案**: flowerstudio-531e8

## 主要功能

### 1. 首頁展示
- 工作室品牌介紹
- 精選花藝作品輪播
- 快速聯絡按鈕
- 營業時間與地址資訊

### 2. 花藝作品展示
- 分類瀏覽（婚禮花束、生日花束、節慶花籃等）
- 作品詳細介紹和價格
- 高品質圖片展示
- 客製化選項

### 3. 訂購系統
- 選擇花藝作品
- 填寫訂購資訊
- 選擇取貨或配送方式
- 預約取貨時間
- **Firebase 訂單同步**
- **自動推播通知**

### 4. 聯絡與服務
- 一鍵撥打訂購專線
- 地址導航功能
- 線上客服諮詢
- 常見問題解答

### 5. 用戶中心
- 訂單歷史記錄
- 收藏的作品
- 個人資訊設定

### 6. 🔔 推播通知系統
- **即時訂單通知**: 新訂單自動通知商家
- **訂單狀態更新**: 訂單狀態變更時推送通知
- **Firebase Cloud Functions**: 自動化推播流程
- **多平台支援**: 支援 iOS 推播通知服務 (APNs)

## 技術架構

### 開發環境
- iOS 17.0+
- Swift 5.9+
- SwiftUI 框架
- SwiftData 本地數據存儲
- **Firebase SDK 11.14.0+**
- **Firebase Cloud Functions (Node.js 20)**

### Firebase 服務
- **Firebase Core**: 核心 SDK
- **Firebase Firestore**: 雲端數據庫
- **Firebase Cloud Messaging**: 推播通知
- **Firebase Cloud Functions**: 伺服器端邏輯

### 主要組件
- **FlowerStudioApp**: 應用程式入口
- **ContentView**: 主要內容視圖
- **Models**: 數據模型層
  - FlowerProduct: 花藝作品模型
  - Order: 訂單模型
  - StudioInfo: 工作室資訊模型
  - CartItem: 購物車項目模型

### 視圖架構
- **HomeView**: 首頁視圖
- **ProductListView**: 作品列表視圖
- **ProductDetailView**: 作品詳情視圖
- **CartView**: 購物車視圖
- **OrderListView**: 訂單列表視圖
- **ContactView**: 聯絡視圖

### 🔥 Firebase 架構
- **Cloud Functions**:
  - `sendOrderNotification`: 新訂單自動推播
  - `sendOrderStatusUpdate`: 狀態更新推播
  - `testPushNotification`: 測試推播功能
- **Firestore Collections**:
  - `orders`: 訂單資料
  - `products`: 產品資料
- **FCM Topics**:
  - `merchant_notifications`: 商家通知主題

## 設計特色
- 溫馨優雅的色彩搭配（粉色系列）
- 符合Apple人機介面指南的設計
- 響應式布局，適配所有iOS設備
- 直觀的用戶體驗設計
- **完整的顏色資源管理**（支援深色模式）

## 安裝和運行

### 基本安裝
1. 使用Xcode打開專案文件
2. 確保iOS部署目標設為17.0或更高版本
3. 在真實設備上運行（推播通知需要真實設備）

### Firebase 設定
1. 確保 `GoogleService-Info.plist` 已正確放置在專案中
2. Firebase 專案已設定 APNs 憑證
3. Bundle ID 設定為 `com.flowerstudio.app`

### 推播通知測試
⚠️ **重要**: 推播通知功能僅在真實 iOS 設備上有效，模擬器不支援 APNs。

請參考 `PUSH_NOTIFICATION_TESTING.md` 了解完整的測試流程。

## 開發進度
- [x] 專案初始化
- [x] UI設計實現
- [x] 數據模型設計
- [x] 核心功能邏輯實現
  - [x] 首頁展示
  - [x] 花藝作品瀏覽和搜索
  - [x] 產品詳情頁面
  - [x] 購物車功能
  - [x] 聯絡我們頁面
  - [x] 訂單管理系統
- [x] Firebase 整合
- [x] 推播通知系統
- [x] Cloud Functions 部署
- [x] 示例數據初始化
- [x] Bundle ID 統一修正
- [x] 顏色資源修正
- [x] 完整測試文檔

## 已實現功能

### 🏠 首頁
- ✅ 工作室品牌展示
- ✅ 精選花藝作品輪播
- ✅ 營業狀態顯示
- ✅ 快速聯絡按鈕
- ✅ 一鍵撥號和地圖導航

### 🌸 花藝作品
- ✅ 分類瀏覽（7個分類）
- ✅ 搜索功能
- ✅ 篩選系統
- ✅ 產品詳情頁面
- ✅ 價格和製作時間顯示
- ✅ 客製化標示

### 🛒 購物車系統
- ✅ 商品加入購物車
- ✅ 數量調整
- ✅ 訂單結算
- ✅ 客戶資訊填寫
- ✅ 配送方式選擇

### 📱 聯絡功能
- ✅ 一鍵撥打訂購專線 (0920663393)
- ✅ 地圖導航到店面
- ✅ 營業時間顯示
- ✅ 服務說明

### 📦 訂單管理
- ✅ 訂單列表顯示
- ✅ 訂單狀態篩選
- ✅ 訂單詳細資訊
- ✅ 空狀態處理
- ✅ Firebase 訂單同步

### 🔔 推播通知
- ✅ Firebase Cloud Messaging 整合
- ✅ APNs 設定完成
- ✅ 自動推播通知 (新訂單)
- ✅ Cloud Functions 部署
- ✅ 商家通知主題訂閱
- ✅ 推播通知權限管理

## 最新修正 (2025/06/21)
- ✅ **Bundle ID 統一**: 修正 `com.iosapp.FlowerStudio` → `com.flowerstudio.app`
- ✅ **顏色資源修正**: 新增所有缺失的顏色資源 (green, yellow, pink, brown, red, orange)
- ✅ **Firebase 整合完成**: Cloud Functions 成功部署並運作
- ✅ **推播通知修正**: 修正 JSON 格式錯誤，推播通知正常運作
- ✅ **測試文檔**: 建立完整的推播通知測試指南

## 技術特色
- 🎨 精美的粉色系主題設計
- 📱 適配所有iOS設備的響應式布局
- 🗄️ SwiftData本地數據存儲
- 🔥 Firebase 雲端服務整合
- 🔔 即時推播通知系統
- 🔍 智能搜索和篩選
- 📍 集成地圖和導航功能
- ☎️ 一鍵撥號功能
- 🎯 符合Apple設計規範
- 🌙 深色模式支援

## 部署資訊
- **Apple Developer Team**: 5SM27L37HZ
- **APNs Key ID**: 28FW72D5N8
- **Firebase Project**: flowerstudio-531e8
- **Cloud Functions Region**: us-central1
- **Minimum iOS Version**: 17.0

## 檔案結構
```
FlowerStudio/
├── FlowerStudio/
│   ├── Models/           # 數據模型
│   ├── Views/            # UI 視圖
│   ├── Assets.xcassets/  # 資源文件
│   └── GoogleService-Info.plist
├── cloud_functions/      # Firebase Cloud Functions
├── PUSH_NOTIFICATION_TESTING.md
├── CLOUD_FUNCTIONS_SETUP.md
└── README.md
```

## 聯絡開發者
如有任何問題或建議，請隨時聯絡。

---

**最後更新**: 2025年6月21日  
**版本**: 1.0  
**狀態**: ✅ 生產就緒 