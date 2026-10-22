# Web hosting

The normal release command is supported:

```sh
flutter build web --release
node tools/verify_web_build.mjs
```

Increase the version or build number in `pubspec.yaml` for each release, as usual. Upload the **complete contents of `build/web`** to the deployment repository, including `version.json`, `app_update.js`, `flutter_bootstrap.js`, and `flutter_service_worker.js`. Have CI run the verification command if it has access to this source repository. Firebase deploys run it automatically through the hosting predeploy hook. No hosting deployment is performed by the build or verification commands.

The optional `bash tools/build_web.sh --no-pub` wrapper adds a unique release ID on every build, so even builds with an unchanged pubspec version trigger updates. It requires Node.js, uses the pinned local Flutter SDK (or `FLUTTER_BIN`), and forwards Flutter build arguments. It stamps the same ID into HTML and `version.json`; startup passes it to bootstrap. Both build commands write to `build/web`; deploy that directory as a unit.

## New build detection

On page load, a fresh startup script reads Flutter's `version.json` with caching disabled. Plain Flutter builds use its `version` and `build_number`; wrapper builds use its additional `release_id`. Startup then loads bootstrap and compiled entrypoints using release-specific URLs. The update checker no longer depends on a custom `APP_VERSION` substitution being supplied to Flutter.

Open tabs check `version.json` every minute while visible and when users return to the tab or reconnect. A changed release reloads the current route, preserving query parameters and fragments. As before, an automatic reload can discard unsaved forms or interrupt an upload. Invalid responses, failed requests, and offline checks do not trigger a reload. A failed initial check still starts Flutter after the request fails or the ten-second timeout expires. The `_app_update` navigation parameter bypasses cached HTML and prevents repeated reloads if a CDN continues serving stale HTML.

The startup controller gets a fresh URL on every page load. Bootstrap and compiled entrypoints use `?release=...`, rather than the `?v=...` parameter stripped by legacy Flutter caching workers. Startup also asks an existing Flutter worker to update to Flutter's generated cleanup stub. It does not unregister Firebase messaging or clear login/session storage.

## Hostinger deployment for partner.privatedeals.in

This app is uploaded through a separate GitHub Actions deployment repository to Hostinger. On 2026-10-14, the public server reported `server: nginx`, no Cache-Control header on `/`, and `Cache-Control: max-age=315360000` plus a 2037 Expires date on `main.dart.js`. That is a ten-year script cache lifetime. Firebase configuration and Apache `.htaccess` files do not configure this nginx server.

In the existing nginx virtual host for `partner.privatedeals.in`, replace `expires max` / the long-lived Cache-Control policy in the matching static-file location with:

```nginx
expires off;
add_header Cache-Control "no-cache, max-age=0, must-revalidate" always;
```

Apply that same policy to the existing `location /` (including the SPA fallback), `index.html`, `version.json`, JavaScript, Wasm, and Flutter assets. Keep the existing TLS settings, root directory, routing and security headers. Put these directives in the locations that actually serve these files; a separate static-file location can override server-level or `location /` settings. Preserve existing security `add_header` directives when editing a location, since nginx header inheritance depends on that location's directives.

Validate the server configuration with `nginx -t` and reload nginx through the existing deployment/admin process. Purge any enabled hosting/CDN cache once after this change. This repository does not contain that deployment workflow or server configuration, so the server change must be applied there. Hostinger documents [Cache-Control customization](https://www.hostinger.com/support/8052370-advanced-cdn-header-management-at-hostinger/) and [its separate server/CDN caches](https://www.hostinger.com/support/6215624-how-to-use-cache-manager-at-hostinger/).

## Hosting cache headers

The hosting server must revalidate HTML, SPA routes, scripts, manifests and assets, since Flutter reuses these filenames:

```text
Cache-Control: no-cache, max-age=0, must-revalidate
```

The included `firebase.json` config applies this policy to all files. **If CI deploys to another host, apply the equivalent response header there**; uploading `build/web` alone does not apply Firebase configuration. Invalidate any CDN rules that override the policy. Check the actual response headers for `/`, a direct application route, `version.json`, `flutter_bootstrap.js`, and `main.dart.js`.

This follows Flutter's [web caching guidance](https://docs.flutter.dev/platform-integration/web/faq#how-do-i-configure-my-cache-headers).

Upload releases atomically (Firebase Hosting does this), rather than replacing files in a live directory one at a time. Keep the generated `flutter_service_worker.js` cleanup file available for browsers with a legacy Flutter worker. Keep the separate Firebase messaging worker too.

Already-open tabs running code from before this fix cannot acquire new update logic without loading the fixed release once. Changing hosting headers cannot retroactively expire an already-cached response. A normal navigation should receive the fix with correct hosting headers; if the host/CDN still serves stale HTML, correct that configuration and invalidate its cache.

## Verification

Run `node --test test/web_update_test.mjs`, build the release, and run `node tools/verify_web_build.mjs`. For staging acceptance, keep one release open, deploy a second release with an increased pubspec version/build number, and confirm an automatic reload within a minute or on returning to the tab. Also verify that normal refresh loads the latest app. The route and login should be preserved. The same check can use two wrapper builds without changing pubspec.

Flutter uses path URLs. A server must send `index.html` when an application route does not match a static file. For example, in an existing nginx server block:

```nginx
location / {
  try_files $uri $uri/ /index.html;
  add_header Cache-Control "no-cache, max-age=0, must-revalidate" always;
}
```

Apply the cache headers to static-file locations too if nginx has separate matching location blocks. For a subdirectory deployment, pass `--base-href /your-path/` to the build command and adapt the server fallback to that path. Test direct refresh and pasted URLs for Institution companies/deals, shared CML and Partner catalog detail pages.

Use HTTPS. Configure API CORS to allow the deployment origin, `headtoken`, `Authorization`, and the device/user headers used by the client. Ensure OPTIONS preflights are accepted. Avoid caching authenticated API responses.

The Partner Firebase project/configuration is retained. Review authorized domains and notification service-worker configuration for the hosting origin. The app uses the Partner logo assets directly; its PWA icon URLs are relative to the configured base path.
