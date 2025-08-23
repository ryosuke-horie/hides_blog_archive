#!/bin/bash

#################################################################
# Fix HTML Links to Match URL-Encoded Filenames
# 
# index.html内の日本語リンクをURLエンコードされた
# 実際のファイル名に合わせて修正します
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

# URLエンコード関数
urlencode() {
    python3 -c "import urllib.parse; print(urllib.parse.quote('$1', safe=''))"
}

# HTMLファイル内のリンクを修正
fix_html_links() {
    log_info "HTMLファイル内のリンクを修正中..."
    
    local fixed_count=0
    
    # すべてのHTMLファイルを処理
    find "$OUTPUT_DIR" -name "*.html" -type f | while read -r file; do
        local temp_file="${file}.tmp"
        local changed=false
        
        # ファイルを一行ずつ処理
        while IFS= read -r line; do
            # href="...日本語...html" パターンを検出
            if echo "$line" | grep -q 'href="[^"]*[^\x00-\x7F][^"]*\.html"'; then
                # 日本語を含むリンクを抽出して処理
                modified_line="$line"
                
                # すべてのhref内の日本語ファイル名をURLエンコード
                while [[ "$modified_line" =~ href=\"([^\"]*/)([^/\"]+)\.html\" ]]; do
                    path="${BASH_REMATCH[1]}"
                    filename="${BASH_REMATCH[2]}"
                    
                    # ファイル名に日本語が含まれているかチェック
                    if echo "$filename" | LC_ALL=C grep -q '[^ -~]'; then
                        # URLエンコード
                        encoded_filename=$(urlencode "$filename")
                        # 置換
                        old_link="href=\"${path}${filename}.html\""
                        new_link="href=\"${path}${encoded_filename}.html\""
                        modified_line="${modified_line//$old_link/$new_link}"
                        changed=true
                    fi
                done
                
                echo "$modified_line"
            else
                echo "$line"
            fi
        done < "$file" > "$temp_file"
        
        # 変更があった場合のみファイルを更新
        if [ "$changed" = true ]; then
            mv "$temp_file" "$file"
            echo "  修正: $(basename "$file")"
            ((fixed_count++))
        else
            rm -f "$temp_file"
        fi
    done
    
    log_info "リンク修正完了"
    log_info "修正されたファイル数: $fixed_count"
}

# Python3で一括処理（より確実）
fix_html_links_python() {
    log_info "Python3を使用してHTMLリンクを修正中..."
    
    python3 << 'EOF'
import os
import re
import urllib.parse
from pathlib import Path

output_dir = "simple_mirror"
fixed_count = 0

# すべてのHTMLファイルを処理
for html_file in Path(output_dir).rglob("*.html"):
    with open(html_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # href="...日本語...html" パターンを検出して修正
    def replace_japanese_link(match):
        full_match = match.group(0)
        path = match.group(1) if match.group(1) else ""
        filename = match.group(2)
        
        # 日本語が含まれているかチェック
        if any(ord(c) > 127 for c in filename):
            # URLエンコード
            encoded_filename = urllib.parse.quote(filename, safe='')
            return f'href="{path}{encoded_filename}.html"'
        return full_match
    
    # パターンマッチング
    pattern = r'href="([^"]*?)([^"/]+)\.html"'
    content = re.sub(pattern, replace_japanese_link, content)
    
    # 変更があった場合のみ書き込み
    if content != original_content:
        with open(html_file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  修正: {html_file.name}")
        fixed_count += 1

print(f"修正されたファイル数: {fixed_count}")
EOF
    
    log_info "リンク修正完了"
}

# メイン処理
main() {
    log_info "=== Fix HTML Links Script ==="
    log_info "対象ディレクトリ: $OUTPUT_DIR"
    echo ""
    
    # ディレクトリの存在確認
    if [ ! -d "$OUTPUT_DIR" ]; then
        log_error "ディレクトリが存在しません: $OUTPUT_DIR"
        exit 1
    fi
    
    # Python3を使用して修正
    fix_html_links_python
    
    echo ""
    log_info "✅ 修正完了！"
    log_info "次のステップ:"
    echo "  1. ローカルテスト: cd $OUTPUT_DIR && python3 -m http.server 8000"
    echo "  2. デプロイ: npx wrangler pages deploy $OUTPUT_DIR --project-name=hides-blog-static"
}

# 実行
main