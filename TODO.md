# TODO

## 📝 未完了タスク

### 最優先
- [ ] Cloudflare Pagesへの本番デプロイ実施
- [ ] デプロイ後の動作確認（全ページアクセステスト）

### デプロイ完了後
- [ ] mirror_blog.shスクリプトを削除（リリース後は不要）

### 将来的な改善  
- [ ] 画像最適化（WebP変換）
- [ ] ページ読み込み速度の測定と改善

## ✅ 完了済み

- 静的HTMLミラーリング方式確立
- 日本語ファイル名問題解決
- CSS/JSパス修正
- プロジェクト整理
- ドキュメント整理
- .DS_Store対策
- simple_mirrorディレクトリに統一（complete_mirror削除）
- ドキュメントをsimple_mirror使用に完全統一
- complete_mirror.shスクリプト削除

## 📌 現在の状態

- **ミラーサイト**: `simple_mirror/` 488MB（動作確認済み、582記事）
- **ミラーリングスクリプト**: `./scripts/mirror_blog.sh`（リリースまでの更新用）
- **デプロイコマンド**: `npx wrangler pages deploy simple_mirror --project-name=hides-blog-static`
- **ローカルテスト**: `cd simple_mirror && python3 -m http.server 8000`