import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const source = readFileSync(new URL('../web/app_update.js', import.meta.url), 'utf8');
const settle = () => new Promise((resolve) => setImmediate(resolve));

function browser({ current = 'build-1', deployed = 'build-1', base = 'https://example.com/portal/', attempted } = {}) {
  const requests = [];
  const listeners = {};
  let now = 20000;
  let interval;
  let destination;
  const document = {
    baseURI: base,
    visibilityState: 'visible',
    querySelector: () => ({ content: current }),
    addEventListener: (name, callback) => { listeners[name] = callback; },
  };
  const navigator = { onLine: true };
  const state = { deployed, ok: true, error: false };
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
      return { ok: state.ok, text: async () => `<meta name="app-version" content="${state.deployed}">` };
    },
    setInterval: (callback, ms) => { assert.equal(ms, 60000); interval = callback; },
    setTimeout: () => 1,
    clearTimeout() {},
  });
  return {
    requests, listeners, document, navigator, state,
    get destination() { return destination; },
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
  assert.equal(request.url.pathname, '/portal/index.html');
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

test('unstamped development builds do not poll or reload', async () => {
  const app = browser({ current: '{{APP_VERSION}}' });
  await app.tick();
  assert.equal(app.requests.length, 0);
  assert.equal(app.destination, undefined);
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

test('release wrapper passes the pubspec version to Flutter and rejects conflicting overrides', () => {
  const script = fileURLToPath(new URL('../tools/build_web.sh', import.meta.url));
  const version = readFileSync(new URL('../pubspec.yaml', import.meta.url), 'utf8')
    .match(/^version:\s*([^\s#]+)/m)[1];
  const env = { ...process.env, FLUTTER_BIN: '/bin/echo' };
  const result = spawnSync('bash', [script, '--no-pub'], { env, encoding: 'utf8' });
  assert.equal(result.status, 0, result.stderr);
  assert.ok(result.stdout.includes(`--web-define=APP_VERSION=${version}`));
  const conflict = spawnSync('bash', [script, '--build-number=999'], { env, encoding: 'utf8' });
  assert.equal(conflict.status, 1);
  assert.ok(conflict.stderr.includes('pubspec.yaml'));
});

test('bootstrap cache-busts JS and Wasm entrypoints relative to deployment base', () => {
  const template = readFileSync(new URL('../web/flutter_bootstrap.js', import.meta.url), 'utf8');
  const builds = [{ mainJsPath: 'main.dart.js' }, {
    mainWasmPath: 'main.dart.wasm', jsSupportRuntimePath: 'main.dart.mjs',
  }];
  let loaded = false;
  vm.runInNewContext(template.replace('{{flutter_js}}', '').replace('{{flutter_build_config}}', '')
    .replace('{{APP_VERSION}}', '1.2.0+16'), {
    URL, document: { baseURI: 'https://example.com/portal/' },
    _flutter: { buildConfig: { builds }, loader: { load() { loaded = true; } } },
  });
  assert.equal(loaded, true);
  assert.equal(builds[0].mainJsPath, 'https://example.com/portal/main.dart.js?v=1.2.0%2B16');
  assert.equal(builds[1].mainWasmPath, 'https://example.com/portal/main.dart.wasm?v=1.2.0%2B16');
  assert.equal(builds[1].jsSupportRuntimePath, 'https://example.com/portal/main.dart.mjs?v=1.2.0%2B16');
});
