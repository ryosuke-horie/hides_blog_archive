#!/bin/bash

# テスト版：最初の5件だけ処理

BASE_DIR="simple_mirror/blog"
FIXED_COUNT=0
ERROR_COUNT=0

echo "日本語記事の修正テスト（最初の5件）..."

# .htmlで終わるディレクトリを検索（最初の5件のみ）
find "$BASE_DIR" -type d -name "*.html" | head -5 | while read -r dir_path; do
    # ディレクトリ名からHTMLファイル名を作成
    html_file="${dir_path}"
    
    # 相対URLパスを構築（simple_mirror/を除いた部分）
    relative_path="${dir_path#simple_mirror/}"
    
    # 完全URLを構築
    full_url="https://hidemiyoshi.jp/${relative_path}"
    
    echo "処理中: ${relative_path}"
    echo "  URL: ${full_url}"
    
    # ページをダウンロード
    if wget -q -O "${html_file}.tmp" \
            --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
            --timeout=30 \
            --tries=2 \
            "$full_url" 2>/dev/null; then
        
        # ダウンロードしたファイルのサイズを確認
        file_size=$(stat -f%z "${html_file}.tmp" 2>/dev/null || stat -c%s "${html_file}.tmp" 2>/dev/null)
        
        if [ "$file_size" -gt 1000 ]; then
            echo "  ✓ ダウンロード成功 (${file_size} bytes)"
            # 実際のHTMLファイル名（ディレクトリ名から.html/を除く、すでに.htmlが含まれている）
            actual_html_file="${dir_path%/}"
            
            # 既存のディレクトリを削除
            rm -rf "$dir_path"
            # ファイルを正しい名前で配置
            mv "${html_file}.tmp" "$actual_html_file"
            echo "  ✓ 修正完了: ${actual_html_file}"
            FIXED_COUNT=$((FIXED_COUNT + 1))
        else
            rm -f "${html_file}.tmp"
            echo "  ✗ ファイルが小さすぎます: ${file_size} bytes"
            ((ERROR_COUNT++))
        fi
    else
        rm -f "${html_file}.tmp"
        echo "  ✗ ダウンロード失敗"
        ((ERROR_COUNT++))
    fi
    
    # サーバー負荷軽減のため少し待つ
    sleep 0.5
done

echo ""
echo "テスト結果:"
echo "  成功: ${FIXED_COUNT} ファイル"
echo "  失敗: ${ERROR_COUNT} ファイル"