{{flutter_js}}
{{flutter_build_config}}

// A release-specific URL also bypasses files cached by older deployments.
const appVersion = window.privateDealsRelease;
if (/^[a-zA-Z0-9_.+-]+$/.test(appVersion)) {
  for (const build of _flutter.buildConfig.builds) {
    for (const key of ['mainJsPath', 'mainWasmPath', 'jsSupportRuntimePath']) {
      if (build[key]) {
        const url = new URL(build[key], document.baseURI);
        // Legacy Flutter workers strip ?v= before consulting their old cache.
        // A different parameter makes these requests go to the network.
        url.searchParams.set('release', appVersion);
        build[key] = url.href;
      }
    }
  }
}

// Ask a legacy Flutter worker to install the SDK's cleanup stub. Leave the
// separate Firebase messaging registration and all login storage untouched.
if (navigator.serviceWorker?.getRegistration) {
  navigator.serviceWorker.getRegistration(document.baseURI).then((registration) => {
    const worker = registration?.active;
    if (worker && new URL(worker.scriptURL).pathname ===
        new URL('flutter_service_worker.js', document.baseURI).pathname) {
      return registration.update();
    }
  }).catch(() => {
    // Offline or unavailable service workers must not block startup.
  });
}
_flutter.loader.load();
