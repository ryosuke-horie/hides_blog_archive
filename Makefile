.PHONY: help build crawl test-crawl stop clean logs shell setup

# デフォルトターゲット
help:
	@echo "利用可能なコマンド:"
	@echo "  make setup        - 初期セットアップ（ディレクトリ作成）"
	@echo "  make build        - Dockerイメージをビルド"
	@echo "  make crawl        - フルクロールを実行"
	@echo "  make test-crawl   - テストクロール（10ページ制限）を実行"
	@echo "  make stop         - クロールを停止"
	@echo "  make clean        - クロール結果をクリーンアップ"
	@echo "  make logs         - ログを表示"
	@echo "  make shell        - コンテナ内でシェルを起動"

# 初期セットアップ
setup:
	@echo "📁 必要なディレクトリを作成中..."
	@mkdir -p crawls config tmp
	@echo "✅ セットアップ完了"

# Dockerイメージのビルド
build:
	@echo "🔨 Dockerイメージをビルド中..."
	docker-compose build
	@echo "✅ ビルド完了"

# フルクロールの実行
crawl: setup
	@echo "🕷️ フルクロールを開始..."
	@echo "URL: ${TARGET_URL}"
	docker-compose up
	@echo "✅ クロール完了"

# テストクロール（10ページ制限）
test-crawl: setup
	@echo "🧪 テストクロールを開始（10ページ制限）..."
	@echo "URL: https://hidemiyoshi.jp/blog/"
	docker-compose -f docker-compose.test.yml up
	@echo "✅ テストクロール完了"

# クイックテスト（設定ファイル使用）
quick-test: setup
	@echo "⚡ クイックテスト（3ページ）..."
	docker-compose -f docker-compose.test.yml run --rm crawler-test \
		--url https://hidemiyoshi.jp/blog/ \
		--collection quick_test \
		--generateWACZ \
		--limit 3 \
		--workers 1 \
		--behaviors autoscroll \
		--screenshot fullPage
	@echo "✅ クイックテスト完了"

# クロールの停止
stop:
	@echo "⏹️ クロールを停止中..."
	docker-compose down
	@echo "✅ 停止完了"

# クロール結果のクリーンアップ
clean:
	@echo "🧹 クロール結果をクリーンアップ中..."
	@read -p "本当にクロール結果を削除しますか？ [y/N]: " confirm && \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		rm -rf crawls/* tmp/*; \
		echo "✅ クリーンアップ完了"; \
	else \
		echo "❌ クリーンアップをキャンセルしました"; \
	fi

# ログの表示
logs:
	@echo "📋 ログを表示..."
	docker-compose logs -f

# コンテナ内でシェルを起動
shell:
	@echo "🐚 コンテナ内でシェルを起動..."
	docker-compose run --rm crawler /bin/bash

# クロール結果の確認
check-results:
	@echo "📊 クロール結果を確認..."
	@echo "=== WACZファイル ==="
	@find crawls -name "*.wacz" -type f -exec ls -lh {} \; 2>/dev/null || echo "WACZファイルが見つかりません"
	@echo ""
	@echo "=== WARCファイル ==="
	@find crawls -name "*.warc.gz" -type f -exec ls -lh {} \; 2>/dev/null || echo "WARCファイルが見つかりません"
	@echo ""
	@echo "=== ログファイル ==="
	@find crawls -name "*.log" -type f -exec ls -lh {} \; 2>/dev/null || echo "ログファイルが見つかりません"

# 設定の確認
check-config:
	@echo "⚙️ 現在の設定:"
	@echo "-------------------"
	@cat .env