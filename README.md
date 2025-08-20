# Hides Blog Archive

WordPressブログ（https://hidemiyoshi.jp/blog/）の完全アーカイブシステム

## 概要

このプロジェクトは、WordPressブログを完全に静的なHTMLサイトとしてミラーリングし、オリジナルサイトと同じ見た目で表示できるようにするシステムです。

### 2つのアプローチ

1. **静的HTMLミラーリング（推奨）** - オリジナルと同じ見た目で直接表示
2. **WACZアーカイブ** - ReplayWeb.pageを使用したアーカイブビューア

## 技術スタック

- **アーカイブ収集**: browsertrix-crawler
- **アーカイブ形式**: WACZ (Web Archive Collection Zipped)
- **再生UI**: ReplayWeb.page
- **ホスティング**: Cloudflare Pages

## クイックスタート

### 方法1: 静的HTMLサイトとしてミラーリング（推奨）

完全な静的サイトとして、オリジナルと同じ見た目で表示します。

#### テストミラーリング（5ページ）
```bash
# テスト用に数ページだけミラーリング
./scripts/test_mirror.sh

# ローカルで確認
cd test_mirror/blog
python3 -m http.server 8000
# http://localhost:8000 でアクセス
```

#### 本番ミラーリング（全440記事）
```bash
# 完全なミラーリングを実行
./scripts/static_site_generator.sh
# オプション2（完全版）を選択

# ローカルで確認
cd static_site/blog
python3 -m http.server 8000
```

### 方法2: WACZアーカイブ形式

ReplayWeb.pageビューアを使用したアーカイブ形式です。

### 前提条件

- Docker & Docker Compose
- 10GB以上の空きディスク容量
- 4GB以上のメモリ

### 1. 環境構築

```bash
# リポジトリのクローン
git clone https://github.com/ryosuke-horie/hides_blog_archive.git
cd hides_blog_archive

# Dockerイメージのビルド
make build
```

### 2. テストクロール（推奨）

まず10ページのテストクロールで動作確認：

```bash
# テストクロール実行（10ページ制限）
make test-crawl

# または3ページのクイックテスト
make quick-test
```

### 3. 開発環境でUIを確認

#### 方法1: Range Request対応サーバー（推奨）

WACZファイルは大きいため、Range Request対応サーバーが必要です：

```bash
# デプロイ準備（テスト用WACZをpublicにコピー）
./scripts/prepare_deploy.sh

# Range Request対応サーバーを起動
python3 scripts/dev_server.py

# ブラウザで開く
# http://localhost:8000
```

#### 方法2: Node.js（http-server）

```bash
# http-serverをインストール（初回のみ）
npm install -g http-server

# デプロイ準備
./scripts/prepare_deploy.sh

# サーバー起動（CORSとService Worker対応）
cd public
http-server -c-1 --cors -p 8000

# ブラウザで開く
# http://localhost:8000
```

#### 方法3: VS Codeの Live Server

1. VS Codeで`public`フォルダを開く
2. Live Server拡張機能をインストール
3. `index.html`を右クリック → "Open with Live Server"

### 4. 本番クロール（全440記事）

⚠️ **注意**: 本番クロールは時間がかかります（1-2時間程度）

```bash
# フルクロール実行
make crawl
# プロンプトで「y」を入力して続行
```

### 5. デプロイ準備

```bash
# WACZファイルをpublicディレクトリにコピー
./scripts/prepare_deploy.sh
```

## 開発環境での確認ポイント

### ✅ 正常動作の確認

1. **初期読み込み**
   - 「アーカイブを読み込み中...」のローディング表示
   - WACZファイルの読み込み完了

2. **UI表示**
   - ヘッダーに「Hides Blog Archive」表示
   - Noteへのリンクが機能
   - フッターの表示

3. **アーカイブ再生**
   - ReplayWeb.pageのUIが表示
   - ブログ記事が閲覧可能
   - 画像が正常に表示
   - ページネーションが機能

### ⚠️ トラブルシューティング

#### CORS エラーが出る場合

```bash
# CORSを許可するオプション付きでサーバー起動
python3 -m http.server 8000 --bind 127.0.0.1
# または
http-server -c-1 --cors
```

#### Service Worker エラーが出る場合

- HTTPSまたはlocalhostでのみ動作します
- `http://localhost:8000` を使用してください（IPアドレスではなく）

#### WACZファイルが見つからない場合

```bash
# WACZファイルの存在確認
ls -la public/archives/

# ない場合は再度デプロイ準備
./scripts/prepare_deploy.sh
```

## ディレクトリ構造

```
.
├── config/              # クロール設定ファイル
│   ├── test-crawl.yaml
│   └── production-crawl.yaml
├── crawls/              # クロール結果（.gitignore）
├── public/              # デプロイ用ファイル
│   ├── index.html       # ReplayWeb.page UI
│   ├── sw.js           # Service Worker
│   └── archives/       # WACZファイル配置
├── scripts/            # ユーティリティスクリプト
├── docker-compose.yml  # Docker設定
└── Makefile           # コマンド集
```

## 主要コマンド

| コマンド | 説明 |
|---------|------|
| `make build` | Dockerイメージをビルド |
| `make test-crawl` | テストクロール（10ページ） |
| `make quick-test` | クイックテスト（3ページ） |
| `make crawl` | フルクロール（440記事） |
| `make check-results` | クロール結果を確認 |
| `make clean` | クロール結果をクリーンアップ |

## Cloudflare Pages へのデプロイ

### 方法1: GitHub連携（推奨）

1. GitHubにpushされた`public`ディレクトリを自動デプロイ
2. Cloudflare Dashboardでプロジェクト作成
3. ビルド設定：
   - ビルドコマンド: （空欄）
   - ビルド出力ディレクトリ: `public`

### 方法2: CLIデプロイ

```bash
# Wrangler CLIをインストール
npm install -g wrangler

# デプロイ
npx wrangler pages deploy public --project-name=hides-blog-archive
```

## 技術仕様

- **総記事数**: 約440記事
- **推定サイズ**: 100-500MB（画像含む）
- **対象範囲**: `/blog/`サブディレクトリのみ
- **除外対象**: 管理画面、フィード、コメント投稿など

## ライセンス

MIT License

## 作者

- GitHub: [@ryosuke-horie](https://github.com/ryosuke-horie)