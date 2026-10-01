import 'package:logger/logger.dart';
/// Legacy callers can contain personal details. No payloads are printed.
final Logger logger = Logger(filter: _PrivateLogFilter());
class _PrivateLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => false;
}
