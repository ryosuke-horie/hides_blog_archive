#!/bin/bash

# WordPressブログを静的HTMLサイトとして完全にミラーリング
# 複数の方法を提供

set -e

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 設定
SITE_URL="https://hidemiyoshi.jp/blog/"
OUTPUT_DIR="./static_site"

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}🌐 静的サイト生成ツール${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "このスクリプトは、WordPressブログを完全な静的HTMLサイトとして"
echo "ミラーリングします。通常のWebサイトと同じように表示されます。"
echo ""
echo -e "${YELLOW}対象URL:${NC} $SITE_URL"
echo -e "${YELLOW}出力先:${NC} $OUTPUT_DIR"
echo ""

# 方法を選択
echo "ミラーリング方法を選択してください:"
echo "1) wget (高速・基本的)"
echo "2) wget (完全版・時間がかかる)"
echo "3) httrack (高度な設定・要インストール)"
read -p "選択 [1-3]: " choice

# 出力ディレクトリの作成
mkdir -p "$OUTPUT_DIR"

case $choice in
    1)
        echo -e "${GREEN}wgetで基本的なミラーリングを開始...${NC}"
        wget \
            --recursive \
            --level=5 \
            --convert-links \
            --page-requisites \
            --no-parent \
            --no-host-directories \
            --directory-prefix="$OUTPUT_DIR" \
            --user-agent="Mozilla/5.0" \
            --reject="wp-login.php,wp-admin*" \
            --execute robots=off \
            "$SITE_URL"
        ;;
    
    2)
        echo -e "${GREEN}wgetで完全なミラーリングを開始...${NC}"
        echo "※これには時間がかかります（約440記事）"
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
            --reject="wp-login.php,wp-admin*,wp-json*,feed*" \
            --accept="html,htm,css,js,jpg,jpeg,png,gif,svg,woff,woff2,ttf,eot,ico" \
            --execute robots=off \
            --tries=3 \
            --timeout=30 \
            "$SITE_URL"
        
        # インデックスファイルの修正
        if [ -f "$OUTPUT_DIR/blog/index.html" ]; then
            echo -e "${GREEN}インデックスファイルを修正中...${NC}"
            # 相対パスに変換
            find "$OUTPUT_DIR/blog" -name "*.html" -type f -exec \
                sed -i '' 's|https://hidemiyoshi.jp/blog/|/|g' {} \;
        fi
        ;;
    
    3)
        echo -e "${GREEN}HTTrackでミラーリングを開始...${NC}"
        # HTTrackがインストールされているか確認
        if ! command -v httrack &> /dev/null; then
            echo -e "${RED}HTTrackがインストールされていません。${NC}"
            echo "インストール方法:"
            echo "  Mac: brew install httrack"
            echo "  Ubuntu/Debian: sudo apt-get install httrack"
            exit 1
        fi
        
        httrack "$SITE_URL" \
            -O "$OUTPUT_DIR" \
            "+*.hidemiyoshi.jp/blog/*" \
            "-*/wp-admin/*" \
            "-*/wp-login.php" \
            "-*/wp-json/*" \
            --depth=50 \
            --ext-depth=2 \
            --near \
            --robots=0 \
            --footer "" \
            -%k  # リンクを相対パスに変換
        ;;
    
    *)
        echo -e "${RED}無効な選択です${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}✅ ミラーリング完了${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${YELLOW}📁 静的サイトの場所:${NC} $OUTPUT_DIR/blog/"
echo ""
echo -e "${YELLOW}ローカルで確認:${NC}"
echo "  cd $OUTPUT_DIR/blog && python3 -m http.server 8000"
echo "  ブラウザで http://localhost:8000 を開く"
echo ""
echo -e "${YELLOW}Cloudflare Pagesへのデプロイ:${NC}"
echo "  1. $OUTPUT_DIR/blog ディレクトリをGitHubにプッシュ"
echo "  2. Cloudflare Pagesでプロジェクトを作成"
echo "  3. ビルド設定は不要（静的ファイルのため）"