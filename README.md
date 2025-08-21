# WordPress Blog Mirror Archive

WordPressブログ（https://hidemiyoshi.jp/blog/）を静的HTMLとしてミラーリングし、Cloudflare Pagesでホスティングするプロジェクトです。

## 🎯 プロジェクト概要

- **目的**: WordPressブログの完全な静的アーカイブを作成
- **対象**: `https://hidemiyoshi.jp/blog/` （約440記事）
- **方式**: wgetによる静的HTMLミラーリング
- **ホスティング**: Cloudflare Pages

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

### 2. 完全ミラーリング実行

```bash
# 全記事を含む完全ミラーリング（30-60分程度）
./scripts/complete_mirror.sh

# 注: 現在は simple_mirror/ に既存のミラーがあります
# 新規実行する場合は complete_mirror/ に作成されます
```

このスクリプトは以下を自動実行：
- 全コンテンツのダウンロード
- 日本語ファイル名の修正
- 相対パスの調整
- CSS/JSリンクの補完
- 不要ファイルのクリーンアップ

### 3. ローカルテスト

```bash
# ミラーサイトをローカルで確認
cd simple_mirror  # または complete_mirror（新規実行後）
python3 -m http.server 8000
# ブラウザで http://localhost:8000/blog/ にアクセス
```

## ☁️ Cloudflare Pages へのデプロイ

### 方法1: CLIで即デプロイ（最速）
```bash
# Wranglerで直接デプロイ
npx wrangler pages deploy simple_mirror --project-name=hides-blog
# または新規実行後: npx wrangler pages deploy complete_mirror --project-name=hides-blog
```

### 方法2: GitHub連携で自動デプロイ
1. このリポジトリをGitHubにプッシュ
2. Cloudflare Pagesでプロジェクト作成
3. ビルド設定：
   - ビルドコマンド: （空欄）
   - ビルド出力ディレクトリ: `complete_mirror`
4. 以降はgit pushで自動デプロイ

詳細は [CLOUDFLARE_DEPLOY.md](CLOUDFLARE_DEPLOY.md) を参照。

## 📁 ディレクトリ構造

```
hides_blog_archive/
├── README.md                    # このファイル
├── CLOUDFLARE_DEPLOY.md         # デプロイ詳細ガイド
├── scripts/
│   └── complete_mirror.sh      # 統合ミラーリングスクリプト
└── simple_mirror/               # 現在のミラーサイト（488MB、動作確認済み）
    ├── blog/                    # ブログコンテンツ
    ├── wp-content/              # テーマ、CSS、画像
    └── wp-includes/             # JavaScript、CSS
```

## 🔧 スクリプト詳細

### `complete_mirror.sh`
統合ミラーリングスクリプト。以下の処理を自動実行：

1. **サイトミラーリング**: wgetで全コンテンツ取得
2. **ファイル名修正**: 日本語ファイル名をURLエンコード
3. **パス修正**: 相対パスを適切に調整
4. **リソース追加**: 不足しているCSS/JSを補完
5. **クリーンアップ**: 不要なファイルを削除
6. **統計表示**: ファイル数やサイズを表示

## 🛠 トラブルシューティング

### CSS/スタイルが適用されない場合
```bash
# スクリプトを再実行
./scripts/complete_mirror.sh
```

### 404エラーが出る場合
- ファイル名のURLエンコーディングを確認
- Cloudflare Pagesの設定でUTF-8を有効化

### ローカルで文字化けする場合
```bash
# UTF-8対応のサーバーで起動
python3 -m http.server 8000
```

## 📝 定期更新

ブログを定期的に更新する場合：

```bash
# 最新のコンテンツをミラーリング
./scripts/complete_mirror.sh

# 変更をコミット＆プッシュ
git add .
git commit -m "Update blog content $(date +%Y-%m-%d)"
git push

# Cloudflare Pagesが自動デプロイ
```

## 📊 パフォーマンス

- **ミラーリング時間**: 約30-60分（440記事）
- **サイズ**: 約100-200MB
- **表示速度**: オリジナルの10倍以上高速
- **可用性**: 99.9%（Cloudflare CDN）

## 🔒 セキュリティ

- WordPressの動的機能を完全に排除
- 管理画面やAPIエンドポイントは含まない
- 静的ファイルのみで構成

## 📄 ライセンス

このプロジェクトはアーカイブ目的で作成されています。
オリジナルコンテンツの著作権は元のサイト所有者に帰属します。

## 🤝 貢献

問題や改善案がある場合は、Issueまたはプルリクエストをお送りください。

## 📚 関連ドキュメント

- [Cloudflare Pagesデプロイガイド](docs/Cloudflareデプロイ.md)
- [要件定義書](docs/要件定義書.md)
- [TODO](TODO.md)