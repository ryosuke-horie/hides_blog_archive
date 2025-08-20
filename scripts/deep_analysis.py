#!/usr/bin/env python3
"""
詳細なサイト分析スクリプト
ページネーションを辿って全記事数を取得
"""

import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin
import json

def analyze_pagination():
    """ページネーションを辿って記事総数を把握"""
    base_url = "https://hidemiyoshi.jp/blog/"
    session = requests.Session()
    session.headers.update({
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
    })
    
    # 最終ページ（45ページ）を確認
    last_page_url = "https://hidemiyoshi.jp/blog/page/45"
    print(f"🔍 最終ページを確認: {last_page_url}")
    
    try:
        response = session.get(last_page_url, timeout=10)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # 記事リンクをカウント
        articles = soup.find_all('article')
        articles_on_last_page = len(articles)
        
        # より詳細な記事要素の検出
        if articles_on_last_page == 0:
            # 別の方法で記事を検出
            entry_titles = soup.find_all(class_=['entry-title', 'post-title'])
            articles_on_last_page = len(entry_titles)
        
        # 総記事数の計算（44ページ × 10記事 + 最終ページの記事数）
        total_articles = (44 * 10) + articles_on_last_page
        
        print(f"✅ 最終ページの記事数: {articles_on_last_page}")
        print(f"✅ 推定総記事数: {total_articles}")
        
        # 除外対象の詳細確認
        excluded_links = []
        for link in soup.find_all('a', href=True):
            href = link.get('href', '')
            if any(pattern in href for pattern in ['/wp-admin/', '/wp-login.php', '/feed/', '/?s=']):
                excluded_links.append(href)
        
        return {
            'total_pages': 45,
            'articles_on_last_page': articles_on_last_page,
            'estimated_total_articles': total_articles,
            'excluded_links_found': len(set(excluded_links))
        }
        
    except Exception as e:
        print(f"❌ エラー: {e}")
        return None

def check_specific_resources():
    """特定のリソースの詳細確認"""
    base_url = "https://hidemiyoshi.jp/blog/"
    session = requests.Session()
    session.headers.update({
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
    })
    
    print("\n📦 リソース依存関係の詳細調査...")
    
    # サンプル記事ページを取得
    sample_url = "https://hidemiyoshi.jp/blog/2025/08/%e4%b9%85%e3%80%85%e3%83%88%e3%83%ac%e3%83%93%e3%83%a5%e3%83%ac%e3%83%bc%e3%83%88%e3%80%82hides%e3%81%aemma%e3%81%af%e3%81%93%e3%81%93%e3%81%8b%e3%82%89%e5%a7%8b%e3%81%be%e3%81%a3%e3%81%9f%e6%80%9d.html"
    
    try:
        response = session.get(sample_url, timeout=10)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # jQuery依存の確認
        jquery_scripts = [s for s in soup.find_all('script', src=True) if 'jquery' in s.get('src', '').lower()]
        
        # WordPressテーマ/プラグインの確認
        wp_resources = {
            'theme': [],
            'plugins': [],
            'core': []
        }
        
        for link in soup.find_all(['link', 'script'], src=True) + soup.find_all(['link', 'script'], href=True):
            url = link.get('src') or link.get('href', '')
            if '/wp-content/themes/' in url:
                wp_resources['theme'].append(url)
            elif '/wp-content/plugins/' in url:
                wp_resources['plugins'].append(url)
            elif '/wp-includes/' in url:
                wp_resources['core'].append(url)
        
        # 外部埋め込みコンテンツ
        embeds = []
        for iframe in soup.find_all('iframe'):
            src = iframe.get('src', '')
            if src:
                if 'youtube' in src.lower():
                    embeds.append({'type': 'YouTube', 'url': src})
                elif 'twitter' in src.lower() or 'x.com' in src:
                    embeds.append({'type': 'Twitter/X', 'url': src})
                elif 'instagram' in src.lower():
                    embeds.append({'type': 'Instagram', 'url': src})
                else:
                    embeds.append({'type': 'Other', 'url': src})
        
        return {
            'jquery_found': len(jquery_scripts) > 0,
            'jquery_scripts': [s.get('src') for s in jquery_scripts][:3],
            'wp_theme_resources': len(wp_resources['theme']),
            'wp_plugin_resources': len(wp_resources['plugins']),
            'wp_core_resources': len(wp_resources['core']),
            'external_embeds': embeds
        }
        
    except Exception as e:
        print(f"❌ エラー: {e}")
        return None

def main():
    print("🔬 詳細サイト分析を開始...")
    print("=" * 50)
    
    # ページネーション分析
    pagination_result = analyze_pagination()
    
    # リソース詳細分析
    resource_result = check_specific_resources()
    
    # 結果をまとめる
    final_report = {
        'pagination_analysis': pagination_result,
        'resource_analysis': resource_result
    }
    
    # レポート保存
    with open('deep_analysis_report.json', 'w', encoding='utf-8') as f:
        json.dump(final_report, f, ensure_ascii=False, indent=2)
    
    print("\n" + "=" * 50)
    print("📊 分析結果サマリー")
    print("=" * 50)
    
    if pagination_result:
        print(f"📚 総ページ数: {pagination_result['total_pages']}ページ")
        print(f"📝 推定総記事数: {pagination_result['estimated_total_articles']}記事")
    
    if resource_result:
        print(f"\n💻 jQuery使用: {'あり' if resource_result['jquery_found'] else 'なし'}")
        print(f"🎨 テーマリソース: {resource_result['wp_theme_resources']}個")
        print(f"🔌 プラグインリソース: {resource_result['wp_plugin_resources']}個")
        print(f"📦 WordPressコア: {resource_result['wp_core_resources']}個")
        
        if resource_result['external_embeds']:
            print("\n🌐 外部埋め込みコンテンツ:")
            for embed in resource_result['external_embeds']:
                print(f"  - {embed['type']}: {embed['url'][:50]}...")
    
    print("\n✅ 詳細レポートを deep_analysis_report.json に保存しました")

if __name__ == "__main__":
    main()