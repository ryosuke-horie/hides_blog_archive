# Cloudflare Pages デプロイガイド

## 📋 事前準備

### 必要なもの
- Cloudflareアカウント（無料）
- GitHubアカウント
- ミラーリング済みの静的サイト（`simple_mirror/`）

## 🚀 デプロイ方法

### 方法1: Wrangler CLI（最速）

```bash
# npxで直接デプロイ（インストール不要）
npx wrangler pages deploy simple_mirror --project-name=hides-blog

# 初回は認証が必要
# ブラウザが開いて認証を求められます
```

### 方法2: GitHub連携（自動デプロイ）

#### 1. GitHubにプッシュ
```bash
git add .
git commit -m "Deploy static mirror site"
git push origin main
```

#### 2. Cloudflare Pagesでプロジェクト作成

1. https://dash.cloudflare.com/ にログイン
2. 「Pages」を選択
3. 「プロジェクトを作成」をクリック
4. 「Gitに接続」を選択
5. GitHubアカウントを連携
6. リポジトリ「hides_blog_archive」を選択

#### 3. ビルド設定

| 項目 | 値 |
|------|-----|
| プロジェクト名 | hides-blog |
| 本番環境のブランチ | main |
| ビルドコマンド | （空欄のまま） |
| ビルド出力ディレクトリ | simple_mirror |

#### 4. デプロイ

「保存してデプロイ」をクリック

## 🌐 カスタムドメイン設定（オプション）

1. Pages プロジェクトの「カスタムドメイン」タブ
2. 「カスタムドメインを設定」
3. ドメイン名を入力（例: `archive.example.com`）
4. DNSレコードを設定：
   ```
   Type: CNAME
   Name: archive
   Content: hides-blog.pages.dev
   ```

## ✅ デプロイ確認

デプロイ後、以下のURLでアクセス可能：
- `https://hides-blog.pages.dev/blog/`

## 📝 更新方法

```bash
# ミラーリングを更新
./scripts/complete_mirror.sh

# GitHubにプッシュ（自動デプロイ）
git add .
git commit -m "Update blog content"
git push
```

## ⚠️ 注意事項

- 初回デプロイは5-10分程度かかります
- 日本語ファイル名は自動的にURLエンコードされます
- 無料プランで月500デプロイまで可能