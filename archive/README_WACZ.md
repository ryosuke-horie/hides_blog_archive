# WACZアーカイブ方式について（参考資料）

## 注意
このドキュメントは参考資料として保存されています。
現在のプロジェクトでは**静的HTMLミラーリング方式**を採用しています。

## WACZアーカイブ方式とは

browsertrix-crawlerを使用してWebサイトをWACZ（Web Archive Collection Zipped）形式で保存し、ReplayWeb.pageビューアーで再生する方式です。

### メリット
- 動的コンテンツも保存可能
- JavaScriptの動作も記録
- 完全な状態のアーカイブ

### デメリット
- ReplayWeb.pageビューアーが必要（ブラウザ内ブラウザ）
- ファイルサイズが大きい
- 表示が複雑

## 関連ファイル（アーカイブ済み）

- `Dockerfile` - browsertrix-crawler用
- `docker-compose.yml` - Docker設定
- `config/` - クロール設定
- `public/` - ReplayWeb.page UI
- `crawls/` - クロール結果

## 静的HTMLミラーリング方式への移行理由

1. **シンプルな表示** - オリジナルと同じ見た目
2. **高速** - 静的ファイルのため非常に高速
3. **管理が簡単** - 通常のHTMLファイルとして扱える
4. **デプロイが容易** - 任意の静的ホスティングで公開可能

---

このアプローチは将来的に動的コンテンツの保存が必要になった場合の参考として残しています。