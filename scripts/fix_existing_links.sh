#!/bin/bash

#################################################################
# Fix Broken Links in Existing Mirror
# 
# 既存のミラーサイト内の壊れたリンクを修正します
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

# 壊れたリンクの修正
fix_broken_links() {
    log_info "壊れたリンクを修正中..."
    
    local fixed_count=0
    
    # index.html?p=XXX 形式のリンクを修正
    find "$OUTPUT_DIR" -name "*.html" -type f | while read -r file; do
        # 一時ファイルを作成
        temp_file="${file}.tmp"
        
        # sedで問題のあるパターンを修正
        # index.html?p=XXX を index.html に変換
        sed 's|index\.html?p=[0-9]*|index.html|g' "$file" > "$temp_file"
        
        # index.html%3Fp=XXX を index.html に変換
        sed -i '' 's|index\.html%3Fp=[0-9]*|index.html|g' "$temp_file"
        
        # 変更があった場合のみファイルを更新
        if ! cmp -s "$file" "$temp_file"; then
            mv "$temp_file" "$file"
            echo "  修正: $(basename "$file")"
            ((fixed_count++))
        else
            rm "$temp_file"
        fi
    done
    
    # ?p=XXX.html 形式のファイルが存在する場合は削除
    local deleted_files=$(find "$OUTPUT_DIR" -name "*\?p=*.html" -type f 2>/dev/null | wc -l)
    find "$OUTPUT_DIR" -name "*\?p=*.html" -type f -delete 2>/dev/null || true
    
    deleted_files=$((deleted_files + $(find "$OUTPUT_DIR" -name "*%3Fp=*.html" -type f 2>/dev/null | wc -l)))
    find "$OUTPUT_DIR" -name "*%3Fp=*.html" -type f -delete 2>/dev/null || true
    
    log_info "リンク修正完了"
    log_info "修正されたファイル数: $fixed_count"
    log_info "削除された不要ファイル数: $deleted_files"
}

# 統計情報の表示
show_statistics() {
    log_info "処理前の統計:"
    
    # 問題のあるリンクをカウント
    local broken_links=$(grep -r 'href="[^"]*index\.html[?%]' "$OUTPUT_DIR" 2>/dev/null | wc -l || echo "0")
    echo "  問題のあるリンク数: $broken_links"
    
    # ?p= を含むファイル数
    local files_with_qp=$(find "$OUTPUT_DIR" -name "*.html" -exec grep -l '?p=' {} \; 2>/dev/null | wc -l || echo "0")
    echo "  ?p=を含むファイル数: $files_with_qp"
}

# メイン処理
main() {
    log_info "=== Fix Broken Links Script ==="
    log_info "対象ディレクトリ: $OUTPUT_DIR"
    echo ""
    
    # ディレクトリの存在確認
    if [ ! -d "$OUTPUT_DIR" ]; then
        log_error "ディレクトリが存在しません: $OUTPUT_DIR"
        exit 1
    fi
    
    # 統計情報表示
    show_statistics
    echo ""
    
    # 修正実行
    fix_broken_links
    
    echo ""
    log_info "✅ 修正完了！"
    log_info "次のステップ:"
    echo "  1. ローカルテスト: cd $OUTPUT_DIR && python3 -m http.server 8000"
    echo "  2. デプロイ: npx wrangler pages deploy $OUTPUT_DIR --project-name=hides-blog-static"
}

# 実行
main