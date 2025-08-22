#!/bin/bash

#################################################################
# WordPress Blog Mirror Script
# 
# WordPressブログを完全にミラーリングし、
# 静的サイトとして保存します
#################################################################

set -e

# 設定
SOURCE_URL="https://hidemiyoshi.jp/blog/"
OUTPUT_DIR="simple_mirror"
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

# 既存ディレクトリのバックアップ
backup_existing() {
    if [ -d "$OUTPUT_DIR" ]; then
        backup_name="${OUTPUT_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
        log_info "既存のミラーをバックアップ中: $backup_name"
        mv "$OUTPUT_DIR" "$backup_name"
        log_info "バックアップ完了"
    fi
}

# ミラーリング実行
perform_mirror() {
    log_info "WordPressブログのミラーリングを開始..."
    log_info "注: 全記事の取得には30-60分程度かかります"
    
    # wgetでミラーリング（クエリパラメーター対策版）
    wget \
        --recursive \
        --level=0 \
        --no-clobber \
        --page-requisites \
        --adjust-extension \
        --convert-links \
        --no-parent \
        --directory-prefix="$OUTPUT_DIR" \
        --no-host-directories \
        --user-agent="$USER_AGENT" \
        --domains=hidemiyoshi.jp \
        --follow-tags=a,area \
        --accept-regex='https?://hidemiyoshi\.jp/blog/((page/[0-9]+/)|(category/[^/]+/)|(tag/[^/]+/)|([0-9]{4}/[0-9]{2}/([0-9]{2}/)?)|[^?#]+\.html)' \
        --reject-regex='[?&](p|replytocom)=' \
        --wait=0.5 \
        --random-wait \
        --limit-rate=300k \
        --tries=3 \
        --timeout=30 \
        --compression=auto \
        -e robots=off \
        "$SOURCE_URL"
    
    # wp-content と wp-includes も確実に取得
    log_info "リソースファイルを追加取得中..."
    
    # CSS/JS/画像などのリソースを取得
    wget \
        --recursive \
        --level=5 \
        --no-clobber \
        --page-requisites \
        --directory-prefix="$OUTPUT_DIR" \
        --no-host-directories \
        --user-agent="$USER_AGENT" \
        --accept="css,js,jpg,jpeg,png,gif,svg,woff,woff2,ttf,eot" \
        --wait=0.2 \
        --tries=2 \
        --timeout=30 \
        -e robots=off \
        "https://hidemiyoshi.jp/wp-content/" 2>/dev/null || true
        
    wget \
        --recursive \
        --level=5 \
        --no-clobber \
        --page-requisites \
        --directory-prefix="$OUTPUT_DIR" \
        --no-host-directories \
        --user-agent="$USER_AGENT" \
        --accept="css,js,jpg,jpeg,png,gif,svg,woff,woff2,ttf,eot" \
        --wait=0.2 \
        --tries=2 \
        --timeout=30 \
        -e robots=off \
        "https://hidemiyoshi.jp/wp-includes/" 2>/dev/null || true
    
    log_info "ミラーリング完了"
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

# 壊れたリンクの修正（後処理）
fix_broken_links() {
    log_info "壊れたリンクを修正中..."
    
    # index.html?p=XXX 形式のリンクを修正
    find "$OUTPUT_DIR" -name "*.html" -type f | while read -r file; do
        # index.html%3Fp= または index.html?p= 形式のリンクを検出して修正
        # これらは実際には記事ページへのリンクなので、適切なパスに変換
        
        # 一時ファイルを作成
        temp_file="${file}.tmp"
        
        # sedで問題のあるパターンを修正
        # index.html?p=XXX または index.html%3Fp=XXX を index.html に変換
        sed -E 's|href="([^"]*/)?(index\.html(%3F|[?])p=[0-9]+)"|href="\1index.html"|g' "$file" > "$temp_file"
        
        # 変更があった場合のみファイルを更新
        if ! cmp -s "$file" "$temp_file"; then
            mv "$temp_file" "$file"
            echo "  修正: $(basename "$file")"
        else
            rm "$temp_file"
        fi
    done
    
    # ?p=XXX.html 形式のファイルが存在する場合は削除
    find "$OUTPUT_DIR" -name "*\?p=*.html" -type f -delete 2>/dev/null || true
    find "$OUTPUT_DIR" -name "*%3Fp=*.html" -type f -delete 2>/dev/null || true
    
    log_info "リンク修正完了"
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
    \) -delete 2>/dev/null || true
    
    # 空ディレクトリを削除
    find "$OUTPUT_DIR" -type d -empty -delete 2>/dev/null || true
    
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
    log_info "=== WordPress Blog Mirror Script ==="
    log_info "ソースURL: $SOURCE_URL"
    log_info "出力先: $OUTPUT_DIR"
    echo ""
    
    # 確認プロンプト
    read -p "新規取得を開始しますか？ (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "キャンセルしました"
        exit 0
    fi
    
    # 既存ディレクトリがあれば削除（バックアップは取らない）
    if [ -d "$OUTPUT_DIR" ]; then
        log_info "既存のディレクトリを削除中..."
        rm -rf "$OUTPUT_DIR"
    fi
    
    # ミラーリング実行
    perform_mirror
    
    # 各種修正処理
    fix_filenames
    fix_relative_paths
    fix_broken_links
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
    echo "  2. デプロイ: npx wrangler pages deploy $OUTPUT_DIR --project-name=hides-blog-static"
}

# 実行
main