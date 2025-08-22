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

### 2. ミラーサイトの確認

`simple_mirror/` ディレクトリに完全なミラーサイトが含まれています：
- 総ファイル数: 3,750ファイル
- HTMLファイル: 582記事
- 合計サイズ: 488MB
- 期間: 2011年〜2025年の全記事

### 3. ローカルテスト

```bash
# ミラーサイトをローカルで確認
cd simple_mirror
python3 -m http.server 8000
# ブラウザで http://localhost:8000/blog/ にアクセス
```

## ☁️ Cloudflare Pages へのデプロイ

### 方法1: CLIで即デプロイ（最速）
```bash
# Wranglerで直接デプロイ
npx wrangler pages deploy simple_mirror --project-name=hides-blog-static
```

詳細は [Cloudflareデプロイ.md](docs/Cloudflareデプロイ.md) を参照。

## 📁 ディレクトリ構造

```
hides_blog_archive/
├── README.md                    # このファイル
├── TODO.md                      # タスク管理
├── docs/
│   ├── Cloudflareデプロイ.md   # デプロイガイド
│   └── 要件定義書.md            # プロジェクト要件
├── scripts/
│   └── complete_mirror.sh       # ミラーリングスクリプト（参考）
└── simple_mirror/               # ミラーサイト（488MB、動作確認済み）
    ├── blog/                    # ブログコンテンツ（582記事）
    ├── wp-content/              # テーマ、CSS、画像
    └── wp-includes/             # JavaScript、CSS
```

## 📊 ミラーサイト詳細

### `simple_mirror/` ディレクトリ
完全なWordPressブログのミラーサイト：

- **総ファイル数**: 3,750ファイル
- **記事数**: 582記事（HTMLファイル）
- **合計サイズ**: 488MB
- **期間**: 2011年〜2025年の全記事
- **コンテンツ**: テキスト、画像、CSS、JavaScript全て含む

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


## 📊 パフォーマンス

- **記事数**: 582記事
- **サイズ**: 488MB
- **表示速度**: 静的ファイルのため超高速
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