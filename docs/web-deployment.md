# Web hosting

Build with `bash tools/build_web.sh --no-pub`. The wrapper uses the pinned local Flutter SDK (or `FLUTTER_BIN` when set), reads the full version from `pubspec.yaml`, and forwards extra Flutter build arguments. Publish the complete contents of `build/web` only after authenticated staging acceptance. This task does not deploy the app.

## New build detection

Open tabs check the deployed `index.html` every minute while visible and when the user returns to the tab or reconnects. A changed version automatically reloads the current route without a notification or confirmation. This can discard unsaved forms or interrupt uploads. Network errors and invalid responses are ignored until the next check. The `_app_update` URL parameter bypasses cached HTML and prevents repeated reloads if a misconfigured CDN continues serving an old page.

The full `pubspec.yaml` version (for example `1.2.0+15`) is embedded at build time using Flutter's `--web-define`. Bump the version or build number before each deployment; uploading the same version again does not trigger an automatic reload. The build wrapper rejects `--build-name` and `--build-number` overrides to keep Flutter metadata consistent with the version used for update detection. Bootstrap, update-checker, and compiled entrypoint URLs include the version to bypass old browser caches. A plain `flutter build web` without `APP_VERSION` still runs but disables update detection; use the wrapper for deployments.

Firebase Hosting now revalidates all files (`max-age=0, must-revalidate`), including SPA routes, scripts, manifests, and assets. This is necessary because these filenames are reused across releases. Unchanged resources can receive a lightweight 304 response. Deploy the hosting configuration as well as the build files. For other hosting providers, apply the equivalent headers and invalidate any CDN rules that override them.

This follows Flutter's [web caching guidance](https://docs.flutter.dev/platform-integration/web/faq#how-do-i-configure-my-cache-headers).

Upload releases atomically (Firebase Hosting does this), rather than replacing files in a live directory one at a time. Keep Flutter's generated `flutter_service_worker.js` cleanup file in the deployment for browsers with a legacy Flutter worker. Do not remove the separate Firebase messaging worker or clear user session storage.

Existing tabs that predate this feature cannot detect updates until they load this release once. Previously cached files may require a one-time refresh/cache reset during the migration; changing server headers cannot retroactively expire a browser's already-cached response.

Verify with `node --test test/web_update_test.mjs`, then build two releases with different pubspec versions: keep the first open, deploy the second, and confirm it automatically reloads within a minute (or on returning to the tab). It should preserve the URL route and load the second build. Check the network response headers on both a direct route and `main.dart.js`.

Flutter uses path URLs. A server must send `index.html` when an application route does not match a static file. For example, in an existing nginx server block:

```nginx
location / {
  try_files $uri $uri/ /index.html;
  add_header Cache-Control "max-age=0, must-revalidate" always;
}
```

Use HTTPS. Configure API CORS to allow the deployment origin, `headtoken`, `Authorization`, and the device/user headers used by the client. Ensure OPTIONS preflights are accepted. Avoid caching authenticated API responses. Keep `index.html`, Flutter bootstrap metadata, and the manifest fresh when deploying updates.

For a subdirectory deployment, use `bash tools/build_web.sh --base-href /your-path/` and adapt the server fallback to that same path. Apply the cache headers to static-file locations too if nginx has separate matching location blocks. Test direct refresh and pasted URLs for Institution companies/deals, shared CML and Partner catalog detail pages.

The Partner Firebase project/configuration is retained. Review authorized domains and notification service-worker configuration for the new hosting origin. The app uses the Partner logo assets directly; its PWA icon URLs are relative to the configured base path.
