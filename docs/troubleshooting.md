# トラブルシューティング

## よくある問題と解決方法

### 1. ページネーションがNot Foundになる

**原因**: クロール時にページネーションのリンクが正しく辿られていない

**解決方法**:
```yaml
# config/test-crawl-improved.yaml の設定
seeds:
  - url: https://hidemiyoshi.jp/blog/
    depth: 5  # 深さを増やす

# 除外パターンを最小限に
exclude:
  - .*\/wp-admin\/.*
  - .*\/wp-login\.php
  - .*\/feed\/.*
```

**改善版テストの実行**:
```bash
make test-improved
```

### 2. 画像が取得できていない

**原因**: 
- 画像の遅延読み込み
- 外部CDNからの画像
- ページ読み込み完了前のクロール

**解決方法**:
```yaml
# 待機時間を増やす
pageExtraDelay: 3000
waitUntil: networkidle0  # networkidle2からnetworkidle0に変更
networkIdleWait: 3000

# スクロール設定
behaviors:
  - autoscroll
scrollDelay: 1500  # ゆっくりスクロール

# 外部リソースも取得
extraHops: 1
```

### 3. Service Workerエラー

**原因**: HTTPSまたはlocalhostでないとService Workerが動作しない

**解決方法**:
- 必ず `http://localhost:8000` を使用（IPアドレスではダメ）
- Range Request対応サーバーを使用: `make serve`

### 4. WACZファイルが大きすぎる

**原因**: スクリーンショットや不要なリソースの取得

**解決方法**:
```yaml
# スクリーンショットを無効化
screenshot: false

# 特定のリソースをブロック
blockRules:
  - url: googletagmanager.com
    type: block
  - url: google-analytics.com
    type: block
```

## 推奨クロール手順

### 1. まず改善版テストで確認
```bash
# 20ページの改善版テスト
make test-improved

# 結果確認
make check-results
```

### 2. 問題がなければ本番クロール
```bash
# 本番設定を確認
cat config/production-crawl.yaml

# フルクロール実行
make crawl
```

### 3. デプロイ前の確認
```bash
# ローカルで表示確認
make serve
# http://localhost:8000 でアクセス

# 以下を確認:
# - トップページが表示される
# - 記事が閲覧できる
# - ページネーションが機能する
# - 画像が表示される
```

## 設定ファイルの使い分け

| ファイル | 用途 | ページ数 | 特徴 |
|---------|------|---------|------|
| test-crawl.yaml | 基本テスト | 10 | 高速、基本機能確認 |
| test-crawl-improved.yaml | 改善版テスト | 20 | ページネーション・画像対応 |
| production-crawl.yaml | 本番 | 無制限 | 全記事取得 |

## デバッグ方法

### クロールログの確認
```bash
# 最新のログを確認
find crawls -name "*.log" -type f -exec tail -100 {} \;
```

### WACZファイルの内容確認
```bash
# WACZファイルサイズ
ls -lh crawls/collections/*/
```

### ネットワーク確認
ブラウザの開発者ツールで:
1. Network タブを開く
2. 206 Partial Content が返されているか確認
3. 画像URLが正しく読み込まれているか確認