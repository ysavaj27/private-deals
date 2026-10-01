# Web hosting

Build with `flutter build web --release`. Publish the contents of `build/web` only after authenticated staging acceptance. This task does not deploy the app.

Flutter uses path URLs. A server must send `index.html` when an application route does not match a static file. For example, in an existing nginx server block:

```nginx
location / {
  try_files $uri $uri/ /index.html;
}
location = /index.html {
  add_header Cache-Control "no-cache";
}
```

Use HTTPS. Configure API CORS to allow the deployment origin, `headtoken`, `Authorization`, and the device/user headers used by the client. Ensure OPTIONS preflights are accepted. Avoid caching authenticated API responses. Keep `index.html`, Flutter bootstrap metadata, and the manifest fresh when deploying updates.

For a subdirectory deployment, use `flutter build web --base-href /your-path/` and adapt the server fallback to that same path. Test direct refresh and pasted URLs for Institution companies/deals, shared CML and Partner catalog detail pages.

The Partner Firebase project/configuration is retained. Review authorized domains and notification service-worker configuration for the new hosting origin. The app uses the Partner logo assets directly; its PWA icon URLs are relative to the configured base path.
