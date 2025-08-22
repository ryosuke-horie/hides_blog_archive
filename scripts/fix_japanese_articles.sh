#!/bin/bash

# 日本語記事の修正スクリプト
# 誤ってディレクトリとして作成された.htmlディレクトリを実際のHTMLファイルに変換

BASE_DIR="simple_mirror/blog"
FIXED_COUNT=0
ERROR_COUNT=0

echo "日本語記事の修正を開始します..."

# .htmlで終わるディレクトリを検索
find "$BASE_DIR" -type d -name "*.html" | while read -r dir_path; do
    # ディレクトリ名からHTMLファイル名を作成
    html_file="${dir_path%.html/}.html"
    
    # 相対URLパスを構築（simple_mirror/blog/を除いた部分）
    relative_path="${dir_path#simple_mirror/}"
    relative_path="${relative_path%.html/}.html"
    
    # 完全URLを構築
    full_url="https://hidemiyoshi.jp/${relative_path}"
    
    echo "処理中: ${relative_path}"
    
    # ページをダウンロード
    if wget -q -O "${html_file}.tmp" \
            --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
            --timeout=30 \
            --tries=2 \
            "$full_url" 2>/dev/null; then
        
        # ダウンロード成功したら既存のディレクトリを削除してファイルを配置
        if [ -s "${html_file}.tmp" ]; then
            rm -rf "$dir_path"
            mv "${html_file}.tmp" "$html_file"
            echo "  ✓ 修正完了: ${html_file}"
            ((FIXED_COUNT++))
        else
            rm -f "${html_file}.tmp"
            echo "  ✗ 空のファイル: ${relative_path}"
            ((ERROR_COUNT++))
        fi
    else
        rm -f "${html_file}.tmp"
        echo "  ✗ ダウンロード失敗: ${relative_path}"
        ((ERROR_COUNT++))
    fi
    
    # サーバー負荷軽減のため少し待つ
    sleep 0.5
done

echo ""
echo "修正完了:"
echo "  成功: ${FIXED_COUNT} ファイル"
echo "  失敗: ${ERROR_COUNT} ファイル"
echo ""
echo "修正後のファイル数:"
find "$BASE_DIR" -type f -name "*.html" | wc -l