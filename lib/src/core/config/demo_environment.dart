/// Host that receives the always-on demo banner.
const String demoEnvironmentHost = 'demo.privatedeals.in';

/// Host that receives the always-on staging banner.
const String stagingEnvironmentHost = 'staging.privatedeals.in';

/// True only when [baseUrl] is the demo site.
///
/// Live, staging, and any other host stay false. A path that merely contains
/// the word "demo" does not count.
bool isDemoEnvironment(String baseUrl) {
  return _hostMatches(baseUrl, demoEnvironmentHost);
}

/// True only when [baseUrl] is the staging site.
///
/// Live, demo, and any other host stay false. A path that merely contains
/// the word "staging" does not count.
bool isStagingEnvironment(String baseUrl) {
  return _hostMatches(baseUrl, stagingEnvironmentHost);
}

bool _hostMatches(String baseUrl, String expectedHost) {
  final uri = Uri.tryParse(baseUrl.trim());
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;
  return uri.host.toLowerCase() == expectedHost;
}
