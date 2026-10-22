(() => {
  'use strict';

  const validVersion = (value) => typeof value === 'string' && /^[a-zA-Z0-9_.+-]{1,100}$/.test(value);
  const stampedVersion = document.querySelector('meta[name="app-version"]')?.content;
  let currentVersion = validVersion(stampedVersion) ? stampedVersion : null;
  let checking = false;
  let reloading = false;
  let started = false;
  let lastCheck = 0;

  function startApp() {
    if (started || reloading) return;
    started = true;
    // A plain Flutter build has no APP_VERSION substitution. Its version.json
    // supplies the version/build number instead. On network failure, a fresh
    // URL still lets the Flutter loader attempt startup without stale scripts.
    window.privateDealsRelease = currentVersion || Date.now().toString();
    const script = document.createElement('script');
    const url = new URL('flutter_bootstrap.js', document.baseURI);
    url.searchParams.set('release', window.privateDealsRelease);
    script.src = url.href;
    script.async = true;
    document.body.appendChild(script);
  }

  function reloadForUpdate(version) {
    const url = new URL(window.location.href);
    // Preserve the route and prevent loops if a CDN returns stale HTML.
    if (!started && url.searchParams.get('_app_update') === version) {
      // Even with stale HTML, startup must select the deployed bundle.
      currentVersion = version;
      return;
    }
    reloading = true;
    url.searchParams.set('_app_update', version);
    window.location.replace(url.href);
  }

  async function checkForUpdate() {
    if (checking || reloading) return;
    if (started && (document.visibilityState === 'hidden' || navigator.onLine === false)) return;
    if (Date.now() - lastCheck < 10000) return;
    lastCheck = Date.now();
    checking = true;
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 10000);
    try {
      const url = new URL('version.json', document.baseURI);
      url.searchParams.set('_update_check', Date.now().toString());
      const response = await fetch(url, { cache: 'no-store', signal: controller.signal });
      if (!response.ok) return;
      const metadata = await response.json();
      const version = metadata.release_id || (
        validVersion(metadata.version) && validVersion(metadata.build_number)
          ? `${metadata.version}+${metadata.build_number}` : null
      );
      if (!validVersion(version)) return;
      if (currentVersion && version !== currentVersion) {
        reloadForUpdate(version);
      } else {
        currentVersion = version;
      }
    } catch (_) {
      // Offline, timeout, or a partial deployment: retry on the next check.
    } finally {
      clearTimeout(timeout);
      checking = false;
      startApp();
    }
  }

  setInterval(checkForUpdate, 60000);
  document.addEventListener('visibilitychange', checkForUpdate);
  window.addEventListener('focus', checkForUpdate);
  window.addEventListener('online', checkForUpdate);
  checkForUpdate();
})();
