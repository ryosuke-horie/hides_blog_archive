# Cloudflare Pages デプロイガイド

## 📋 目次

1. [事前準備](#事前準備)
2. [初回デプロイ（手動）](#初回デプロイ手動)
3. [GitHub連携による自動デプロイ設定](#github連携による自動デプロイ設定)
4. [カスタムドメイン設定](#カスタムドメイン設定)
5. [トラブルシューティング](#トラブルシューティング)

---

## 事前準備

### 必要なもの

- [ ] Cloudflareアカウント（無料）
- [ ] GitHubアカウント
- [ ] ミラーリング済みの静的サイト（`production_mirror/blog`）

### アカウント作成

1. **Cloudflareアカウント作成**
   - https://dash.cloudflare.com/sign-up へアクセス
   - メールアドレスとパスワードを設定
   - メール認証を完了

2. **GitHubアカウント（既存でOK）**
   - https://github.com でアカウント確認

---

## 初回デプロイ（手動）

### 方法1: Wrangler CLI を使用（推奨）

#### 1. Wrangler CLIのインストール

```bash
# Node.jsがインストールされていることを確認
node --version

# Wranglerをインストール
npm install -g wrangler

# または、npxで直接実行（インストール不要）
npx wrangler --version
```

#### 2. Cloudflareにログイン

```bash
# ブラウザが開いて認証画面が表示されます
npx wrangler login
```

#### 3. 静的サイトをデプロイ

```bash
# プロジェクトルートから実行
cd /path/to/hides_blog_archive

# 本番ミラーリングが完了していることを確認
ls -la production_mirror/blog/

# デプロイ実行
npx wrangler pages deploy production_mirror/blog \
  --project-name=hides-blog \
  --branch=main
```

#### 4. デプロイ結果の確認

```
✅ デプロイ成功時の出力例：
Uploading... 100%
Success! Your site was deployed to:
https://hides-blog.pages.dev
```

### 方法2: Cloudflare Dashboard から直接アップロード

1. **Cloudflare Pages にアクセス**
   - https://dash.cloudflare.com へログイン
   - 左メニューから「Pages」を選択

2. **新規プロジェクト作成**
   - 「Create a project」ボタンをクリック
   - 「Upload assets」を選択

3. **ファイルアップロード**
   - `production_mirror/blog`フォルダ内のすべてのファイルを選択
   - ドラッグ&ドロップまたは「Upload」ボタンでアップロード

4. **プロジェクト名設定**
   - プロジェクト名: `hides-blog`
   - 「Deploy site」をクリック

---

## GitHub連携による自動デプロイ設定

### ステップ1: GitHubリポジトリの準備

#### 新規リポジトリ作成

```bash
# 静的サイト用の新規リポジトリを作成
cd production_mirror/blog
git init
git add .
git commit -m "Initial commit of static blog site"

# GitHubで新規リポジトリ作成後
git remote add origin https://github.com/YOUR_USERNAME/hides-blog-static.git
git branch -M main
git push -u origin main
```

### ステップ2: Cloudflare Pages との連携

1. **Cloudflare Pages ダッシュボード**
   - https://dash.cloudflare.com/pages へアクセス
   - 「Create a project」→「Connect to Git」を選択

2. **GitHub連携を承認**
   - 「Connect GitHub account」をクリック
   - GitHubの認証画面で承認

3. **リポジトリ選択**
   - リポジトリ一覧から `hides-blog-static` を選択
   - 「Begin setup」をクリック

4. **ビルド設定**
   ```
   プロジェクト名: hides-blog
   Production branch: main
   Build command: （空欄のまま）
   Build output directory: /
   ```

5. **環境変数（不要）**
   - 静的サイトなので環境変数は不要
   - 「Save and Deploy」をクリック

### ステップ3: 自動デプロイの確認

```bash
# 変更を加えてプッシュ
echo "<!-- Updated: $(date) -->" >> index.html
git add .
git commit -m "Test auto deployment"
git push

# Cloudflare Pagesダッシュボードで
# デプロイが自動的に開始されることを確認
```

---

## カスタムドメイン設定

### 前提条件
- ドメインを所有していること
- DNSの管理権限があること

### 設定手順

1. **Cloudflare Pages プロジェクト設定**
   - プロジェクトダッシュボード → 「Custom domains」タブ
   - 「Set up a custom domain」をクリック

2. **ドメイン入力**
   ```
   例: archive.hidemiyoshi.jp
   または: blog-archive.example.com
   ```

3. **DNS設定**

   **Cloudflareでドメイン管理している場合:**
   - 自動的にCNAMEレコードが追加される
   - 「Activate domain」をクリックして完了

   **外部DNSを使用している場合:**
   ```
   タイプ: CNAME
   名前: archive（サブドメインの場合）
   値: hides-blog.pages.dev
   TTL: 3600
   ```

4. **SSL証明書**
   - Cloudflareが自動的にSSL証明書を発行
   - 通常15分以内に有効化

---

## 更新フロー

### 手動更新

```bash
# 1. 最新のサイトをミラーリング
./scripts/production_mirror.sh

# 2. GitHubにプッシュ（自動デプロイ設定済みの場合）
cd production_mirror/blog
git add .
git commit -m "Update: $(date +%Y-%m-%d)"
git push

# または、Wranglerで直接デプロイ
npx wrangler pages deploy production_mirror/blog --project-name=hides-blog
```

### 定期自動更新（GitHub Actions）

`.github/workflows/mirror-and-deploy.yml` を作成:

```yaml
name: Mirror and Deploy

on:
  schedule:
    # 毎週日曜日の午前2時（JST: 午前11時）
    - cron: '0 17 * * 0'
  workflow_dispatch: # 手動実行も可能

jobs:
  mirror-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3
    
    - name: Setup environment
      run: |
        sudo apt-get update
        sudo apt-get install -y wget
    
    - name: Mirror website
      run: |
        chmod +x scripts/production_mirror.sh
        ./scripts/production_mirror.sh
    
    - name: Deploy to Cloudflare Pages
      uses: cloudflare/pages-action@v1
      with:
        apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
        accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
        projectName: hides-blog
        directory: production_mirror/blog
        branch: main
```

### 必要なSecrets設定

GitHubリポジトリの Settings → Secrets → Actions で追加:

1. **CLOUDFLARE_API_TOKEN**
   - https://dash.cloudflare.com/profile/api-tokens
   - 「Create Token」→「Custom token」
   - 権限: `Cloudflare Pages:Edit`

2. **CLOUDFLARE_ACCOUNT_ID**
   - https://dash.cloudflare.com の右サイドバー
   - 「Account ID」をコピー

---

## トラブルシューティング

### よくある問題と解決方法

#### 1. デプロイが失敗する

```bash
# ファイルサイズ制限の確認（25MB以上のファイルは不可）
find production_mirror/blog -size +25M -type f

# 大きなファイルを除外
find production_mirror/blog -size +25M -type f -delete
```

#### 2. 404エラーが表示される

```bash
# index.htmlが存在するか確認
ls -la production_mirror/blog/index.html

# 存在しない場合は再ミラーリング
./scripts/production_mirror.sh
```

#### 3. スタイルが適用されない

```bash
# CSSファイルのパスを確認
grep -h "stylesheet" production_mirror/blog/index.html

# 相対パスに修正
find production_mirror/blog -name "*.html" -exec \
  sed -i '' 's|https://hidemiyoshi.jp/|/|g' {} \;
```

#### 4. 日本語が文字化けする

```html
<!-- index.html の先頭に追加 -->
<meta charset="UTF-8">
```

#### 5. デプロイは成功したがサイトが表示されない

- キャッシュクリア: `Ctrl+Shift+R` (Windows) / `Cmd+Shift+R` (Mac)
- 別のブラウザで確認
- DNS伝播待ち（最大48時間）

---

## サポート

### Cloudflare Pages 制限事項

- **無料プラン:**
  - 500デプロイ/月
  - 20,000ファイル/デプロイ
  - 25MBファイルサイズ上限
  - 帯域幅無制限

### 有用なリンク

- [Cloudflare Pages ドキュメント](https://developers.cloudflare.com/pages/)
- [Wrangler CLI ドキュメント](https://developers.cloudflare.com/workers/wrangler/)
- [トラブルシューティングガイド](https://developers.cloudflare.com/pages/platform/troubleshooting/)

### 問題が解決しない場合

1. [Cloudflare Community](https://community.cloudflare.com/c/developers/pages/)
2. [GitHub Issues](https://github.com/ryosuke-horie/hides_blog_archive/issues)

---

## 📝 チェックリスト

### 初回デプロイ
- [ ] Cloudflareアカウント作成
- [ ] ミラーリング完了確認
- [ ] Wrangler CLIインストール
- [ ] 初回デプロイ実行
- [ ] サイト表示確認

### GitHub連携設定
- [ ] GitHubリポジトリ作成
- [ ] Cloudflare Pages連携
- [ ] 自動デプロイテスト
- [ ] 正常動作確認

### カスタムドメイン（オプション）
- [ ] ドメイン追加
- [ ] DNS設定
- [ ] SSL証明書確認
- [ ] カスタムドメインでアクセス確認

---

最終更新: 2024年8月20日