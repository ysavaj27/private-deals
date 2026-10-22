import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export function verifyWebBuild(directory = 'build/web') {
  const read = (name) => readFileSync(resolve(directory, name), 'utf8');
  const html = read('index.html');
  const bootstrap = read('flutter_bootstrap.js');
  const metadata = JSON.parse(read('version.json'));
  const valid = (value) => typeof value === 'string' && /^[a-zA-Z0-9_.+-]{1,100}$/.test(value);
  if (!valid(metadata.version) || !valid(metadata.build_number)) {
    throw new Error('Missing version/build number in version.json.');
  }
  const stamp = html.match(/<meta name="app-version" content="([^"]+)"/)?.[1];
  if (valid(stamp) && stamp !== metadata.release_id) {
    throw new Error('HTML and version.json release IDs do not match.');
  }
  if (!html.includes("startupUrl.searchParams.set('_startup'") ||
      !bootstrap.includes('window.privateDealsRelease') ||
      !bootstrap.includes("url.searchParams.set('release', appVersion)")) {
    throw new Error('Missing cache-safe startup scripts.');
  }
  if (/\{\{flutter_\w+\}\}/.test(html + bootstrap)) {
    throw new Error('Unresolved Flutter build placeholders.');
  }
  for (const name of ['app_update.js', 'main.dart.js', 'flutter_service_worker.js',
    'firebase-messaging-sw.js']) {
    if (!read(name).trim()) throw new Error(`Missing content in ${name}.`);
  }
  return metadata.release_id || `${metadata.version}+${metadata.build_number}`;
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    console.log(`Verified web release ${verifyWebBuild(process.argv[2])}.`);
  } catch (error) {
    console.error(`Web release is not ready: ${error.message}\nRun flutter build web --release before uploading build/web.`);
    process.exitCode = 1;
  }
}
