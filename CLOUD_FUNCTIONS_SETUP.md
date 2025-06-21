# 🚀 Firebase Cloud Functions 自動推播設定指南

## 📋 功能說明

Cloud Functions 將實現以下**自動推播功能**：

### ✅ **已實現的自動功能：**
1. **新訂單自動推播** 🔔
   - 當客戶下訂單 → Firestore 新增訂單 → **自動觸發推播**
   - 商家立即收到新訂單通知

2. **訂單狀態更新推播** 📱
   - 當商家更新訂單狀態 → **自動通知客戶**
   - 客戶即時了解訂單進度

3. **測試推播功能** 🧪
   - 可手動測試推播系統是否正常運作

## 🛠 **設定步驟**

### **第一步：安裝 Firebase CLI**

```bash
# 安裝 Firebase CLI
npm install -g firebase-tools

# 登入 Firebase
firebase login

# 初始化專案（在 FlowerStudio 根目錄執行）
cd /Users/night/Desktop/FlowerStudio/FlowerStudio
firebase init
```

選擇以下選項：
- ✅ Functions: Configure a Cloud Functions directory
- ✅ Firestore: Configure security rules and indexes files

### **第二步：設定專案資訊**
```bash
# 選擇現有的 Firebase 專案
? Please select an option: Use an existing project
? Select a default Firebase project: flowerstudio-531e8

# Functions 設定
? What language would you like to use to write Cloud Functions? JavaScript
? Do you want to use ESLint? No
? Do you want to install dependencies now? Yes
```

### **第三步：部署 Cloud Functions**

```bash
# 進入 cloud_functions 目錄
cd cloud_functions

# 安裝依賴
npm install

# 回到根目錄並部署
cd ..
firebase deploy --only functions
```

### **第四步：更新 Firestore 規則**

```bash
# 部署 Firestore 規則
firebase deploy --only firestore:rules
```

## 🎯 **工作原理**

### **1. 新訂單自動推播流程：**

```
客戶下訂單 
    ↓
iOS App 上傳到 Firestore 
    ↓
Cloud Function 自動觸發 
    ↓
發送推播給商家 ✅
```

### **2. 關鍵 Cloud Function：**

```javascript
// 監聽新訂單並自動發送推播
exports.sendOrderNotification = functions.firestore
    .document('orders/{orderId}')
    .onCreate(async (snap, context) => {
        // 當 Firestore 有新訂單時自動執行
        // 發送推播通知給 'merchant_notifications' 主題
    });
```

### **3. 推播內容：**
- 標題：🌸 新訂單通知
- 內容：客戶姓名、訂單號、金額
- 目標：訂閱 `merchant_notifications` 主題的設備

## 📱 **iOS App 端設定**

確認 iOS App 已正確訂閱推播主題：

```swift
// 在 FirebaseManager.swift 中已設定
Messaging.messaging().subscribe(toTopic: "merchant_notifications")
```

## 🧪 **測試自動推播**

### **方法一：完整訂單流程測試**
1. 在 iOS 模擬器中下訂單
2. 檢查 Firebase Console → Functions 日誌
3. 應該看到 Cloud Function 執行記錄

### **方法二：手動測試推播**
在 Firebase Console → Functions 中執行：

```javascript
// 在 Firebase Console 中測試
firebase.functions().httpsCallable('testPushNotification')({})
```

### **方法三：Firebase Console 測試**
1. Firebase Console → Cloud Messaging
2. 發送測試訊息到主題：`merchant_notifications`

## 📊 **監控和日誌**

### **查看 Cloud Functions 執行日誌：**

```bash
# 即時查看日誌
firebase functions:log

# 查看特定函數日誌
firebase functions:log --only sendOrderNotification
```

### **Firebase Console 監控：**
- Functions → 查看執行次數和錯誤
- Cloud Messaging → 查看推播統計

## 🔧 **故障排除**

### **常見問題：**

**❌ Cloud Function 部署失敗**
```bash
# 檢查 Node.js 版本
node --version  # 需要 18.x

# 重新安裝依賴
cd cloud_functions
rm -rf node_modules
npm install
```

**❌ 推播未收到**
1. 檢查 iOS 設備是否訂閱了主題
2. 確認 APNs 設定正確
3. 查看 Cloud Functions 日誌是否有錯誤

**❌ Firestore 權限錯誤**
```bash
# 更新 Firestore 規則
firebase deploy --only firestore:rules
```

## 🎉 **成功驗證**

當設定完成後，您應該看到：

### **iOS App Console：**
```
✅ 已訂閱商家通知主題
✅ 訂單已成功上傳到 Firestore
```

### **Firebase Functions 日誌：**
```
🔔 新訂單觸發推播: [orderId]
✅ 推播通知發送成功: [messageId]
```

### **推播通知：**
- 標題：🌸 新訂單通知
- 內容：客戶 XXX 下了新訂單...

## 💡 **進階功能**

Cloud Functions 還支援：

1. **訂單狀態更新推播** 📦
   - 商家更新狀態 → 自動通知客戶

2. **個人化推播** 👤
   - 根據客戶電話號碼發送專屬通知

3. **推播統計** 📈
   - 追蹤推播開啟率和互動率

## 🎯 **總結**

通過 Cloud Functions，您的花藝工作室現在具備：

- ✅ **完全自動化** 的推播通知系統
- ✅ **即時響應** 新訂單
- ✅ **無需手動干預** 的通知流程
- ✅ **可擴展** 的通知功能

**不再需要手動測試推播！** 🎉

---

*設定完成後，每次有新訂單都會自動發送推播通知給商家！* 