#!/bin/bash

# 多语言验证脚本 / Localization Validation Script
# 用于检查所有语言文件中的键是否一致

echo "🌍 开始验证多语言文件 / Starting localization validation..."
echo ""

# 定义语言文件路径
ZH_FILE="subscription-tracker/Resources/zh-Hans.lproj/Localizable.strings"
EN_FILE="subscription-tracker/Resources/en.lproj/Localizable.strings"
JA_FILE="subscription-tracker/Resources/ja.lproj/Localizable.strings"

# 检查文件是否存在
if [ ! -f "$ZH_FILE" ]; then
    echo "❌ 错误: 找不到中文文件 $ZH_FILE"
    exit 1
fi

if [ ! -f "$EN_FILE" ]; then
    echo "❌ 错误: 找不到英文文件 $EN_FILE"
    exit 1
fi

if [ ! -f "$JA_FILE" ]; then
    echo "❌ 错误: 找不到日文文件 $JA_FILE"
    exit 1
fi

echo "✅ 所有语言文件都存在"
echo ""

# 提取所有键（忽略注释和空行）
extract_keys() {
    grep -E '^"[^"]+"\s*=' "$1" | sed 's/^\"\([^\"]*\)\".*/\1/' | sort
}

echo "📊 提取所有键..."
ZH_KEYS=$(extract_keys "$ZH_FILE")
EN_KEYS=$(extract_keys "$EN_FILE")
JA_KEYS=$(extract_keys "$JA_FILE")

ZH_COUNT=$(echo "$ZH_KEYS" | wc -l | tr -d ' ')
EN_COUNT=$(echo "$EN_KEYS" | wc -l | tr -d ' ')
JA_COUNT=$(echo "$JA_KEYS" | wc -l | tr -d ' ')

echo "  中文键数量: $ZH_COUNT"
echo "  英文键数量: $EN_COUNT"
echo "  日文键数量: $JA_COUNT"
echo ""

# 检查键数量是否一致
if [ "$ZH_COUNT" != "$EN_COUNT" ] || [ "$ZH_COUNT" != "$JA_COUNT" ]; then
    echo "⚠️  警告: 键数量不一致！"
    echo ""
fi

# 查找缺失的键
echo "🔍 检查缺失的键..."
echo ""

# 检查英文文件中缺失的键
MISSING_IN_EN=$(comm -23 <(echo "$ZH_KEYS") <(echo "$EN_KEYS"))
if [ -n "$MISSING_IN_EN" ]; then
    echo "❌ 英文文件中缺失的键:"
    echo "$MISSING_IN_EN"
    echo ""
else
    echo "✅ 英文文件包含所有键"
fi

# 检查日文文件中缺失的键
MISSING_IN_JA=$(comm -23 <(echo "$ZH_KEYS") <(echo "$JA_KEYS"))
if [ -n "$MISSING_IN_JA" ]; then
    echo "❌ 日文文件中缺失的键:"
    echo "$MISSING_IN_JA"
    echo ""
else
    echo "✅ 日文文件包含所有键"
fi

# 检查中文文件中缺失的键（相对于英文）
MISSING_IN_ZH=$(comm -23 <(echo "$EN_KEYS") <(echo "$ZH_KEYS"))
if [ -n "$MISSING_IN_ZH" ]; then
    echo "❌ 中文文件中缺失的键:"
    echo "$MISSING_IN_ZH"
    echo ""
else
    echo "✅ 中文文件包含所有键"
fi

# 检查重复的键
echo "🔍 检查重复的键..."
echo ""

check_duplicates() {
    local file=$1
    local lang=$2
    local duplicates=$(extract_keys "$file" | uniq -d)
    
    if [ -n "$duplicates" ]; then
        echo "❌ $lang 文件中有重复的键:"
        echo "$duplicates"
        echo ""
        return 1
    else
        echo "✅ $lang 文件没有重复的键"
        return 0
    fi
}

check_duplicates "$ZH_FILE" "中文"
check_duplicates "$EN_FILE" "英文"
check_duplicates "$JA_FILE" "日文"

echo ""
echo "✨ 验证完成！"
