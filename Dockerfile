# browsertrix-crawlerのDockerイメージを使用
# 最新の安定版を使用
FROM webrecorder/browsertrix-crawler:latest

# 作業ディレクトリの設定
WORKDIR /crawls

# 日本語フォントのインストール（日本語サイトのスクリーンショット対応）
USER root
RUN apt-get update && \
    apt-get install -y fonts-noto-cjk fonts-ipafont-gothic fonts-ipafont-mincho && \
    fc-cache -fv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# crawlerユーザーに戻す
USER crawler

# デフォルトのエントリーポイントを使用
ENTRYPOINT ["crawl"]