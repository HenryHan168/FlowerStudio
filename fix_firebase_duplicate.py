#!/usr/bin/env python3
import re

# 讀取專案檔案
with open('FlowerStudio.xcodeproj/project.pbxproj', 'r') as file:
    content = file.read()

# 移除重複的 Firebase 參考（保留 A66D3B7x 系列，移除 A661FCx 系列）
patterns_to_remove = [
    r'.*A661FCA02E00699700176DF0.*\n',
    r'.*A661FCA22E00699700176DF0.*\n', 
    r'.*A661FCA42E00699700176DF0.*\n',
    r'.*A661FC9F2E00699700176DF0.*\n',
    r'.*A661FCA12E00699700176DF0.*\n',
    r'.*A661FCA32E00699700176DF0.*\n'
]

for pattern in patterns_to_remove:
    content = re.sub(pattern, '', content)

# 寫入修復後的檔案
with open('FlowerStudio.xcodeproj/project.pbxproj', 'w') as file:
    file.write(content)

print("✅ Firebase 重複參考已清理完成") 