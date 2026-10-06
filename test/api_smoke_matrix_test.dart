import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/core/config/api_endpoints.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_api.dart';
import 'package:private_deals/src/features/institution/data/institution_endpoints.dart';

import 'api_smoke/smoke_case.dart';
import 'api_smoke/smoke_checklist.dart';
import 'api_smoke/smoke_config.dart';
import 'api_smoke/smoke_harness.dart';

/// Maps checklist ids to canonical path constants in the app (source of truth).
String? _declaredPathFor(int id) {
  switch (id) {
    case 1:
      return AppUrl.iPrimarySellNow;
    case 2:
      return AppUrl.wPreIPOSellNow;
    case 3:
    case 4:
      return AppUrl.wChannelPartnerList;
    case 5:
      return AppUrl.wPortfolio;
    case 6:
      return AppUrl.wCompanyStartupList;
    case 7:
      return AppUrl.wInvestorList;
    case 8:
      return AppUrl.wAddInvestor;
    case 9:
      return AppUrl.wInvestorDetail;
    case 10:
      return 'v2/business/investor/kyc/cml/read';
    case 11:
      return AppUrl.wInvestorKyc;
    case 12:
      return AppUrl.wPendingTasks;
    case 13:
      return AppUrl.wTransactions;
    case 14:
      return AppUrl.wPrimaryInvestment;
    case 15:
      return AppUrl.iUploadPaymentReceipt;
    case 16:
      return AppUrl.wSecondaryTransaction;
    case 17:
      return AppUrl.wSellRequestList;
    case 18:
      return AppUrl.wOpportunitiesList;
    case 19:
      return AppUrl.wShareReceiptApprove;
    case 20:
      return AppUrl.wBuyNow;
    case 21:
      return AppUrl.wPreIpoSellTransaction;
    case 22:
      return AppUrl.wNewPreIpoTransaction;
    case 23:
      return AppUrl.wSendDocument;
    case 24:
      return AppUrl.wInvestorEarning;
    case 25:
      return AppUrl.wMis;
    case 26:
      return AppUrl.wNotification;
    case 27:
      return AppUrl.wDashboard;
    case 28:
    case 29:
      return AppUrl.wEnquiry;
    case 30:
      return AppUrl.wPreIpoBuy;
    case 31:
      return AppUrl.wLogin;
    case 32:
      return AppUrl.verifyMobileNumber;
    case 33:
      return InstitutionEndpoints.dashboard;
    case 34:
      return InstitutionEndpoints.companyList;
    case 35:
      return InstitutionEndpoints.sectors;
    case 36:
      return InstitutionEndpoints.addPromoters;
    case 37:
      return InstitutionEndpoints.dealList;
    case 38:
      return InstitutionEndpoints.bulkDeals;
    case 39:
      return InstitutionEndpoints.preIpoTransaction;
    case 40:
      return EnquiryApi.institutionPath;
    case 41:
      return InstitutionEndpoints.profile;
    case 42:
      return null;
    case 43:
      return AppUrl.home;
    case 44:
      return AppUrl.wPreIPOHome;
    case 45:
      return AppUrl.wSecondaryLandingPage;
    case 46:
      return AppUrl.wPreIPOHomeNewsSector;
    default:
      return null;
  }
}

void main() {
  test('checklist covers plan ids 1–46 exactly once', () {
    final ids = smokeChecklist().map((c) => c.id).toList()..sort();
    expect(ids, List.generate(46, (i) => i + 1));
  });

  test('known endpoint mismatches are flagged on the matrix', () {
    final flagged = mismatchFlags().map((c) => c.id).toSet();
    expect(
      flagged.containsAll({1, 4, 5, 15, 20, 26}),
      isTrue,
      reason: 'Plan-called mismatches must stay documented',
    );
  });

  test('checklist paths align with AppUrl / InstitutionEndpoints', () {
    for (final c in smokeChecklist()) {
      if (c.id == 42) {
        smokeLedger.record(
          SmokeResult(
            caseId: 42,
            status: SmokeResultStatus.skip,
            detail: c.skipReason ?? 'no API',
          ),
        );
        continue;
      }
      final declared = _declaredPathFor(c.id);
      expect(declared, isNotNull, reason: 'missing path map for #${c.id}');
      final ok = pathMatches(declared!, c.pathSuffix);
      smokeLedger.record(
        SmokeResult(
          caseId: c.id,
          status: ok ? SmokeResultStatus.pass : SmokeResultStatus.fail,
          actualPath: declared,
          detail: ok
              ? (c.mismatchNote ?? 'path constant aligned')
              : 'checklist ${c.pathSuffix} != declared $declared',
        ),
      );
      expect(ok, isTrue, reason: '#${c.id} ${c.feature}');
    }
  });

  test('writes Pass/Fail/N/A matrix artifact + prints markdown', () {
    // Ensure ledger is complete even if previous test order differs.
    for (final c in smokeChecklist()) {
      if (smokeLedger[c.id] != null) continue;
      if (c.id == 42) {
        recordNa(c, c.skipReason ?? 'skip');
        continue;
      }
      final declared = _declaredPathFor(c.id);
      if (declared == null) {
        recordNa(c, 'no declared path');
        continue;
      }
      smokeLedger.record(
        SmokeResult(
          caseId: c.id,
          status: pathMatches(declared, c.pathSuffix)
              ? SmokeResultStatus.pass
              : SmokeResultStatus.fail,
          actualPath: declared,
          detail: c.mismatchNote ?? 'path constant aligned',
        ),
      );
    }

    // Runtime: partner Dio interceptor rejects pure /investor/ paths.
    const interceptorBlocked = {
      1: 'Client blocks iPrimarySellNow; WM sell UI cannot reach network',
      15: 'Client blocks iUploadPaymentReceipt; WM receipt UI cannot reach network',
    };
    for (final entry in interceptorBlocked.entries) {
      final c = smokeChecklist().firstWhere((e) => e.id == entry.key);
      smokeLedger.record(
        SmokeResult(
          caseId: entry.key,
          status: SmokeResultStatus.fail,
          actualPath: c.pathSuffix,
          detail: entry.value,
        ),
      );
    }

    final rows = smokeLedger.matrixRows(smokeChecklist());
    final report = {
      'generated_at': DateTime.now().toUtc().toIso8601String(),
      'config': SmokeConfig.describe(),
      'mode': 'contract_path_alignment+interceptor_findings',
      'roles_env': {
        'PRIVATE_DEALS_BASE_URL': SmokeConfig.baseUrl,
        'SMOKE_LIVE': SmokeConfig.live,
        'SMOKE_ALLOW_WRITES': SmokeConfig.allowWrites,
        'has_wm_creds': SmokeConfig.hasWmCredentials,
        'has_institution_creds': SmokeConfig.hasInstitutionCredentials,
        'staging_hint': SmokeConfig.looksLikeStaging,
      },
      'live_hint':
          'Re-run with SMOKE_LIVE=true and staging credentials for live Pass/Fail',
      'mismatch_flags': mismatchFlags()
          .map((c) => {'id': c.id, 'note': c.mismatchNote})
          .toList(),
      'interceptor_blocked': interceptorBlocked.entries
          .map((e) => {'id': e.key, 'detail': e.value})
          .toList(),
      'results': rows,
    };

    final outDir = Directory('test/api_smoke');
    expect(outDir.existsSync(), isTrue);
    final outFile = File('${outDir.path}/last_run_matrix.json');
    outFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(report),
    );

    final md = smokeLedger.renderMarkdownTable(smokeChecklist());
    // ignore: avoid_print
    print('\n=== API smoke matrix ===\n$md');
    // ignore: avoid_print
    print('Wrote ${outFile.path}');

    final pass = rows.where((r) => r['status'] == 'PASS').length;
    final skip = rows.where((r) => r['status'] == 'SKIP').length;
    final fail = rows.where((r) => r['status'] == 'FAIL').length;
    expect(fail, interceptorBlocked.length);
    expect(pass + skip + fail, 46);
  });
}
