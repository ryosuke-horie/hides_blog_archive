# 🚀 クイックスタートガイド

## 3ステップで完了！

### ステップ1: テスト実行（1分）
```bash
# リポジトリをクローン
git clone https://github.com/ryosuke-horie/hides_blog_archive.git
cd hides_blog_archive

# テストミラーリング（5ページだけ）
./scripts/test_mirror.sh
```

### ステップ2: 確認（10秒）
```bash
# ローカルサーバー起動
cd test_mirror/blog
python3 -m http.server 8000
```
ブラウザで http://localhost:8000 を開いて確認

### ステップ3: 本番実行（30-60分）
```bash
# プロジェクトルートに戻る
cd ../../

# 全記事ミラーリング
./scripts/production_mirror.sh
```

## 🎯 完了！

ミラーリングが完了したら、以下のコマンドでCloudflare Pagesにデプロイ：

```bash
npx wrangler pages deploy production_mirror/blog --project-name=hides-blog
```

これだけです！🎉