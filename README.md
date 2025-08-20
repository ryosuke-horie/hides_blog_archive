# Hides Blog Archive

WordPressブログ（https://hidemiyoshi.jp/blog/）を静的HTMLサイトとして完全ミラーリング

## 📌 概要

このプロジェクトは、WordPressブログを**完全な静的HTMLサイト**としてミラーリングし、オリジナルと同じ見た目で表示・保存するシステムです。

### 特徴
- ✅ **オリジナルと同じ見た目** - 特別なビューアー不要
- ✅ **超高速表示** - 静的ファイルのため高速
- ✅ **完全オフライン対応** - ダウンロード後はネット不要
- ✅ **簡単デプロイ** - Cloudflare Pagesで即公開

## 🚀 クイックスタート

### 1. リポジトリのクローン
```bash
git clone https://github.com/ryosuke-horie/hides_blog_archive.git
cd hides_blog_archive
```

### 2. テストミラーリング（5ページ）
```bash
# まず数ページで動作確認
./scripts/test_mirror.sh

# ローカルで確認
cd test_mirror/blog
python3 -m http.server 8000
# ブラウザで http://localhost:8000 を開く
```

### 3. 本番ミラーリング（全440記事）
```bash
# 全記事をミラーリング（30-60分程度）
./scripts/production_mirror.sh

# ローカルで確認
cd production_mirror/blog
python3 -m http.server 8000
```

## ☁️ Cloudflare Pages へのデプロイ

### 方法1: CLIで即デプロイ（最速）
```bash
# Wranglerで直接デプロイ
npx wrangler pages deploy production_mirror/blog --project-name=hides-blog
```

### 方法2: GitHub連携で自動デプロイ
詳細は [CLOUDFLARE_DEPLOY.md](CLOUDFLARE_DEPLOY.md) を参照

## 📁 プロジェクト構成

```
.
├── scripts/
│   ├── test_mirror.sh         # テスト用（5ページ）
│   ├── production_mirror.sh   # 本番用（全記事）
│   └── static_site_generator.sh # インタラクティブ版
├── test_mirror/               # テスト結果
├── production_mirror/         # 本番ミラーサイト
├── CLOUDFLARE_DEPLOY.md      # デプロイ詳細ガイド
└── README.md                  # このファイル
```

## 📊 ミラーリング内容

### ✅ 含まれるもの
- すべての記事ページ
- ページネーション
- 画像・メディアファイル  
- CSS/JavaScriptファイル
- Webフォント

### ❌ 除外されるもの
- WordPress管理画面
- ログインページ
- コメント投稿機能
- 動的な検索機能

## 🛠️ 必要な環境

- macOS/Linux/Windows（WSL）
- wget コマンド
- Python 3（ローカル確認用）
- Node.js（Cloudflareデプロイ用）

## 📚 ドキュメント

- [Cloudflare Pagesデプロイガイド](CLOUDFLARE_DEPLOY.md)
- [静的ミラーリング詳細ガイド](docs/static_mirror_guide.md)
- [トラブルシューティング](docs/troubleshooting.md)

## 💡 トラブルシューティング

### wgetがインストールされていない
```bash
# macOS
brew install wget

# Ubuntu/Debian
sudo apt-get install wget
```

### 文字化けする場合
HTMLファイルのcharsetがUTF-8になっているか確認

### リンクが動作しない場合
相対パス変換スクリプトが自動実行されますが、手動で実行する場合：
```bash
find production_mirror/blog -name "*.html" -exec \
  sed -i '' 's|https://hidemiyoshi.jp/blog/|/|g' {} \;
```

## 📝 ライセンス

MIT License

## 👤 作者

- GitHub: [@ryosuke-horie](https://github.com/ryosuke-horie)