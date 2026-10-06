enum SmokePriority { p1, p2, p3, catalog, skip }

enum SmokeMethod { get, post }

enum SmokeRole { wealthManager, institution, public, either }

enum SmokeResultStatus { pass, fail, na, skip }

class SmokeCase {
  const SmokeCase({
    required this.id,
    required this.feature,
    required this.apiLabel,
    required this.method,
    required this.pathSuffix,
    required this.priority,
    required this.role,
    this.readOnly = true,
    this.mismatchNote,
    this.skipReason,
  });

  final int id;
  final String feature;
  final String apiLabel;
  final SmokeMethod method;
  final String pathSuffix;
  final SmokePriority priority;
  final SmokeRole role;
  final bool readOnly;
  final String? mismatchNote;
  final String? skipReason;

  String get pathKey => pathSuffix.startsWith('/')
      ? pathSuffix
      : '/api/$pathSuffix'.replaceAll('//', '/');
}

class SmokeResult {
  SmokeResult({
    required this.caseId,
    required this.status,
    this.detail = '',
    this.actualPath = '',
  });

  final int caseId;
  final SmokeResultStatus status;
  final String detail;
  final String actualPath;

  Map<String, dynamic> toJson(SmokeCase c) => {
        'id': c.id,
        'feature': c.feature,
        'api': c.apiLabel,
        'method': c.method.name.toUpperCase(),
        'expected_path': c.pathSuffix,
        'actual_path': actualPath,
        'priority': c.priority.name,
        'status': status.name.toUpperCase(),
        'detail': detail,
        if (c.mismatchNote != null) 'mismatch_note': c.mismatchNote,
        if (c.skipReason != null) 'skip_reason': c.skipReason,
      };
}

class SmokeResultsLedger {
  final _byId = <int, SmokeResult>{};

  void record(SmokeResult result) => _byId[result.caseId] = result;

  SmokeResult? operator [](int id) => _byId[id];

  List<Map<String, dynamic>> matrixRows(List<SmokeCase> cases) =>
      cases.map((c) {
        final r = _byId[c.id];
        if (r == null) {
          return SmokeResult(
            caseId: c.id,
            status: SmokeResultStatus.na,
            detail: 'Not executed in this run',
          ).toJson(c);
        }
        return r.toJson(c);
      }).toList();

  String renderMarkdownTable(List<SmokeCase> cases) {
    final buf = StringBuffer();
    buf.writeln('| # | Feature | Method | Path | Status | Notes |');
    buf.writeln('|---|---------|--------|------|--------|-------|');
    for (final c in cases) {
      final r = _byId[c.id];
      final status = (r?.status ?? SmokeResultStatus.na).name.toUpperCase();
      final notes = [
        if (c.mismatchNote != null) c.mismatchNote!,
        if (r?.detail.isNotEmpty == true) r!.detail,
        if (c.skipReason != null) c.skipReason!,
      ].join('; ');
      buf.writeln(
        '| ${c.id} | ${c.feature} | ${c.method.name.toUpperCase()} | '
        '`${c.pathSuffix}` | $status | $notes |',
      );
    }
    return buf.toString();
  }
}

/// Shared ledger for the suite so matrix test can summarize.
final smokeLedger = SmokeResultsLedger();
