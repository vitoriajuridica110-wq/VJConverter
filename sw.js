/* ============================================================================
   VJ Converter / VJ IMG — Service Worker
   Deixa os dois programas abrirem e funcionarem sem internet depois da
   primeira visita, e permite instalá-los como aplicativo no Windows,
   Android e iOS.

   Regras de privacidade deste arquivo:
   - Nenhum documento, foto ou texto do usuário passa por aqui. O cache
     guarda apenas as páginas do site e as bibliotecas públicas dos CDNs.
   - Requisições para a IA do Google e para o tradutor NUNCA são
     interceptadas nem guardadas (veja NEVER_CACHE abaixo).

   Sempre que publicar uma alteração nos arquivos, troque o número da
   versão abaixo. É isso que faz o navegador buscar a versão nova.
============================================================================ */

const VERSION = 'vj-4.3.1';
const SHELL_CACHE = VERSION + '-shell';
const LIB_CACHE = VERSION + '-libs';

// Arquivos do próprio site, guardados já na instalação.
const SHELL_FILES = [
    './',
    './index.html',
    './img.html',
    './midia.html',
    './manifest.webmanifest',
    './icon-192.png',
    './icon-512.png',
    './apple-touch-icon.png'
];

// Hosts de bibliotecas e modelos que podem ser guardados para uso offline.
const CACHEABLE_HOSTS = [
    'cdn.tailwindcss.com',
    'cdn.jsdelivr.net',
    'cdnjs.cloudflare.com',
    'unpkg.com',
    'fonts.googleapis.com',
    'fonts.gstatic.com',
    'tessdata.projectnaptha.com',  // pacotes de idioma do OCR
    'staticimgly.com'              // modelo da IA de remoção de fundo
];

// Serviços que recebem conteúdo do usuário: o Service Worker se mantém
// totalmente fora do caminho, para não guardar nada que venha deles.
const NEVER_CACHE = [
    'generativelanguage.googleapis.com',
    'translate.googleapis.com'
];

self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(SHELL_CACHE)
            .then(cache => cache.addAll(SHELL_FILES))
            .then(() => self.skipWaiting())
            .catch(() => self.skipWaiting())
    );
});

self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys()
            .then(keys => Promise.all(
                keys.filter(k => k.indexOf(VERSION) !== 0).map(k => caches.delete(k))
            ))
            .then(() => self.clients.claim())
    );
});

self.addEventListener('message', (event) => {
    if (event.data === 'skipWaiting') self.skipWaiting();
});

self.addEventListener('fetch', (event) => {
    const req = event.request;
    if (req.method !== 'GET') return;

    let url;
    try { url = new URL(req.url); } catch (e) { return; }

    if (NEVER_CACHE.indexOf(url.hostname) >= 0) return;

    // Páginas: busca a versão nova primeiro, e só usa o cache se estiver offline.
    if (req.mode === 'navigate') {
        event.respondWith(
            fetch(req)
                .then(res => {
                    const copy = res.clone();
                    caches.open(SHELL_CACHE).then(c => c.put(req, copy)).catch(() => {});
                    return res;
                })
                .catch(() => caches.match(req).then(r => r || caches.match('./index.html')))
        );
        return;
    }

    const sameOrigin = url.origin === self.location.origin;
    const cacheableLib = CACHEABLE_HOSTS.indexOf(url.hostname) >= 0;
    if (!sameOrigin && !cacheableLib) return;

    const cacheName = sameOrigin ? SHELL_CACHE : LIB_CACHE;

    // Bibliotecas e arquivos do site: usa o cache primeiro (abre instantâneo),
    // e atualiza em segundo plano quando houver internet.
    event.respondWith(
        caches.match(req).then(cached => {
            const network = fetch(req).then(res => {
                if (res && (res.status === 200 || res.type === 'opaque')) {
                    const copy = res.clone();
                    caches.open(cacheName).then(c => c.put(req, copy)).catch(() => {});
                }
                return res;
            }).catch(() => cached);
            return cached || network;
        })
    );
});
