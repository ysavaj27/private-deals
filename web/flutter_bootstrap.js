{{flutter_js}}
{{flutter_build_config}}

// A release-specific URL also bypasses files cached by older deployments.
const appVersion = '{{APP_VERSION}}';
if (/^[a-zA-Z0-9_.+-]+$/.test(appVersion)) {
  for (const build of _flutter.buildConfig.builds) {
    for (const key of ['mainJsPath', 'mainWasmPath', 'jsSupportRuntimePath']) {
      if (build[key]) {
        const url = new URL(build[key], document.baseURI);
        url.searchParams.set('v', appVersion);
        build[key] = url.href;
      }
    }
  }
}
_flutter.loader.load();
