#!/bin/bash

# デプロイ準備スクリプト
# WACZファイルをpublicディレクトリにコピーして、デプロイ準備を行う

echo "================================================"
echo "📦 デプロイ準備を開始"
echo "================================================"

# 変数定義
WACZ_SOURCE="crawls/collections/hides_blog_full/hides_blog_full.wacz"
WACZ_DEST="public/archives/hides_blog_full.wacz"
PUBLIC_DIR="public"

# publicディレクトリの確認
if [ ! -d "$PUBLIC_DIR" ]; then
    echo "❌ publicディレクトリが見つかりません"
    exit 1
fi

# WACZファイルの確認
if [ ! -f "$WACZ_SOURCE" ]; then
    echo "⚠️ 本番WACZファイルが見つかりません: $WACZ_SOURCE"
    echo "テスト用WACZファイルを探しています..."
    
    # テスト用WACZファイルを探す
    TEST_WACZ="crawls/collections/test_hides_blog/test_hides_blog.wacz"
    if [ -f "$TEST_WACZ" ]; then
        echo "✅ テスト用WACZファイルを使用します: $TEST_WACZ"
        WACZ_SOURCE=$TEST_WACZ
    else
        echo "❌ WACZファイルが見つかりません"
        echo "先にクロールを実行してください:"
        echo "  make test-crawl  # テストクロール"
        echo "  make crawl       # フルクロール"
        exit 1
    fi
fi

# WACZファイルのコピー
echo "📋 WACZファイルをコピー中..."
cp "$WACZ_SOURCE" "$WACZ_DEST"

if [ $? -eq 0 ]; then
    echo "✅ WACZファイルをコピーしました"
    file_size=$(ls -lh "$WACZ_DEST" | awk '{print $5}')
    echo "  ファイルサイズ: $file_size"
else
    echo "❌ WACZファイルのコピーに失敗しました"
    exit 1
fi

# _headersファイルの作成（Cloudflare Pages用）
cat > "$PUBLIC_DIR/_headers" << EOF
/*
  Access-Control-Allow-Origin: *
  Access-Control-Allow-Methods: GET, HEAD, OPTIONS
  Access-Control-Allow-Headers: *

/archives/*
  Cache-Control: public, max-age=31536000
  Access-Control-Allow-Origin: *

/*.wacz
  Content-Type: application/wacz+zip
  Cache-Control: public, max-age=31536000
EOF

echo "✅ _headersファイルを作成しました"

# _redirectsファイルの作成（オプション）
cat > "$PUBLIC_DIR/_redirects" << EOF
# 旧URLから新しいNoteへのリダイレクト（必要に応じて）
# /blog/* https://note.com/hidemiyoshi 301
EOF

echo "✅ _redirectsファイルを作成しました"

# デプロイ情報の表示
echo ""
echo "================================================"
echo "✅ デプロイ準備完了"
echo "================================================"
echo ""
echo "📁 デプロイディレクトリ: $PUBLIC_DIR"
echo "📦 WACZファイル: $WACZ_DEST"
echo ""
echo "次のステップ:"
echo "1. Cloudflare Pagesでプロジェクトを作成"
echo "2. publicディレクトリをルートに設定"
echo "3. GitHubと連携またはCLIでデプロイ"
echo ""
echo "CLIでのデプロイ例:"
echo "  npx wrangler pages deploy public --project-name=hides-blog-archive"