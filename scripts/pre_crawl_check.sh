#!/bin/bash

# クロール前のチェックスクリプト

echo "================================================"
echo "🔍 クロール前チェックを開始"
echo "================================================"

# 1. Docker環境の確認
echo ""
echo "📦 Docker環境チェック..."
if command -v docker &> /dev/null; then
    echo "✅ Docker: $(docker --version)"
else
    echo "❌ Dockerがインストールされていません"
    exit 1
fi

if command -v docker-compose &> /dev/null; then
    echo "✅ Docker Compose: $(docker-compose --version)"
else
    echo "❌ Docker Composeがインストールされていません"
    exit 1
fi

# 2. ディレクトリの確認と作成
echo ""
echo "📁 ディレクトリチェック..."
directories=("crawls" "config" "tmp")
for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "📂 $dir ディレクトリを作成..."
        mkdir -p "$dir"
    fi
    echo "✅ $dir ディレクトリ: OK"
done

# 3. 設定ファイルの確認
echo ""
echo "⚙️ 設定ファイルチェック..."
config_files=(
    "config/crawl-config.yaml"
    "config/crawl-config-detailed.yaml"
    "config/test-crawl.yaml"
    "docker-compose.yml"
    "docker-compose.test.yml"
    ".env"
)

for file in "${config_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file: 存在"
    else
        echo "⚠️ $file: 見つかりません"
    fi
done

# 4. ディスク容量の確認
echo ""
echo "💾 ディスク容量チェック..."
df -h . | tail -1 | awk '{print "  使用可能: " $4 " / 全体: " $2 " (使用率: " $5 ")"}'

available_gb=$(df . | tail -1 | awk '{print $4}')
available_gb=$((available_gb / 1024 / 1024))
if [ $available_gb -lt 5 ]; then
    echo "⚠️ 警告: 空き容量が5GB未満です（${available_gb}GB）"
    echo "  フルクロールには10GB以上の空き容量を推奨します"
else
    echo "✅ 十分な空き容量があります（${available_gb}GB）"
fi

# 5. ターゲットサイトの接続確認
echo ""
echo "🌐 ターゲットサイト接続チェック..."
target_url="https://hidemiyoshi.jp/blog/"
if curl -s -o /dev/null -w "%{http_code}" "$target_url" | grep -q "200"; then
    echo "✅ $target_url: 接続OK (HTTP 200)"
else
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "$target_url")
    echo "⚠️ $target_url: HTTP $http_code"
fi

# 6. メモリ確認
echo ""
echo "🧮 システムリソースチェック..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    memory_gb=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
    echo "  メモリ: ${memory_gb}GB"
else
    # Linux
    memory_gb=$(free -g | awk '/^Mem:/{print $2}')
    echo "  メモリ: ${memory_gb}GB"
fi

if [ $memory_gb -lt 4 ]; then
    echo "⚠️ 警告: メモリが4GB未満です。クロール中にメモリ不足になる可能性があります"
else
    echo "✅ 十分なメモリがあります"
fi

echo ""
echo "================================================"
echo "✅ クロール前チェック完了"
echo "================================================"
echo ""
echo "次のコマンドでクロールを開始できます:"
echo "  テストクロール（10ページ）: make test-crawl"
echo "  クイックテスト（3ページ）: make quick-test"
echo "  フルクロール: make crawl"