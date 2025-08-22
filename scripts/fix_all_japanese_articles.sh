#!/bin/bash

# 全ての日本語記事を修正するスクリプト

BASE_DIR="simple_mirror/blog"
FIXED_COUNT=0
ERROR_COUNT=0
TOTAL_COUNT=0

echo "日本語記事の修正を開始します..."
echo ""

# 総数を取得
TOTAL=$(find "$BASE_DIR" -type d -name "*.html" | wc -l)
echo "修正対象: ${TOTAL} ファイル"
echo ""

# .htmlで終わるディレクトリを検索して処理
find "$BASE_DIR" -type d -name "*.html" | while read -r dir_path; do
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    
    # 相対URLパスを構築（simple_mirror/を除いた部分）
    relative_path="${dir_path#simple_mirror/}"
    
    # 完全URLを構築
    full_url="https://hidemiyoshi.jp/${relative_path}"
    
    # 進捗表示
    echo -n "[$TOTAL_COUNT/$TOTAL] ${relative_path} ... "
    
    # ページをダウンロード
    if wget -q -O "${dir_path}.tmp" \
            --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
            --timeout=30 \
            --tries=2 \
            "$full_url" 2>/dev/null; then
        
        # ダウンロードしたファイルのサイズを確認
        file_size=$(stat -f%z "${dir_path}.tmp" 2>/dev/null || stat -c%s "${dir_path}.tmp" 2>/dev/null)
        
        if [ "$file_size" -gt 1000 ]; then
            # 実際のHTMLファイル名（ディレクトリ名から末尾の/を除く）
            actual_html_file="${dir_path%/}"
            
            # 既存のディレクトリを削除
            rm -rf "$dir_path"
            # ファイルを正しい名前で配置
            mv "${dir_path}.tmp" "$actual_html_file"
            echo "✓"
            FIXED_COUNT=$((FIXED_COUNT + 1))
        else
            rm -f "${dir_path}.tmp"
            echo "✗ (empty file)"
            ERROR_COUNT=$((ERROR_COUNT + 1))
        fi
    else
        rm -f "${dir_path}.tmp"
        echo "✗ (download failed)"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
    
    # 10件ごとに進捗をサマリー表示
    if [ $((TOTAL_COUNT % 10)) -eq 0 ]; then
        echo "  進捗: $TOTAL_COUNT/$TOTAL (成功: $FIXED_COUNT, 失敗: $ERROR_COUNT)"
    fi
    
    # サーバー負荷軽減のため少し待つ
    sleep 0.3
done

echo ""
echo "========================================="
echo "修正完了:"
echo "  成功: ${FIXED_COUNT} ファイル"
echo "  失敗: ${ERROR_COUNT} ファイル"
echo ""
echo "修正後のHTMLファイル総数:"
find "$BASE_DIR" -type f -name "*.html" | wc -l
echo "========================================="