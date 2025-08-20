#!/bin/bash

# 本番用：全440記事の完全ミラーリング
# 実行時間：約30-60分

set -e

# 色付き出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SITE_URL="https://hidemiyoshi.jp/blog/"
OUTPUT_DIR="./production_mirror"

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}🚀 本番ミラーリング（全440記事）${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${YELLOW}⚠️  注意事項:${NC}"
echo "  - 実行時間: 約30-60分"
echo "  - 必要容量: 約500MB-1GB"
echo "  - ネットワーク使用量: 高"
echo ""
echo -e "${YELLOW}対象URL:${NC} $SITE_URL"
echo -e "${YELLOW}出力先:${NC} $OUTPUT_DIR"
echo ""

read -p "続行しますか？ [y/N]: " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "キャンセルしました"
    exit 0
fi

# 出力ディレクトリの準備
if [ -d "$OUTPUT_DIR" ]; then
    echo -e "${YELLOW}既存のディレクトリが見つかりました${NC}"
    read -p "削除して続行しますか？ [y/N]: " delete_confirm
    if [[ "$delete_confirm" =~ ^[Yy]$ ]]; then
        rm -rf "$OUTPUT_DIR"
    else
        echo "キャンセルしました"
        exit 0
    fi
fi

mkdir -p "$OUTPUT_DIR"

echo ""
echo -e "${GREEN}ミラーリングを開始...${NC}"
echo "進捗状況："
echo ""

# wgetで完全ミラーリング
wget \
    --mirror \
    --convert-links \
    --adjust-extension \
    --page-requisites \
    --no-parent \
    --no-host-directories \
    --directory-prefix="$OUTPUT_DIR" \
    --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
    --wait=0.5 \
    --random-wait \
    --reject="wp-login.php,wp-admin*,wp-json*,xmlrpc.php,wp-cron.php" \
    --accept="html,htm,css,js,jpg,jpeg,png,gif,svg,woff,woff2,ttf,eot,ico,webp" \
    --execute robots=off \
    --tries=3 \
    --timeout=30 \
    --show-progress \
    "$SITE_URL" 2>&1 | grep -E "(Saving to:|Downloaded:)" || true

echo ""
echo -e "${GREEN}リンクの相対パス化...${NC}"

# 絶対URLを相対URLに変換
find "$OUTPUT_DIR/blog" -name "*.html" -type f -exec \
    sed -i '' \
    -e 's|https://hidemiyoshi.jp/blog/|/|g' \
    -e 's|http://hidemiyoshi.jp/blog/|/|g' \
    -e 's|//hidemiyoshi.jp/blog/|/|g' \
    {} \; 2>/dev/null || true

find "$OUTPUT_DIR/blog" -name "*.css" -type f -exec \
    sed -i '' \
    -e 's|https://hidemiyoshi.jp/blog/|/|g' \
    -e 's|http://hidemiyoshi.jp/blog/|/|g' \
    {} \; 2>/dev/null || true

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}✅ ミラーリング完了！${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

# 統計情報
echo -e "${YELLOW}📊 統計情報:${NC}"
echo -n "  HTMLファイル数: "
find "$OUTPUT_DIR/blog" -name "*.html" -type f | wc -l
echo -n "  画像ファイル数: "
find "$OUTPUT_DIR/blog" \( -name "*.jpg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" \) -type f | wc -l
echo -n "  総サイズ: "
du -sh "$OUTPUT_DIR/blog" | cut -f1

echo ""
echo -e "${YELLOW}📁 ミラーサイトの場所:${NC} $OUTPUT_DIR/blog/"
echo ""
echo -e "${YELLOW}🖥️  ローカルで確認:${NC}"
echo "  cd $OUTPUT_DIR/blog && python3 -m http.server 8000"
echo "  ブラウザで http://localhost:8000 を開く"
echo ""
echo -e "${YELLOW}☁️  Cloudflare Pagesへのデプロイ:${NC}"
echo "  1. $OUTPUT_DIR/blog ディレクトリをGitHubにプッシュ"
echo "  2. Cloudflare Pagesでプロジェクト作成"
echo "  3. ビルド設定は不要（静的ファイルのため）"
echo ""
echo -e "${YELLOW}🚀 直接デプロイ:${NC}"
echo "  npx wrangler pages deploy $OUTPUT_DIR/blog --project-name=hides-blog-static"