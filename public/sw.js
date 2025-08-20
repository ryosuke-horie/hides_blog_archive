// Service Worker for ReplayWeb.page
// This is required for offline functionality

self.addEventListener('install', (event) => {
    console.log('Service Worker installing...');
    self.skipWaiting();
});

self.addEventListener('activate', (event) => {
    console.log('Service Worker activated');
    event.waitUntil(clients.claim());
});

// ReplayWeb.pageが独自のService Worker処理を行うため、
// ここでは基本的な設定のみ