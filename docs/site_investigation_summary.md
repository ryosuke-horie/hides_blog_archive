# サイト調査結果サマリー

## 📊 サイト概要

- **対象URL**: https://hidemiyoshi.jp/blog/
- **サイトマップ**: なし
- **推定総記事数**: 約440記事
- **総ページ数**: 45ページ（1ページあたり10記事）

## 📄 URL構造

### ページネーション
- パターン: `/blog/page/{番号}`
- 例: `https://hidemiyoshi.jp/blog/page/2`
- 最終ページ: `https://hidemiyoshi.jp/blog/page/45`

### 記事URL
- パターン: `/blog/{年}/{月}/{記事タイトル}.html`
- 例: `https://hidemiyoshi.jp/blog/2025/08/久々トレビュレート。hidesのmmaはここから始まった思.html`

## 🌐 リソース依存関係

### 内部リソース
- **WordPress Core**: `/wp-includes/` 配下のJS/CSS
- **テーマ**: `/wp-content/themes/colibri-wp/` 
- **画像**: `/wp-content/uploads/{年}/{月}/` 形式で保存

### 外部リソース
- **Google Fonts**: フォント読み込み
- **CDN**: 
  - wp-slimstat (cdn.jsdelivr.net)
- **トラッキング**: 
  - Google Tag Manager (GTM-KTPXLT4)

### JavaScript依存
- **jQuery**: 使用あり（WordPress標準）
- **その他**: imagesloaded, masonry等のライブラリ

## ⚠️ 除外すべきURL

確認された除外パターン:
- `#respond` - コメント返信リンク
- `/wp-admin/` - 管理画面（リンクなし）
- `/wp-login.php` - ログイン画面（リンクなし）
- `/feed/` - RSSフィード（リンクなし）
- `/?s=` - 検索クエリ（フォームあり）

## 📝 クロール設定への推奨事項

1. **Seeds設定**
   - メインURL: `https://hidemiyoshi.jp/blog/`
   - ページネーションを自動で辿るため追加seedsは不要

2. **Scope設定**
   - scopeType: `prefix`
   - 対象: `/blog/` 配下のみ

3. **除外設定**
   ```
   - .*#respond.*
   - .*#comment.*
   - .*\?s=.*
   - .*/wp-admin/.*
   - .*/wp-login\.php
   - .*/feed/.*
   ```

4. **リソース取得**
   - 外部CDN（Google Fonts, jsdelivr.net）は自動取得
   - GTMは除外しても問題なし（アナリティクス用）

5. **推定容量**
   - 記事数: 約440記事
   - 画像あり（scaled画像使用）
   - 推定サイズ: 100MB-500MB（画像次第）