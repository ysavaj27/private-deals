(() => {
  'use strict';

  const currentVersion = document.querySelector('meta[name="app-version"]')?.content;
  const validVersion = (value) => typeof value === 'string' && /^[a-zA-Z0-9_.+-]{1,100}$/.test(value);
  // Plain flutter run/build remains usable without release update checks.
  if (!validVersion(currentVersion)) return;

  let checking = false;
  let reloading = false;
  let lastCheck = 0;

  function reloadForUpdate(version) {
    // Keep the route, existing query parameters, and fragment. The unique
    // navigation URL bypasses an HTML response cached by a previous release.
    const url = new URL(window.location.href);
    // A misconfigured CDN may still return stale HTML. Do not reload forever.
    if (url.searchParams.get('_app_update') === version) return;
    reloading = true;
    url.searchParams.set('_app_update', version);
    window.location.replace(url.href);
  }

  async function checkForUpdate() {
    if (checking || reloading || document.visibilityState === 'hidden' || navigator.onLine === false) return;
    if (Date.now() - lastCheck < 10000) return;
    lastCheck = Date.now();
    checking = true;
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 10000);
    try {
      const url = new URL('index.html', document.baseURI);
      url.searchParams.set('_update_check', Date.now().toString());
      const response = await fetch(url, { cache: 'no-store', signal: controller.signal });
      if (!response.ok) return;
      const page = new DOMParser().parseFromString(await response.text(), 'text/html');
      const version = page.querySelector('meta[name="app-version"]')?.content;
      if (!validVersion(version)) return;
      if (version !== currentVersion) {
        reloadForUpdate(version);
      }
    } catch (_) {
      // Offline, timeout, or a deployment in progress: retry on the next check.
    } finally {
      clearTimeout(timeout);
      checking = false;
    }
  }

  setInterval(checkForUpdate, 60000);
  document.addEventListener('visibilitychange', checkForUpdate);
  window.addEventListener('focus', checkForUpdate);
  window.addEventListener('online', checkForUpdate);
  checkForUpdate();
})();
