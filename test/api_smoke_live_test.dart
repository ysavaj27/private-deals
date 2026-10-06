import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/features/auth/data/w_auth_api.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_api.dart';
import 'package:private_deals/src/features/institution/data/api/company_api.dart';
import 'package:private_deals/src/features/institution/data/api/deal_api.dart';
import 'package:private_deals/src/features/institution/data/api/institution_profile_api.dart';
import 'package:private_deals/src/features/institution/legacy/backend/api/dashboard_api.dart'
    as inst_dash;
import 'package:private_deals/src/features/institution/legacy/backend/api/pre_ipo_transaction_api.dart';
import 'package:private_deals/src/features/investors/data/w_investors_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/channel_partner/channel_partner_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/dashboard/dashboard_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/landing_page/landing_page_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/landing_page/unlisted_landing_page_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/mis/mis_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/my_earning/my_earning_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/notification/notification_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/pending_task/pending_task_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/portfolio/portfolio_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/transaction/w_pre_ipo_transaction_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/transaction/w_primary_transaction_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/transaction/w_secondary_transaction_api.dart';
import 'package:private_deals/src/shared/models/base_model.dart';

import 'api_smoke/smoke_case.dart';
import 'api_smoke/smoke_checklist.dart';
import 'api_smoke/smoke_config.dart';
import 'api_smoke/smoke_harness.dart';

SmokeCase _case(int id) => smokeChecklist().firstWhere((c) => c.id == id);

bool _ok(BaseModel m) => m.isSuccess;

/// Live read-only smoke against staging. Skipped unless SMOKE_LIVE=true + creds.
///
/// ```sh
/// flutter test test/api_smoke_live_test.dart --dart-define=SMOKE_LIVE=true \
///   --dart-define=PRIVATE_DEALS_BASE_URL=https://staging.example/ \
///   --dart-define=SMOKE_WM_MOBILE=... --dart-define=SMOKE_WM_PASSWORD=... \
///   --dart-define=SMOKE_INSTITUTION_MOBILE=... \
///   --dart-define=SMOKE_INSTITUTION_PASSWORD=...
/// ```
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
  });

  tearDown(() async {
    await app.clear();
    Get.reset();
  });

  group('Live WM GETs', () {
    test('Priority 1–2 read-only endpoints', () async {
      if (!SmokeConfig.canRunWmLive) {
        for (final id in [3, 5, 6, 7, 12, 13, 16, 17, 18, 21, 22, 24, 25, 26, 27, 29, 43, 44, 45, 46]) {
          recordNa(
            _case(id),
            'Set SMOKE_LIVE=true and SMOKE_WM_MOBILE/PASSWORD (prefer staging host)',
          );
        }
        // ignore: avoid_print
        print('WM live smoke skipped: ${SmokeConfig.describe()}');
        return;
      }

      final login = await WAuthApi.login(
        mobileNo: SmokeConfig.wmMobile,
        password: SmokeConfig.wmPassword,
      );
      recordLive(_case(31), ok: login.isSuccess, detail: login.m);
      expect(login.isSuccess, isTrue, reason: login.m);

      Future<void> getCase(int id, Future<BaseModel> Function() call) async {
        final res = await call();
        recordLive(_case(id), ok: _ok(res), detail: res.m);
        expect(_ok(res), isTrue, reason: '#$id ${res.m}');
      }

      await getCase(3, () => ChannelPartnerApi.channelPartnerList());
      await getCase(
        5,
        () => PortfolioApi.wPortfolioAPi('all', const [], const []),
      );
      await PortfolioApi.wPreIpoPortfolioAPi(const []);
      await getCase(6, () => PortfolioApi.getCompanyStartupApi());
      await getCase(
        7,
        () => WInvestorsApi.investorsList(isKyc: '', isActive: '', isAif: ''),
      );
      await getCase(12, () => PendingTaskApi.pendingTasks());
      await getCase(13, () => WPrimaryTransactionApi.transactionList());
      await getCase(16, () => WSecondaryTransactionApi.secondaryTransactionList());
      await getCase(17, () => WSecondaryTransactionApi.sellRequestList());
      await getCase(18, () => WSecondaryTransactionApi.opportunitiesList());
      await getCase(21, () => WPreIpoTransactionApi.sellTransactionList());
      await getCase(22, () => WPreIpoTransactionApi.transactionList());
      await getCase(24, () => MyEarningApi.wInvestorEarningList());
      await getCase(25, () => MisApi.wMisList());
      await getCase(26, () => NotificationApi.wNotificationList());
      await getCase(27, () => DashboardApi.wealthManagerDashboard());
      await getCase(29, () => EnquiryApi.list(institution: false));
      await getCase(43, () => LandingPageApi.wHomePage());
      await getCase(44, () => PreIpoLandingPageApi.wPreIPOHome());
      await getCase(45, () => PreIpoLandingPageApi.wSecondaryHome());
      await getCase(46, () => PreIpoLandingPageApi.newsSectors());

      // Write POSTs stay gated.
      for (final id in [1, 2, 4, 8, 10, 11, 14, 15, 19, 20, 23, 28, 30]) {
        recordNa(
          _case(id),
          SmokeConfig.allowWrites
              ? 'allowWrites set but live write helpers not auto-run (manual)'
              : 'requires SMOKE_ALLOW_WRITES=true (not auto-executed)',
        );
      }
    }, timeout: const Timeout(Duration(minutes: 3)));
  });

  group('Live Institution GETs', () {
    test('Priority 3 read-only endpoints', () async {
      if (!SmokeConfig.canRunInstitutionLive) {
        for (final id in [33, 34, 35, 37, 39, 40, 41]) {
          recordNa(
            _case(id),
            'Set SMOKE_LIVE=true and SMOKE_INSTITUTION_MOBILE/PASSWORD',
          );
        }
        recordNa(_case(42), 'no API');
        // ignore: avoid_print
        print('Institution live smoke skipped: ${SmokeConfig.describe()}');
        return;
      }

      final login = await WAuthApi.login(
        mobileNo: SmokeConfig.institutionMobile,
        password: SmokeConfig.institutionPassword,
      );
      expect(login.isSuccess, isTrue, reason: login.m);

      Future<void> check(int id, Future<BaseModel> Function() call) async {
        final res = await call();
        recordLive(_case(id), ok: _ok(res), detail: res.m);
        expect(_ok(res), isTrue, reason: '#$id ${res.m}');
      }

      try {
        await inst_dash.DashboardApi.getDashboard();
        recordLive(_case(33), ok: true);
      } catch (e) {
        recordLive(_case(33), ok: false, detail: '$e');
        fail('#33 $e');
      }

      await check(34, () => CompanyApi.getCompanyList(skip: 0));
      await check(35, () => CompanyApi.getSectorList());
      await check(37, () => DealApi.getDealList(skip: 0, isHotDeal: true));
      try {
        await PreIPOTransactionApi.getTransactions();
        recordLive(_case(39), ok: true);
      } catch (e) {
        recordLive(_case(39), ok: false, detail: '$e');
        fail('#39 $e');
      }
      await check(40, () => EnquiryApi.list(institution: true));
      await check(41, () => InstitutionProfileApi.getProfile());
      smokeLedger.record(
        SmokeResult(
          caseId: 42,
          status: SmokeResultStatus.skip,
          detail: 'LP secondary transactions placeholder — no API',
        ),
      );

      for (final id in [36, 38]) {
        recordNa(
          _case(id),
          SmokeConfig.allowWrites
              ? 'allowWrites set but live write helpers not auto-run'
              : 'requires SMOKE_ALLOW_WRITES=true (not auto-executed)',
        );
      }

      // Silence unused import when analyzer is strict on dioConfig in live mode.
      expect(dioConfig.dio.options.baseUrl, contains('api'));
    }, timeout: const Timeout(Duration(minutes: 3)));
  });
}
