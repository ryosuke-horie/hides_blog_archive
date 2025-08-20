#!/bin/bash

# WordPressブログの完全ミラーリングスクリプト
# wgetを使用して静的HTMLサイトとして保存

set -e

# 設定
SITE_URL="https://hidemiyoshi.jp/blog/"
OUTPUT_DIR="./mirror"
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

echo "================================================"
echo "🌐 サイトミラーリングを開始"
echo "================================================"
echo "対象URL: $SITE_URL"
echo "出力先: $OUTPUT_DIR"
echo ""

# 出力ディレクトリの作成
mkdir -p "$OUTPUT_DIR"

# wgetでサイト全体をミラーリング
wget \
  --mirror \
  --convert-links \
  --adjust-extension \
  --page-requisites \
  --no-parent \
  --no-host-directories \
  --directory-prefix="$OUTPUT_DIR" \
  --user-agent="$USER_AGENT" \
  --wait=1 \
  --random-wait \
  --limit-rate=200k \
  --reject="wp-login.php,wp-admin*,wp-json*" \
  --accept="html,htm,css,js,jpg,jpeg,png,gif,svg,woff,woff2,ttf,eot" \
  --execute robots=off \
  "$SITE_URL"

echo ""
echo "================================================"
echo "✅ ミラーリング完了"
echo "================================================"
echo ""
echo "📁 ミラーサイトの場所: $OUTPUT_DIR/blog/"
echo ""
echo "ローカルで確認:"
echo "  cd $OUTPUT_DIR/blog && python3 -m http.server 8000"
echo "  ブラウザで http://localhost:8000 を開く"