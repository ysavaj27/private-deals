# Session credential storage

`flutter_secure_storage: ^11.2.0` stores a single JSON record containing `id`
and `token`, under `private_deals.credentials.v1`. Keeping these together avoids
pairing one account's ID with another account's token after an interrupted write.
The complete profile and permission flags remain in memory and are refreshed by
the existing business profile endpoint before protected routes are accessible.
GetStorage continues to hold ordinary preferences, such as theme and language.

On the first startup after upgrading, `SecureSessionStore` migrates the existing
`private_deals.session.v1` record, or the older `distributor` profile. It writes
credentials to secure storage before removing both plaintext entries. If secure
storage is temporarily unavailable, the existing session retry screen handles
recovery; the app does not authenticate using a plaintext fallback.

Login waits for secure persistence. Session storage operations are serialized,
and revision checks prevent a pending login or restoration from undoing logout.
Logout and HTTP 401 expiry clear credentials and legacy entries. A non-secret
GetStorage sign-out marker prevents restoration if secure deletion fails; a
subsequent startup retries deletion. A successful login removes that marker.

## Platform requirements

- Web deployments require HTTPS; localhost is supported for development. The
  plugin encrypts browser storage using WebCrypto. This does not protect against
  scripts executing within the app's origin; maintain normal XSS protections.
- Android backups are disabled to avoid restoring encrypted preferences without
  their device encryption key. The existing minimum SDK (28) is sufficient.
- iOS and macOS Runner entitlements enable Keychain access. Check signing and
  provisioning when distributing native builds.
- Windows builds require the C++ ATL component in Visual Studio Build Tools.

See the [package documentation](https://pub.dev/packages/flutter_secure_storage/versions/11.2.0).

## Verification

`test/secure_session_storage_test.dart` exercises the plugin method-channel
boundary with simulated storage. It covers migration, untrusted restored
profiles, failed reads/writes/deletes, malformed records, logout during writes,
credential expiry, and preservation of unrelated preferences and secure keys.
Existing authentication, profile, navigation, and workspace tests remain relevant.

Before release on each supported platform, verify a real-device login, app
restart, profile refresh, logout, and another restart. Also upgrade a signed-in
older installation and confirm that its legacy GetStorage entry disappears.
Method-channel tests cannot verify OS Keychain/Keystore behavior or code signing.
