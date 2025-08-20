# CLAUDE.md

このファイルは、このリポジトリでコードを扱う際のClaude Code (claude.ai/code)への指針を提供します。

## プロジェクト概要

WordPressブログ（`https://hidemiyoshi.jp/blog/`）を静的なWACZアーカイブとして保存し、Cloudflare Pagesでデプロイするシステムプロジェクトです。現在は計画フェーズで、実装はまだ開始されていません。

## システムアーキテクチャ

計画されているアーキテクチャ：
- **アーカイブ収集**: browsertrix-crawlerを使用してWordPressブログからWACZファイルを作成
- **再生UI**: ReplayWeb.pageでアーカイブコンテンツを閲覧
- **ホスティング**: Cloudflare Pages + R2ストレージ（大容量ファイル用）
- **アーカイブ形式**: WACZ（Web Archive Collection Zipped）

## 主要要件

要件定義書.mdより：
- アーカイブ範囲：`/blog/`サブディレクトリのみ（ドメイン全体ではない）
- アーカイブ形式：オフライン閲覧可能なWACZ形式
- サイズ最適化：可能であれば25MB以下を目標
- デプロイ：Service Worker対応のCloudflare Pages静的ホスティング
- 品質：テキスト、画像、基本的なフォーマットの保持が必須

## 開発時の注意点

新規プロジェクトのため、実装時は以下の順序で進める：
1. WordPressブログ用のbrowsertrix-crawler設定のセットアップ
2. 適切なクロール設定でのWACZ生成の実装
3. アーカイブ再生用のReplayWeb.page統合
4. Service Worker対応のCloudflare Pagesデプロイ設定
5. アーカイブが25MBを超える場合はR2ストレージ統合を検討