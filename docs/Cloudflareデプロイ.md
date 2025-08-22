# Cloudflare Pages デプロイガイド

## 📋 デプロイ準備

### 1. ミラーサイトの確認

```bash
# simple_mirrorディレクトリに完全なミラーサイトが含まれています
ls -la simple_mirror/
# 総ファイル数: 3,750ファイル
# HTMLファイル: 582記事
# 合計サイズ: 488MB
```

### 2. ローカル動作確認

```bash
# ミラーサイトをローカルで起動
cd simple_mirror
python3 -m http.server 8000

# ブラウザで確認
# http://localhost:8000/blog/ にアクセス
# 以下を確認：
# - トップページの表示
# - 記事ページの表示（いくつかクリック）
# - CSS/スタイルの適用
# - 画像の表示
# - 日本語記事タイトルのリンク動作
```

### 3. デプロイ前の最終確認

```bash
# 元のディレクトリに戻る
cd ..

# サイズ確認
du -sh simple_mirror
# → 488MB（Cloudflare Pagesの無料枠500MB以内）
```

## 🚀 Cloudflare Pagesへデプロイ

### デプロイ実行

```bash
# Wrangler CLIでデプロイ（初回は認証が必要）
npx wrangler pages deploy simple_mirror --project-name=hides-blog-static

# デプロイ完了後、URLが表示される
# 例：https://hides-blog-static.pages.dev/
```

### 本番確認

```bash
# デプロイ後、ブラウザで以下を確認
# 1. https://hides-blog-static.pages.dev/blog/ にアクセス
# 2. 記事一覧の表示確認
# 3. 個別記事のクリック確認
# 4. 画像・CSS・JSの読み込み確認
# 5. 404エラーがないか確認
```

## ⚠️ 注意事項

- 初回デプロイは5-10分程度かかります
- ミラーリングは30-60分程度かかります（記事数による）
- 日本語ファイル名は自動的にURLエンコードされます
- 500MB以上の場合はCloudflare R2の利用を検討