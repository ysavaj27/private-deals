import 'debug_log_io.dart' if (dart.library.html) 'debug_log_stub.dart'
    as debug_log_impl;

void agentDebugLog({
  required String hypothesisId,
  required String location,
  required String message,
  Map<String, Object?> data = const {},
  String runId = 'post-fix',
}) {
  debug_log_impl.writeAgentDebugLog(
    hypothesisId: hypothesisId,
    location: location,
    message: message,
    data: data,
    runId: runId,
  );
}
