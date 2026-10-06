import 'dart:convert';
import 'dart:io';

void writeAgentDebugLog({
  required String hypothesisId,
  required String location,
  required String message,
  Map<String, Object?> data = const {},
  String runId = 'post-fix',
}) {
  // #region agent log
  try {
    final payload = <String, Object?>{
      'sessionId': '93e3b1',
      'runId': runId,
      'hypothesisId': hypothesisId,
      'location': location,
      'message': message,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    File(
      '/Users/kd/Development/Project/PrivateDeals/Application/private_deals/.cursor/debug-93e3b1.log',
    ).writeAsStringSync('${jsonEncode(payload)}\n', mode: FileMode.append);
  } catch (_) {}
  // #endregion
}
