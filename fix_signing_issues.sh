#!/bin/bash

echo "🔧 修復 iOS 簽名問題腳本"
echo "================================"

# 1. 清理 Xcode 快取
echo "📱 清理 Xcode 快取..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*

# 2. 清理配置檔案快取
echo "🗑️ 清理配置檔案快取..."
rm -rf ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/*

# 3. 清理專案建置快取
echo "🧹 清理專案建置快取..."
cd "$(dirname "$0")"
rm -rf build/
rm -rf FlowerStudio.xcodeproj/project.xcworkspace/xcuserdata/
rm -rf FlowerStudio.xcodeproj/xcuserdata/

# 4. 重置 Git 快取 (如果需要)
echo "🔄 重置 Git 快取..."
git rm -r --cached . 2>/dev/null || true
git add .

echo "✅ 清理完成！"
echo ""
echo "🚀 接下來請按照以下步驟操作："
echo "1. 打開 Xcode"
echo "2. 前往 Xcode > Settings > Accounts"
echo "3. 確認已正確登入 Apple ID"
echo "4. 在專案設定中選擇正確的開發者團隊"
echo "5. 將程式碼簽名設為 'Automatic'"
echo "6. 重新建置專案" 