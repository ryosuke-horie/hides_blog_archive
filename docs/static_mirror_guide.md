# 静的HTMLミラーリングガイド

## 概要

WordPressブログを完全な静的HTMLサイトとしてミラーリングすることで、以下のメリットがあります：

- ✅ **オリジナルと同じ見た目** - アーカイブビューアー不要
- ✅ **高速表示** - 静的ファイルのため非常に高速
- ✅ **完全オフライン対応** - インターネット接続不要
- ✅ **簡単なデプロイ** - 静的ホスティングサービスで公開可能

## 実行方法

### 1. テスト実行（推奨）

まず数ページだけミラーリングして動作確認：

```bash
./scripts/test_mirror.sh
```

### 2. 本番実行（全440記事）

```bash
./scripts/static_site_generator.sh
# オプション2（完全版）を選択
```

実行時間の目安：
- テスト版：1-2分
- 完全版：30-60分（記事数による）

## ミラーリングされる内容

### 含まれるもの
- ✅ すべての記事ページ
- ✅ ページネーション
- ✅ 画像・メディアファイル
- ✅ CSS/JavaScriptファイル
- ✅ Webフォント

### 除外されるもの
- ❌ WordPress管理画面
- ❌ ログインページ
- ❌ コメント投稿機能
- ❌ 検索機能（動的処理）
- ❌ RSSフィード

## ローカルでの確認

```bash
cd static_site/blog
python3 -m http.server 8000
```

ブラウザで http://localhost:8000 を開く

## Cloudflare Pagesへのデプロイ

### 方法1: GitHub経由（推奨）

1. `static_site/blog`ディレクトリを新しいGitリポジトリにプッシュ
2. Cloudflare Pagesでプロジェクト作成
3. ビルド設定：
   - ビルドコマンド：（空欄）
   - ビルド出力ディレクトリ：`/`

### 方法2: 直接アップロード

```bash
npx wrangler pages deploy static_site/blog --project-name=hides-blog-static
```

## トラブルシューティング

### リンクが動作しない

相対パスに変換するスクリプトを実行：

```bash
find static_site/blog -name "*.html" -type f -exec \
  sed -i '' 's|https://hidemiyoshi.jp/blog/|/|g' {} \;
```

### 文字化けする

UTF-8エンコーディングを確認：

```bash
file -I static_site/blog/index.html
```

### 画像が表示されない

画像ファイルが正しくダウンロードされているか確認：

```bash
find static_site/blog -name "*.jpg" -o -name "*.png" | wc -l
```

## 高度な設定

### カスタムドメインの設定

1. Cloudflare Pagesでカスタムドメインを追加
2. DNSレコードを設定
3. SSL証明書は自動で発行される

### 定期更新の自動化

GitHub Actionsを使用して定期的にミラーリングを実行：

```yaml
name: Mirror WordPress Site
on:
  schedule:
    - cron: '0 0 * * 0'  # 毎週日曜日
  workflow_dispatch:

jobs:
  mirror:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Mirror site
        run: ./scripts/static_site_generator.sh
      - name: Deploy to Cloudflare Pages
        run: npx wrangler pages deploy static_site/blog
```

## メリット vs デメリット

### メリット
- 🚀 超高速表示
- 💰 低コスト（静的ホスティング）
- 🔒 セキュリティ（WordPressの脆弱性なし）
- 📱 CDN対応で世界中から高速アクセス

### デメリット
- ❌ 動的機能の喪失
- ❌ 更新に再ミラーリングが必要
- ❌ コメント機能なし
- ❌ 検索機能の制限