const functions = require('firebase-functions');
const admin = require('firebase-admin');

// 初始化 Firebase Admin SDK
admin.initializeApp();

// 監聽新訂單並自動發送推播通知
exports.sendOrderNotification = functions.firestore
    .document('orders/{orderId}')
    .onCreate(async (snap, context) => {
        try {
            const orderData = snap.data();
            const orderId = context.params.orderId;
            
            console.log(`🔔 新訂單觸發推播: ${orderId}`);
            
            // 構建推播通知內容
            const message = {
                topic: 'merchant_notifications', // 商家訂閱的主題
                notification: {
                    title: '🌸 新訂單通知',
                    body: `客戶 ${orderData.customerName} 下了新訂單\n訂單號：${orderData.orderNumber}\n金額：NT$ ${orderData.totalAmount}`,
                    sound: 'default'
                },
                data: {
                    orderId: orderId,
                    orderNumber: orderData.orderNumber,
                    customerName: orderData.customerName,
                    totalAmount: orderData.totalAmount.toString(),
                    type: 'new_order'
                },
                apns: {
                    payload: {
                        aps: {
                            alert: {
                                title: '🌸 新訂單通知',
                                body: `客戶 ${orderData.customerName} 下了新訂單\n訂單號：${orderData.orderNumber}\n金額：NT$ ${orderData.totalAmount}`
                            },
                            sound: 'default',
                            badge: 1
                        }
                    }
                }
            };
            
            // 發送推播通知
            const response = await admin.messaging().send(message);
            console.log('✅ 推播通知發送成功:', response);
            
            return { success: true, messageId: response };
            
        } catch (error) {
            console.error('❌ 推播通知發送失敗:', error);
            return { success: false, error: error.message };
        }
    });

// 手動測試推播功能（可選）
exports.testPushNotification = functions.https.onCall(async (data, context) => {
    try {
        const message = {
            topic: 'merchant_notifications',
            notification: {
                title: '🧪 測試推播',
                body: '這是一個測試推播通知',
                sound: 'default'
            }
        };
        
        const response = await admin.messaging().send(message);
        console.log('✅ 測試推播發送成功:', response);
        
        return { success: true, messageId: response };
        
    } catch (error) {
        console.error('❌ 測試推播發送失敗:', error);
        throw new functions.https.HttpsError('internal', '推播發送失敗', error);
    }
});

// 訂單狀態更新通知（可選擴展功能）
exports.sendOrderStatusUpdate = functions.firestore
    .document('orders/{orderId}')
    .onUpdate(async (change, context) => {
        try {
            const beforeData = change.before.data();
            const afterData = change.after.data();
            
            // 檢查訂單狀態是否有變更
            if (beforeData.orderStatus !== afterData.orderStatus) {
                const orderId = context.params.orderId;
                
                console.log(`📱 訂單狀態更新: ${orderId} -> ${afterData.orderStatus}`);
                
                // 構建狀態更新通知（發送給客戶）
                const message = {
                    topic: `customer_${afterData.customerPhone}`, // 客戶專屬主題
                    notification: {
                        title: '📦 訂單狀態更新',
                        body: `您的訂單 ${afterData.orderNumber} 狀態已更新為：${getStatusText(afterData.orderStatus)}`,
                        sound: 'default'
                    },
                    data: {
                        orderId: orderId,
                        orderNumber: afterData.orderNumber,
                        newStatus: afterData.orderStatus,
                        type: 'status_update'
                    }
                };
                
                const response = await admin.messaging().send(message);
                console.log('✅ 狀態更新通知發送成功:', response);
                
                return { success: true, messageId: response };
            }
            
            return { success: true, message: '狀態未變更，無需發送通知' };
            
        } catch (error) {
            console.error('❌ 狀態更新通知發送失敗:', error);
            return { success: false, error: error.message };
        }
    });

// 輔助函數：將訂單狀態轉換為中文
function getStatusText(status) {
    const statusMap = {
        'pending': '待處理',
        'confirmed': '已確認',
        'preparing': '準備中',
        'ready': '已完成',
        'delivering': '配送中',
        'completed': '已送達',
        'cancelled': '已取消'
    };
    
    return statusMap[status] || status;
} 