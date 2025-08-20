#!/usr/bin/env python3
"""
Range Request対応の開発サーバー
WACZファイルの部分読み込みに必要
"""

import http.server
import socketserver
import os
import sys
from pathlib import Path

class RangeRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Range Requestに対応したHTTPハンドラー"""
    
    def end_headers(self):
        # CORS対応
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        # Range Request対応
        self.send_header('Accept-Ranges', 'bytes')
        super().end_headers()
    
    def do_GET(self):
        """GETリクエストの処理（Range対応）"""
        path = self.translate_path(self.path)
        
        if not os.path.exists(path) or not os.path.isfile(path):
            super().do_GET()
            return
        
        # Rangeヘッダーの確認
        range_header = self.headers.get('Range')
        if not range_header:
            super().do_GET()
            return
        
        # ファイルサイズ取得
        file_size = os.path.getsize(path)
        
        # Range解析（簡易版）
        try:
            range_str = range_header.replace('bytes=', '')
            range_parts = range_str.split('-')
            start = int(range_parts[0]) if range_parts[0] else 0
            end = int(range_parts[1]) if range_parts[1] else file_size - 1
        except:
            super().do_GET()
            return
        
        # 範囲チェック
        if start >= file_size or end >= file_size:
            self.send_response(416)  # Range Not Satisfiable
            self.send_header('Content-Range', f'bytes */{file_size}')
            self.end_headers()
            return
        
        # 部分レスポンス
        self.send_response(206)  # Partial Content
        self.send_header('Content-Type', self.guess_type(path))
        self.send_header('Content-Length', str(end - start + 1))
        self.send_header('Content-Range', f'bytes {start}-{end}/{file_size}')
        self.end_headers()
        
        # ファイルの部分送信
        with open(path, 'rb') as f:
            f.seek(start)
            remaining = end - start + 1
            while remaining > 0:
                chunk_size = min(64 * 1024, remaining)
                chunk = f.read(chunk_size)
                if not chunk:
                    break
                self.wfile.write(chunk)
                remaining -= len(chunk)
    
    def do_OPTIONS(self):
        """OPTIONSリクエストの処理（CORS対応）"""
        self.send_response(200)
        self.end_headers()

def main():
    PORT = 8000
    
    # publicディレクトリに移動
    public_dir = Path(__file__).parent.parent / 'public'
    if public_dir.exists():
        os.chdir(public_dir)
        print(f"📁 Serving from: {public_dir}")
    else:
        print(f"❌ Public directory not found: {public_dir}")
        sys.exit(1)
    
    # サーバー起動
    with socketserver.TCPServer(("", PORT), RangeRequestHandler) as httpd:
        httpd.allow_reuse_address = True
        print(f"🚀 Range Request対応サーバー起動")
        print(f"📍 URL: http://localhost:{PORT}")
        print(f"✨ Features:")
        print(f"   - Range Request対応（WACZファイルの部分読み込み）")
        print(f"   - CORS対応")
        print(f"   - Service Worker対応")
        print(f"\n⚠️  Ctrl+C で停止")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n👋 サーバーを停止しました")

if __name__ == "__main__":
    main()