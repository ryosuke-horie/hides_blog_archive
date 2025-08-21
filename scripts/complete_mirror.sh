#!/bin/bash

#################################################################
# WordPress Blog Complete Mirror Script
# 
# 完全なWordPressブログのミラーリングを実行し、
# Cloudflare Pagesへのデプロイ準備を整えます
#################################################################

set -e

# 設定
SOURCE_URL="https://hidemiyoshi.jp/blog/"
OUTPUT_DIR="complete_mirror"
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"

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

# 既存ディレクトリのクリーンアップ
cleanup_existing() {
    log_info "既存のミラーディレクトリをクリーンアップ中..."
    if [ -d "$OUTPUT_DIR" ]; then
        rm -rf "$OUTPUT_DIR"
        log_info "既存ディレクトリを削除しました"
    fi
}

# ミラーリング実行
perform_mirror() {
    log_info "WordPressブログのミラーリングを開始..."
    
    wget \
        --mirror \
        --convert-links \
        --adjust-extension \
        --page-requisites \
        --no-parent \
        --directory-prefix="$OUTPUT_DIR" \
        --no-host-directories \
        --user-agent="$USER_AGENT" \
        --reject="wp-admin*,wp-login*,wp-json*,xmlrpc*,*?*replytocom*,*?*share*,*?*like*,*/comment-page-*,*/trackback*,*/feed*,*/wp-*,*?p=*,*?s=*,*?author=*,*?tag=*,*?cat=*,*?m=*,*?year=*,*?monthnum=*,*?day=*,*?paged=*" \
        --reject-regex=".*\?(replytocom|share|like|p|s|author|tag|cat|m|year|monthnum|day|paged)=.*" \
        --wait=0.5 \
        --random-wait \
        --limit-rate=200k \
        --tries=3 \
        --timeout=30 \
        "$SOURCE_URL" 2>&1 | while read line; do
            if [[ $line == *"Saving to:"* ]]; then
                echo -e "${GREEN}[DL]${NC} ${line#*Saving to: }"
            elif [[ $line == *"ERROR"* ]]; then
                echo -e "${RED}[ERROR]${NC} $line"
            fi
        done
    
    log_info "基本ミラーリング完了"
}

# ファイル名のURLエンコーディング修正
fix_filenames() {
    log_info "日本語ファイル名をURLエンコード形式に変換中..."
    
    find "$OUTPUT_DIR" -type f -name "*.html" | while read -r file; do
        dir=$(dirname "$file")
        filename=$(basename "$file")
        
        # 日本語が含まれているファイル名のみ処理
        if echo "$filename" | LC_ALL=C grep -q '[^ -~]'; then
            # URLエンコード
            encoded_filename=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$filename', safe='.-_'))")
            
            if [ "$filename" != "$encoded_filename" ]; then
                mv "$file" "$dir/$encoded_filename"
                echo "  変換: $filename → $encoded_filename"
            fi
        fi
    done
    
    log_info "ファイル名変換完了"
}

# 相対パスの修正
fix_relative_paths() {
    log_info "相対パスを修正中..."
    
    find "$OUTPUT_DIR" -name "*.html" -type f | while read -r file; do
        # ファイルのディレクトリ深さを計算
        rel_path="${file#$OUTPUT_DIR/}"
        depth=$(echo "$rel_path" | tr -cd '/' | wc -c)
        
        # 深さに応じて相対パスを生成
        prefix=""
        for ((i=0; i<depth; i++)); do
            prefix="../$prefix"
        done
        
        # ./で始まるパスを適切な相対パスに置換
        sed -i '' "s|href=['\"]\\./|href='${prefix}|g" "$file"
        sed -i '' "s|src=['\"]\\./|src='${prefix}|g" "$file"
    done
    
    log_info "相対パス修正完了"
}

# CSS/JSリンクの追加（不足している場合）
add_missing_resources() {
    log_info "不足しているCSS/JSリンクを追加中..."
    
    find "$OUTPUT_DIR" -name "*.html" -type f | while read -r file; do
        # index.htmlはスキップ
        if [[ $(basename "$file") == "index.html" ]]; then
            continue
        fi
        
        # ファイルのディレクトリ深さを計算
        rel_path="${file#$OUTPUT_DIR/}"
        depth=$(echo "$rel_path" | tr -cd '/' | wc -c)
        
        # 深さに応じて相対パスを生成
        prefix=""
        for ((i=0; i<depth; i++)); do
            prefix="../$prefix"
        done
        
        # すでにCSS/JSが追加されているかチェック
        if ! grep -q "wp-includes/css/dist/block-library/style.min.css" "$file"; then
            # titleタグの後にCSS/JSリンクを追加
            sed -i '' "/<\/title>/a\\
<link rel='stylesheet' href='${prefix}wp-includes/css/dist/block-library/style.min.css' type='text/css' media='all' />\\
<link rel='stylesheet' href='${prefix}wp-content/themes/colibri-wp/style.css' type='text/css' media='all' />\\
<script type='text/javascript' src='${prefix}wp-includes/js/jquery/jquery.min.js'></script>\\
<script type='text/javascript' src='${prefix}wp-includes/js/jquery/jquery-migrate.min.js'></script>
" "$file"
            echo "  リソース追加: $(basename "$file")"
        fi
    done
    
    log_info "CSS/JSリンク追加完了"
}

# 不要なファイルのクリーンアップ
cleanup_unnecessary() {
    log_info "不要なファイルをクリーンアップ中..."
    
    # WordPress管理ファイル等を削除
    find "$OUTPUT_DIR" -type f \( \
        -name "*.php" -o \
        -name "xmlrpc*" -o \
        -name "wp-config*" -o \
        -name "*.sql" -o \
        -name ".htaccess" \
    \) -delete
    
    # 空ディレクトリを削除
    find "$OUTPUT_DIR" -type d -empty -delete
    
    log_info "クリーンアップ完了"
}

# 統計情報の表示
show_statistics() {
    log_info "ミラーリング統計:"
    
    total_files=$(find "$OUTPUT_DIR" -type f | wc -l)
    html_files=$(find "$OUTPUT_DIR" -name "*.html" | wc -l)
    css_files=$(find "$OUTPUT_DIR" -name "*.css" | wc -l)
    js_files=$(find "$OUTPUT_DIR" -name "*.js" | wc -l)
    image_files=$(find "$OUTPUT_DIR" \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" \) | wc -l)
    total_size=$(du -sh "$OUTPUT_DIR" | cut -f1)
    
    echo "  総ファイル数: $total_files"
    echo "  HTMLファイル: $html_files"
    echo "  CSSファイル: $css_files"
    echo "  JSファイル: $js_files"
    echo "  画像ファイル: $image_files"
    echo "  合計サイズ: $total_size"
}

# メイン処理
main() {
    log_info "=== WordPress Blog Complete Mirror Script ==="
    log_info "ソースURL: $SOURCE_URL"
    log_info "出力先: $OUTPUT_DIR"
    echo ""
    
    # 既存ディレクトリのクリーンアップ
    cleanup_existing
    
    # ミラーリング実行
    perform_mirror
    
    # 各種修正処理
    fix_filenames
    fix_relative_paths
    add_missing_resources
    cleanup_unnecessary
    
    # 統計情報表示
    echo ""
    show_statistics
    
    echo ""
    log_info "✅ ミラーリング完了！"
    log_info "デプロイ準備が整いました: $OUTPUT_DIR/"
    log_info ""
    log_info "次のステップ:"
    echo "  1. ローカルテスト: cd $OUTPUT_DIR && python3 -m http.server 8000"
    echo "  2. GitHubにプッシュ: git add . && git commit -m 'Update mirror' && git push"
    echo "  3. Cloudflare Pagesで自動デプロイ"
}

# 実行
main