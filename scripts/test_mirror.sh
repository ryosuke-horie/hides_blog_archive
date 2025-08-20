#!/bin/bash

# テスト用：数ページだけミラーリング

echo "================================================"
echo "🧪 テストミラーリング（5ページ限定）"
echo "================================================"
echo ""

OUTPUT_DIR="./test_mirror"
mkdir -p "$OUTPUT_DIR"

wget \
  --recursive \
  --level=2 \
  --convert-links \
  --page-requisites \
  --no-parent \
  --no-host-directories \
  --directory-prefix="$OUTPUT_DIR" \
  --user-agent="Mozilla/5.0" \
  --reject="wp-login.php,wp-admin*,wp-json*,feed*" \
  --execute robots=off \
  --accept="html,css,js,jpg,jpeg,png,gif,svg,woff,woff2" \
  --quota=50M \
  "https://hidemiyoshi.jp/blog/"

echo ""
echo "✅ テストミラーリング完了"
echo ""
echo "確認方法:"
echo "  cd $OUTPUT_DIR/blog && python3 -m http.server 8000"
echo "  http://localhost:8000 でアクセス"