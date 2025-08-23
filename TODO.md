# TODO: ブログミラーリングのリンク問題修正

## 🚨 現状の問題

デプロイ先（https://hides-blog-static.pages.dev/blog/）で、記事リンクをクリックすると以下の問題が発生：
- URLが `https://hides-blog-static.pages.dev/blog/?p=2243` のようなクエリパラメーター形式になる
- 結果として記事ページではなくトップページが表示される

## 🔍 問題の原因分析

### 1. wgetの挙動
- 現在の設定では `--convert-links` を使用しているが、これがクエリパラメーター付きURLを生成している可能性
- `--adjust-extension` と `--html-extension` の競合の可能性

### 2. WordPressの構造
- 元サイト: `https://hidemiyoshi.jp/blog/YEAR/MONTH/記事タイトル.html` 形式
- ミラーサイト: リンクが `index.html%3Fp=XXXX.html` に変換されている

### 3. 根本原因
- wgetが記事を取得する際、WordPressの内部リンク（`?p=`形式）も取得してしまっている
- `--convert-links` オプションがこれらのリンクを相対パスに変換する際に問題が発生

## 📋 修正方針: 後処理でリンクを修正

1. ミラーリング完了後、HTMLファイル内のリンクを検索・置換
2. `href="index.html%3Fp=XXXX.html"` 形式のリンクを正しいパスに修正
3. 外部サイトへのリンク（`?p=`形式）はそのまま保持

## 🛠 実装手順

### ステップ1: 問題の確認
- 449個のHTMLファイルに`?p=`形式のリンクが含まれている
- 主に外部サイトへのリンク（regasu-shinjuku.or.jp等）
- 内部リンクは正常（相対パス形式）

### ステップ2: リンク修正スクリプトの作成
```bash
# fix_broken_links.sh スクリプトを作成
# 外部リンクはそのまま保持（問題なし）
# 内部の壊れたリンクのみ修正対象とする
```

### ステップ3: テストと検証
```bash
# ローカルでテスト
cd simple_mirror && python3 -m http.server 8000

# 修正されたリンクが正しく動作することを確認
```

## ✅ 次のアクション

1. [ ] デプロイサイトで実際に問題となっているリンクを特定
2. [ ] リンク修正スクリプト（fix_broken_links.sh）を作成
3. [ ] スクリプトを実行して問題を修正
4. [ ] Cloudflare Pagesに再デプロイ
5. [ ] 動作確認

## 📌 重要な発見

- `?p=`を含む449個のファイルは主に外部サイトへのリンク（問題なし）
- デプロイサイトでの問題は別の原因の可能性
- 実際のデプロイサイトでのリンク構造を詳細に調査する必要がある

## 📊 現在の状態（更新前）

- **ミラーサイト**: `simple_mirror/` 488MB（動作確認済み、582記事）
- **ミラーリングスクリプト**: `./scripts/mirror_blog.sh`（問題あり）
- **デプロイコマンド**: `npx wrangler pages deploy simple_mirror --project-name=hides-blog-static`
- **ローカルテスト**: `cd simple_mirror && python3 -m http.server 8000`