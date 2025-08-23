#!/bin/bash

#################################################################
# Decode URL-Encoded Filenames to Japanese
# 
# URLエンコードされたファイル名を日本語に戻します
# これによりブラウザからのアクセスが正常に動作します
#################################################################

set -e

# 設定
OUTPUT_DIR="simple_mirror"

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# URLエンコードされたファイル名をデコード
decode_filenames() {
    log_info "URLエンコードされたファイル名を日本語に変換中..."
    
    local decoded_count=0
    local error_count=0
    
    # %を含むHTMLファイルを検索
    find "$OUTPUT_DIR" -name "*%*.html" -type f | while read -r file; do
        dir=$(dirname "$file")
        filename=$(basename "$file")
        
        # Pythonを使ってURLデコード
        decoded_filename=$(python3 -c "
import urllib.parse
import sys
try:
    print(urllib.parse.unquote('$filename'))
except:
    print('$filename')
")
        
        if [ "$filename" != "$decoded_filename" ]; then
            # ファイル名を変更
            new_path="$dir/$decoded_filename"
            
            # 既存ファイルがないか確認
            if [ -f "$new_path" ]; then
                log_warn "既存ファイル: $decoded_filename (スキップ)"
            else
                mv "$file" "$new_path"
                echo "  変換: $filename → $decoded_filename"
                ((decoded_count++))
            fi
        fi
    done
    
    log_info "ファイル名変換完了"
    log_info "変換されたファイル数: $decoded_count"
}

# HTMLファイル内のリンクも更新
update_html_links() {
    log_info "HTML内のURLエンコードされたリンクを更新中..."
    
    python3 << 'EOF'
import os
import re
import urllib.parse
from pathlib import Path

output_dir = "simple_mirror"
updated_count = 0

# すべてのHTMLファイルを処理
for html_file in Path(output_dir).rglob("*.html"):
    with open(html_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # href="...%XX...html" パターンを検出して修正
    def decode_link(match):
        full_match = match.group(0)
        link = match.group(1)
        
        # %を含むリンクのみ処理
        if '%' in link:
            try:
                # URLデコード
                decoded_link = urllib.parse.unquote(link)
                return f'href="{decoded_link}"'
            except:
                return full_match
        return full_match
    
    # パターンマッチング - href内のパスを取得
    pattern = r'href="([^"]*%[^"]*\.html)"'
    content = re.sub(pattern, decode_link, content)
    
    # src属性も同様に処理
    pattern = r'src="([^"]*%[^"]*)"'
    content = re.sub(pattern, lambda m: f'src="{urllib.parse.unquote(m.group(1))}"' if '%' in m.group(1) else m.group(0), content)
    
    # 変更があった場合のみ書き込み
    if content != original_content:
        with open(html_file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  更新: {html_file.name}")
        updated_count += 1

print(f"更新されたHTMLファイル数: {updated_count}")
EOF
    
    log_info "リンク更新完了"
}

# 統計情報の表示
show_statistics() {
    log_info "処理統計:"
    
    # URLエンコードされたファイルの数
    encoded_files=$(find "$OUTPUT_DIR" -name "*%*.html" -type f 2>/dev/null | wc -l || echo "0")
    echo "  残りのエンコードファイル: $encoded_files"
    
    # 日本語ファイル名の数
    japanese_files=$(find "$OUTPUT_DIR" -name "*.html" -type f -exec basename {} \; | grep -c '[ぁ-んァ-ヶー一-龠]' || echo "0")
    echo "  日本語ファイル名: $japanese_files"
    
    total_html=$(find "$OUTPUT_DIR" -name "*.html" -type f | wc -l)
    echo "  総HTMLファイル数: $total_html"
}

# メイン処理
main() {
    log_info "=== Decode URL-Encoded Filenames Script ==="
    log_info "対象ディレクトリ: $OUTPUT_DIR"
    echo ""
    
    # ディレクトリの存在確認
    if [ ! -d "$OUTPUT_DIR" ]; then
        log_error "ディレクトリが存在しません: $OUTPUT_DIR"
        exit 1
    fi
    
    # 処理前の統計
    log_info "処理前の状態:"
    show_statistics
    echo ""
    
    # ファイル名のデコード
    decode_filenames
    echo ""
    
    # HTML内のリンク更新
    update_html_links
    echo ""
    
    # 処理後の統計
    log_info "処理後の状態:"
    show_statistics
    
    echo ""
    log_info "✅ 変換完了！"
    log_info "次のステップ:"
    echo "  1. ローカルテスト: cd $OUTPUT_DIR && python3 -m http.server 8000"
    echo "  2. デプロイ: npx wrangler pages deploy $OUTPUT_DIR --project-name=hides-blog-static"
}

# 実行
main