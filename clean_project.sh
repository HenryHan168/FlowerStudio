#!/bin/bash

# 備份原始檔案
cp FlowerStudio.xcodeproj/project.pbxproj FlowerStudio.xcodeproj/project.pbxproj.backup2

# 移除所有 Firebase 相關行
sed -i '' '/Firebase/d' FlowerStudio.xcodeproj/project.pbxproj

echo "✅ Firebase 參考已清理完成"
echo "📝 請重新在 Xcode 中加入 Firebase SDK" 