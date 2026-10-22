import assert from 'node:assert/strict';
import { readFileSync, writeFileSync, mkdtempSync, mkdirSync, cpSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { verifyWebBuild } from '../tools/verify_web_build.mjs';
import test from 'node:test';
import vm from 'node:vm';
import { spawnSync } from 'node:child_process';

const source = readFileSync(new URL('../web/app_update.js', import.meta.url), 'utf8');
const settle = () => new Promise((resolve) => setImmediate(resolve));

function browser({ current = 'build-1', deployed = 'build-1', base = 'https://example.com/portal/', attempted, error = false, metadata, hanging = false } = {}) {
  const requests = [];
  const scripts = [];
  const listeners = {};
  let now = 20000;
  let interval;
  let destination;
  let timeout;
  const document = {
    baseURI: base,
    visibilityState: 'visible',
    querySelector: () => ({ content: current }),
    addEventListener: (name, callback) => { listeners[name] = callback; },
    createElement: () => ({}),
    body: { appendChild: (script) => scripts.push(script) },
  };
  const navigator = { onLine: true };
  const state = { deployed, ok: true, error, metadata, hanging };
  const window = {
    location: {
      href: `${base}deals/42?filter=open${attempted ? `&_app_update=${attempted}` : ''}#details`,
      replace: (value) => { destination = value; },
    },
    addEventListener: (name, callback) => { listeners[name] = callback; },
  };
  vm.runInNewContext(source, {
    document, navigator, window, URL, AbortController,
    Date: { now: () => now },
    DOMParser: class {
      parseFromString(html) {
        return { querySelector: () => {
          const match = html.match(/content="([^"]*)"/);
          return match ? { content: match[1] } : null;
        } };
      }
    },
    fetch: async (url, options) => {
      requests.push({ url, options });
      if (state.error) throw new Error('offline');
      if (state.hanging) await new Promise((resolve, reject) => {
        options.signal.addEventListener('abort', () => reject(new Error('timeout')));
      });
      return { ok: state.ok, json: async () => state.metadata || { release_id: state.deployed } };
    },
    setInterval: (callback, ms) => { assert.equal(ms, 60000); interval = callback; },
    setTimeout: (callback) => { timeout = callback; return 1; },
    clearTimeout() {},
  });
  return {
    requests, listeners, document, navigator, state, scripts, window,
    get destination() { return destination; },
    async expire() { timeout(); await settle(); },
    async tick() { now += 60000; await interval?.(); await settle(); },
    async event(name) { now += 11000; await listeners[name]?.(); await settle(); },
  };
}

test('new deployment reloads once, preserves route, and bypasses cached HTML', async () => {
  const app = browser();
  await settle();
  assert.equal(app.destination, undefined);
  app.state.deployed = 'build-2';
  await app.tick();
  const count = app.requests.length;
  await app.tick();
  assert.equal(app.requests.length, count, 'no further checks during navigation');
  const request = app.requests.at(-1);
  assert.equal(request.url.pathname, '/portal/version.json');
  assert.ok(request.url.searchParams.has('_update_check'));
  assert.equal(request.options.cache, 'no-store');
  assert.equal(app.destination, 'https://example.com/portal/deals/42?filter=open&_app_update=build-2#details');
});

test('offline, HTTP failures, invalid metadata, and hidden tabs do not reload', async () => {
  const app = browser();
  await settle();
  app.state.error = true;
  await app.tick();
  app.state.error = false;
  app.state.ok = false;
  app.state.deployed = 'build-2';
  await app.tick();
  app.state.ok = true;
  app.state.deployed = '{{APP_VERSION}}';
  await app.tick();
  assert.equal(app.destination, undefined);
  const count = app.requests.length;
  app.document.visibilityState = 'hidden';
  await app.tick();
  app.document.visibilityState = 'visible';
  app.navigator.onLine = false;
  await app.tick();
  assert.equal(app.requests.length, count);
  app.navigator.onLine = true;
  app.state.deployed = 'build-2';
  await app.event('online');
  assert.ok(app.destination.includes('_app_update=build-2'));
});

test('returning to a tab checks for new deployments', async () => {
  for (const event of ['visibilitychange', 'focus']) {
    const app = browser();
    await settle();
    app.state.deployed = 'build-2';
    await app.event(event);
    assert.ok(app.destination.includes('_app_update=build-2'));
  }
});

test('rollback to an older deployed build also reloads', async () => {
  const app = browser({ current: 'build-3', deployed: 'build-2' });
  await settle();
  assert.ok(app.destination.includes('_app_update=build-2'));
});

test('stale HTML after navigation does not cause an infinite reload loop', async () => {
  const app = browser({ deployed: 'build-2', attempted: 'build-2' });
  await settle();
  await app.tick();
  assert.equal(app.destination, undefined);
  app.state.deployed = 'build-3';
  await app.tick();
  assert.ok(app.destination.includes('_app_update=build-3'));
});

test('plain Flutter builds use version.json and start the app only once', async () => {
  const app = browser({ current: '{{APP_VERSION}}' });
  app.state.metadata = { version: '1.2.0', build_number: '15' };
  await settle();
  assert.equal(app.window.privateDealsRelease, '1.2.0+15');
  assert.equal(app.scripts.length, 1);
  assert.equal(app.scripts[0].src, 'https://example.com/portal/flutter_bootstrap.js?release=1.2.0%2B15');
  await app.tick();
  assert.equal(app.destination, undefined);
  assert.equal(app.scripts.length, 1);
  app.state.metadata.build_number = '16';
  await app.tick();
  assert.equal(new URL(app.destination).searchParams.get('_app_update'), '1.2.0+16');
});

test('bad metadata or offline startup still loads Flutter and retries later', async () => {
  for (const mode of ['error', 'metadata']) {
    const app = browser({ current: '{{APP_VERSION}}',
      error: mode === 'error', metadata: mode === 'metadata' ? { version: 'broken' } : undefined });
    await settle();
    assert.equal(app.scripts.length, 1);
    assert.equal(app.destination, undefined);
    app.state.error = false;
    app.state.metadata = { version: '1.2.0', build_number: '15' };
    await app.tick();
    app.state.metadata.build_number = '16';
    await app.tick();
    assert.ok(app.destination.includes('_app_update=1.2.0%2B16'));
  }
});

test('full pubspec version matches unchanged builds and detects build-number changes', async () => {
  const app = browser({ current: '1.2.0+15', deployed: '1.2.0+15' });
  await settle();
  await app.tick();
  assert.equal(app.destination, undefined);
  app.state.deployed = '1.2.0+16';
  await app.tick();
  assert.equal(new URL(app.destination).searchParams.get('_app_update'), '1.2.0+16');
});

test('release wrapper creates distinct IDs without a version bump and rejects overrides', () => {
  const directory = mkdtempSync(join(tmpdir(), 'web-release-'));
  try {
    mkdirSync(join(directory, 'tools'));
    cpSync(new URL('../tools/build_web.sh', import.meta.url), join(directory, 'tools/build_web.sh'));
    cpSync(new URL('../tools/verify_web_build.mjs', import.meta.url), join(directory, 'tools/verify_web_build.mjs'));
    cpSync(new URL('../web', import.meta.url), join(directory, 'web'), { recursive: true });
    writeFileSync(join(directory, 'pubspec.yaml'), 'version: 1.2.0+15\n');
    const fakeFlutter = join(directory, 'flutter.mjs');
    writeFileSync(fakeFlutter, `#!/usr/bin/env node
import { mkdirSync, readFileSync, writeFileSync, cpSync } from 'node:fs';
mkdirSync('build/web', { recursive: true });
cpSync('web', 'build/web', { recursive: true });
for (const name of ['index.html', 'flutter_bootstrap.js']) {
  writeFileSync('build/web/' + name, readFileSync('web/' + name, 'utf8').replaceAll(/\\{\\{flutter_\\w+\\}\\}/g, ''));
}
writeFileSync('build/web/main.dart.js', '// compiled app');
writeFileSync('build/web/flutter_service_worker.js', '// cleanup stub');
writeFileSync('build/web/version.json', JSON.stringify({ version: '1.2.0', build_number: '15' }));
`, { mode: 0o755 });
    const env = { ...process.env, FLUTTER_BIN: fakeFlutter };
    const script = join(directory, 'tools/build_web.sh');
    const first = spawnSync('bash', [script, '--no-pub'], { env, encoding: 'utf8' });
    assert.equal(first.status, 0, first.stderr);
    const firstId = verifyWebBuild(join(directory, 'build/web'));
    const second = spawnSync('bash', [script, '--no-pub'], { env, encoding: 'utf8' });
    assert.equal(second.status, 0, second.stderr);
    assert.notEqual(verifyWebBuild(join(directory, 'build/web')), firstId);
    const conflict = spawnSync('bash', [script, '--build-number=999'], { env, encoding: 'utf8' });
    assert.equal(conflict.status, 1);
    assert.ok(conflict.stderr.includes('pubspec.yaml'));
    writeFileSync(join(directory, 'build/web/index.html'), '<html>incomplete build</html>');
    assert.throws(() => verifyWebBuild(join(directory, 'build/web')), /startup/);
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
});

test('bootstrap cache-busts JS and Wasm entrypoints relative to deployment base', () => {
  const template = readFileSync(new URL('../web/flutter_bootstrap.js', import.meta.url), 'utf8');
  const builds = [{ mainJsPath: 'main.dart.js' }, {
    mainWasmPath: 'main.dart.wasm', jsSupportRuntimePath: 'main.dart.mjs',
  }];
  let loaded = false;
  vm.runInNewContext(template.replace('{{flutter_js}}', '').replace('{{flutter_build_config}}', '')
    .replace('{{APP_VERSION}}', '1.2.0+16'), {
    URL, window: { privateDealsRelease: '1.2.0+16' }, navigator: {}, document: { baseURI: 'https://example.com/portal/' },
    _flutter: { buildConfig: { builds }, loader: { load() { loaded = true; } } },
  });
  assert.equal(loaded, true);
  assert.equal(builds[0].mainJsPath, 'https://example.com/portal/main.dart.js?release=1.2.0%2B16');
  assert.equal(builds[1].mainWasmPath, 'https://example.com/portal/main.dart.wasm?release=1.2.0%2B16');
  assert.equal(builds[1].jsSupportRuntimePath, 'https://example.com/portal/main.dart.mjs?release=1.2.0%2B16');
});

test('stale HTML recovery starts the deployed bundle instead of the cached version', async () => {
  const app = browser({ current: 'build-1', deployed: 'build-2', attempted: 'build-2' });
  await settle();
  assert.equal(app.destination, undefined);
  assert.equal(app.window.privateDealsRelease, 'build-2');
  assert.ok(app.scripts[0].src.endsWith('?release=build-2'));
});

test('bootstrap uses runtime release for plain builds and only updates its own legacy worker', async () => {
  const template = readFileSync(new URL('../web/flutter_bootstrap.js', import.meta.url), 'utf8')
    .replace('{{flutter_js}}', '').replace('{{flutter_build_config}}', '');
  for (const scriptURL of ['https://example.com/portal/flutter_service_worker.js?v=1',
    'https://example.com/firebase-messaging-sw.js',
    'https://example.com/another-app/flutter_service_worker.js', null]) {
    let updates = 0;
    let loaded = 0;
    const builds = [{ mainJsPath: 'main.dart.js' }];
    vm.runInNewContext(template, {
      URL, window: { privateDealsRelease: '1.2.0+15' },
      document: { baseURI: 'https://example.com/portal/' },
      navigator: { serviceWorker: { getRegistration: async () => {
        if (!scriptURL) throw new Error('service worker unavailable');
        return { active: { scriptURL }, update: async () => { updates++; } };
      } } },
      _flutter: { buildConfig: { builds }, loader: { load() { loaded++; } } },
    });
    await settle();
    assert.equal(loaded, 1);
    assert.equal(updates, scriptURL?.includes('/portal/flutter_service_worker.js') ? 1 : 0);
    assert.equal(builds[0].mainJsPath, 'https://example.com/portal/main.dart.js?release=1.2.0%2B15');
    // Old Flutter SW resource keys only remove ?v=; this must miss that cache.
    const key = new URL(builds[0].mainJsPath).pathname.slice(1) + new URL(builds[0].mainJsPath).search;
    assert.notEqual(key.split('?v=')[0], 'portal/main.dart.js');
  }
});

test('HTML requests a fresh startup controller without needing build substitutions', () => {
  const html = readFileSync(new URL('../web/index.html', import.meta.url), 'utf8');
  const inline = html.match(/<script>\s*([\s\S]*?)<\/script>/)[1];
  const urls = [];
  for (const now of [1000, 2000]) {
    vm.runInNewContext(inline, {
      URL, Date: { now: () => now },
      document: { baseURI: 'https://example.com/portal/', createElement: () => ({}),
        body: { appendChild: (script) => urls.push(script.src) } },
    });
  }
  assert.equal(new URL(urls[0]).pathname, '/portal/app_update.js');
  assert.notEqual(urls[0], urls[1]);
  assert.ok(!html.includes('src="flutter_bootstrap.js'));
});


test('a hung initial request times out, starts Flutter, and permits later checks', async () => {
  const app = browser({ current: '', hanging: true });
  await settle();
  assert.equal(app.scripts.length, 0);
  await app.event('focus');
  assert.equal(app.requests.length, 1, 'do not overlap pending requests');
  await app.expire();
  assert.equal(app.scripts.length, 1);
  assert.equal(app.destination, undefined);
  app.state.hanging = false;
  await app.event('online');
  assert.equal(app.requests.length, 2);
  assert.equal(app.scripts.length, 1);
});

test('rollback still reloads when the URL retains that release from an earlier visit', async () => {
  const app = browser({ current: 'build-3', deployed: 'build-3', attempted: 'build-2' });
  await settle();
  app.state.deployed = 'build-2';
  await app.tick();
  assert.ok(app.destination.includes('_app_update=build-2'));
});
