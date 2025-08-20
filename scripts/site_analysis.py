#!/usr/bin/env python3
"""
サイト構造調査スクリプト
https://hidemiyoshi.jp/blog/ の構造を分析
"""

import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse
import json
import time
from collections import defaultdict

class BlogAnalyzer:
    def __init__(self, base_url):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        })
        self.results = {
            'sitemap': None,
            'pagination': {},
            'resources': defaultdict(set),
            'external_resources': defaultdict(set),
            'excluded_patterns': set(),
            'article_count_estimate': 0,
            'sample_urls': []
        }
    
    def check_url(self, url):
        """URLの存在確認"""
        try:
            response = self.session.head(url, allow_redirects=True, timeout=10)
            return response.status_code == 200
        except:
            return False
    
    def analyze_page(self, url):
        """ページの詳細分析"""
        try:
            response = self.session.get(url, timeout=10)
            response.raise_for_status()
            soup = BeautifulSoup(response.text, 'html.parser')
            return soup
        except Exception as e:
            print(f"Error fetching {url}: {e}")
            return None
    
    def check_sitemap(self):
        """サイトマップの存在確認"""
        sitemap_urls = [
            urljoin(self.base_url, 'sitemap.xml'),
            urljoin(self.base_url, 'sitemap_index.xml'),
            urljoin(self.base_url, '../sitemap.xml'),  # ルートドメイン
        ]
        
        for sitemap_url in sitemap_urls:
            if self.check_url(sitemap_url):
                self.results['sitemap'] = sitemap_url
                print(f"✅ サイトマップ発見: {sitemap_url}")
                return True
        
        print("❌ サイトマップが見つかりません")
        return False
    
    def analyze_main_page(self):
        """メインページの分析"""
        soup = self.analyze_page(self.base_url)
        if not soup:
            return
        
        # ページネーション構造の確認
        pagination_links = soup.find_all('a', class_=['page-numbers', 'pagination', 'next', 'prev'])
        for link in pagination_links:
            href = link.get('href')
            if href:
                self.results['pagination'][link.text.strip()] = urljoin(self.base_url, href)
        
        # 記事リンクの収集
        article_links = []
        for link in soup.find_all('a', href=True):
            href = urljoin(self.base_url, link['href'])
            if '/blog/' in href and href != self.base_url:
                parsed = urlparse(href)
                if parsed.netloc == urlparse(self.base_url).netloc:
                    article_links.append(href)
        
        # 重複を除去して最初の10件を保存
        unique_articles = list(set(article_links))
        self.results['sample_urls'] = unique_articles[:10]
        self.results['article_count_estimate'] = len(unique_articles)
        
        # リソースの分析
        self.analyze_resources(soup)
        
        # 除外対象パターンの確認
        self.check_excluded_patterns(soup)
    
    def analyze_resources(self, soup):
        """使用されているリソースの分析"""
        base_domain = urlparse(self.base_url).netloc
        
        # CSS
        for link in soup.find_all('link', rel='stylesheet'):
            href = link.get('href')
            if href:
                full_url = urljoin(self.base_url, href)
                domain = urlparse(full_url).netloc
                if domain == base_domain:
                    self.results['resources']['css'].add(full_url)
                else:
                    self.results['external_resources']['css'].add(full_url)
        
        # JavaScript
        for script in soup.find_all('script', src=True):
            src = script.get('src')
            if src:
                full_url = urljoin(self.base_url, src)
                domain = urlparse(full_url).netloc
                if domain == base_domain:
                    self.results['resources']['js'].add(full_url)
                else:
                    self.results['external_resources']['js'].add(full_url)
        
        # 画像
        for img in soup.find_all('img', src=True):
            src = img.get('src')
            if src:
                full_url = urljoin(self.base_url, src)
                domain = urlparse(full_url).netloc
                if domain == base_domain:
                    if '/wp-content/uploads/' in full_url:
                        self.results['resources']['wp_uploads'].add(full_url)
                    else:
                        self.results['resources']['images'].add(full_url)
                else:
                    self.results['external_resources']['images'].add(full_url)
        
        # 外部埋め込み（iframe）
        for iframe in soup.find_all('iframe'):
            src = iframe.get('src')
            if src:
                self.results['external_resources']['embed'].add(src)
    
    def check_excluded_patterns(self, soup):
        """除外すべきURLパターンの確認"""
        excluded_patterns = [
            '/wp-admin/',
            '/wp-login.php',
            '/feed/',
            '/xmlrpc.php',
            '/?s=',  # 検索
            '#comment',
            '#respond',
            '/trackback/',
            '/wp-json/'
        ]
        
        for link in soup.find_all('a', href=True):
            href = link.get('href', '')
            for pattern in excluded_patterns:
                if pattern in href:
                    self.results['excluded_patterns'].add(pattern)
    
    def generate_report(self):
        """調査レポートの生成"""
        report = {
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S'),
            'base_url': self.base_url,
            'sitemap': self.results['sitemap'],
            'pagination': dict(self.results['pagination']),
            'article_count_estimate': self.results['article_count_estimate'],
            'sample_urls': self.results['sample_urls'][:5],
            'resources': {
                'internal': {
                    'css': list(self.results['resources']['css'])[:5],
                    'js': list(self.results['resources']['js'])[:5],
                    'wp_uploads': list(self.results['resources']['wp_uploads'])[:5],
                    'images': list(self.results['resources']['images'])[:5]
                },
                'external': {
                    'css': list(self.results['external_resources']['css'])[:5],
                    'js': list(self.results['external_resources']['js'])[:5],
                    'images': list(self.results['external_resources']['images'])[:5],
                    'embed': list(self.results['external_resources']['embed'])[:5]
                }
            },
            'excluded_patterns_found': list(self.results['excluded_patterns'])
        }
        
        return report

def main():
    print("🔍 サイト構造調査を開始します...")
    print("=" * 50)
    
    analyzer = BlogAnalyzer('https://hidemiyoshi.jp/blog/')
    
    # サイトマップの確認
    print("\n📍 サイトマップの確認...")
    analyzer.check_sitemap()
    
    # メインページの分析
    print("\n📊 メインページの分析...")
    analyzer.analyze_main_page()
    
    # レポート生成
    report = analyzer.generate_report()
    
    # レポート保存
    with open('site_analysis_report.json', 'w', encoding='utf-8') as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
    
    # コンソール出力
    print("\n" + "=" * 50)
    print("📋 調査結果サマリー")
    print("=" * 50)
    print(f"✅ サイトマップ: {report['sitemap'] or '見つかりませんでした'}")
    print(f"✅ 推定記事数: {report['article_count_estimate']}件")
    print(f"✅ ページネーション: {len(report['pagination'])}件のリンク発見")
    
    if report['pagination']:
        print("\n📄 ページネーション構造:")
        for text, url in list(report['pagination'].items())[:5]:
            print(f"  - {text}: {url}")
    
    print("\n🌐 外部リソース:")
    for resource_type, urls in report['resources']['external'].items():
        if urls:
            print(f"  {resource_type}: {len(urls)}件")
            for url in urls[:2]:
                print(f"    - {url}")
    
    print("\n⚠️ 除外パターン検出:")
    for pattern in report['excluded_patterns_found']:
        print(f"  - {pattern}")
    
    print("\n✅ レポートを site_analysis_report.json に保存しました")

if __name__ == "__main__":
    main()