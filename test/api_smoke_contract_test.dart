import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/features/auth/data/i_auth_api.dart';
import 'package:private_deals/src/features/auth/data/w_auth_api.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_api.dart';
import 'package:private_deals/src/features/institution/data/api/company_api.dart';
import 'package:private_deals/src/features/institution/data/api/deal_api.dart';
import 'package:private_deals/src/features/institution/data/api/institution_profile_api.dart';
import 'package:private_deals/src/features/institution/legacy/backend/api/dashboard_api.dart'
    as inst_dash;
import 'package:private_deals/src/features/institution/legacy/backend/api/pre_ipo_transaction_api.dart';
import 'package:private_deals/src/features/investors/data/cml_api.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';
import 'package:private_deals/src/features/investors/data/w_investors_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/channel_partner/channel_partner_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/dashboard/dashboard_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/document/document_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/kyc/w_kyc_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/landing_page/landing_page_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/landing_page/unlisted_landing_page_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/mis/mis_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/my_earning/my_earning_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/notification/notification_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/pending_task/pending_task_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/portfolio/portfolio_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/transaction/i_primary_transaction_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/transaction/i_secondary_transaction_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/transaction/w_pre_ipo_transaction_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/transaction/w_primary_transaction_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/transaction/w_secondary_transaction_api.dart';
import 'package:private_deals/src/shared/models/enums.dart';
import 'package:private_deals/src/shared/models/media_model.dart';

import 'api_smoke/smoke_case.dart';
import 'api_smoke/smoke_checklist.dart';
import 'api_smoke/smoke_config.dart';
import 'api_smoke/smoke_harness.dart';

SmokeCase _case(int id) => smokeChecklist().firstWhere((c) => c.id == id);

MediaModel _emptyMedia() => MediaModel();

void main() {
  late SmokeFakeAdapter adapter;

  setUp(() async {
    await smokeSetUp();
    adapter = SmokeFakeAdapter();
    dioConfig.dio.httpClientAdapter = adapter;
    await installSmokeSession();
  });

  tearDown(() async {
    await smokeTearDown();
  });

  group('Smoke config (roles / base URL)', () {
    test('documents dart-define wiring without embedding credentials', () {
      expect(SmokeConfig.baseUrl, isNotEmpty);
      expect(SmokeConfig.baseUrl.endsWith('/'), isTrue);
      // Default CI run is contract-only (no live creds in repo).
      expect(SmokeConfig.live || !SmokeConfig.hasWmCredentials, isTrue);
      // ignore: avoid_print
      print('SmokeConfig: ${SmokeConfig.describe()}');
    });
  });

  group('Priority 1 contract paths', () {
    test('#1 primary sell share uses investor sell-now (blocked by interceptor)',
        () async {
      final res = await InvestorSecondaryTransactionApi.primarySellRequest(
        portfolioId: 1,
        shares: 1,
        price: '10',
      );
      expect(adapter.requests, isEmpty);
      expect(res.isSuccess, isFalse);
      expect(res.m.toLowerCase(), contains('partner workflow'));
      smokeLedger.record(
        SmokeResult(
          caseId: 1,
          status: SmokeResultStatus.fail,
          detail:
              'Dio interceptor rejects /investor/ sell-now for partner session; '
              'UI should call v1/business/secondary-invest/sell-now (wSellNow)',
        ),
      );
    });

    test('#2 pre-IPO sell share', () async {
      await expectContractPath(
        smokeCase: _case(2),
        adapter: adapter,
        action: () async {
          await WPreIpoTransactionApi.preIPOSellRequest(
            portfolioId: 1,
            shares: 1,
            price: '10',
            doc: _emptyMedia(),
          );
        },
      );
    });

    test('#3 channel partner list', () async {
      await expectContractPath(
        smokeCase: _case(3),
        adapter: adapter,
        expectList: true,
        action: () async {
          await ChannelPartnerApi.channelPartnerList();
        },
      );
    });

    test('#4 channel partner add', () async {
      await expectContractPath(
        smokeCase: _case(4),
        adapter: adapter,
        action: () async {
          await ChannelPartnerApi.addChannelPartner(
            name: 'Smoke CP',
            email: 'smoke-cp@example.com',
            mobile: '9000000001',
            password: 'secret',
            commission: '1',
            partner: 'Distributor',
            gender: 'male',
          );
        },
      );
    });

    test('#5 portfolio lists (startup + pre-ipo)', () async {
      await expectContractPath(
        smokeCase: _case(5),
        adapter: adapter,
        expectList: true,
        action: () async {
          await PortfolioApi.wPortfolioAPi('all', const [], const []);
        },
      );
      adapter.requests.clear();
      await PortfolioApi.wPreIpoPortfolioAPi(const []);
      expect(
        adapter.requests.any(
          (r) => pathMatches(r.path, 'v2/business/portfolio/pre-ipo'),
        ),
        isTrue,
        reason: 'pre-IPO portfolio path must also be hit',
      );
    });
  });

  group('Priority 2 contract paths', () {
    test('#6 company-startup list for upload portfolio', () async {
      await expectContractPath(
        smokeCase: _case(6),
        adapter: adapter,
        action: () async {
          await PortfolioApi.getCompanyStartupApi();
        },
      );
    });

    test('#7 investors list', () async {
      await expectContractPath(
        smokeCase: _case(7),
        adapter: adapter,
        expectList: true,
        action: () async {
          await WInvestorsApi.investorsList(
            isKyc: '',
            isActive: '',
            isAif: '',
          );
        },
      );
      await ChannelPartnerApi.relationManagerGet();
      expect(
        adapter.requests.any(
          (r) => pathMatches(r.path, 'v1/business/relation-manager'),
        ),
        isTrue,
      );
    });

    test('#8 add investor', () async {
      await expectContractPath(
        smokeCase: _case(8),
        adapter: adapter,
        responseData: {'id': 1, 'name': 'Smoke', 'mobile_number': '9'},
        action: () async {
          await WInvestorsApi.addInvestor(
            id: 0,
            investorType: 'Individual',
            name: 'Smoke Investor',
            mobileNumber: '9000000002',
          );
        },
      );
    });

    test('#9 investor detail', () async {
      await expectContractPath(
        smokeCase: _case(9),
        adapter: adapter,
        responseData: {'id': 1, 'uuid': 'u1', 'name': 'Smoke'},
        action: () async {
          await WInvestorsApi.getInvestor(uuid: 'u1');
        },
      );
    });

    test('#10 CML read path', () async {
      await expectContractPath(
        smokeCase: _case(10),
        adapter: adapter,
        responseData: {
          'dp_id': 'IN001',
          'client_id': '1',
          'pan_no': 'ABCDE1234F',
          'name': 'Smoke',
          'account_number': '1',
          'ifsc_code': 'AAAA0000000',
        },
        action: () async {
          final pdf = Uint8List.fromList('%PDF-1.4 smoke'.codeUnits);
          await CmlApi.read(1, CmlDocument('cml.pdf', pdf));
        },
      );
    });

    test('#11 legacy KYC', () async {
      await expectContractPath(
        smokeCase: _case(11),
        adapter: adapter,
        action: () async {
          await WealthManagerKycApi.kycUpdate(
            aadharFront: _emptyMedia(),
            aadharBack: _emptyMedia(),
            panCard: _emptyMedia(),
            cheque: _emptyMedia(),
            cml: _emptyMedia(),
            investorId: 1,
          );
        },
      );
    });

    test('#12 pending tasks', () async {
      await expectContractPath(
        smokeCase: _case(12),
        adapter: adapter,
        action: () async {
          await PendingTaskApi.pendingTasks();
        },
      );
    });

    test('#13 primary TX list', () async {
      await expectContractPath(
        smokeCase: _case(13),
        adapter: adapter,
        expectList: true,
        action: () async {
          await WPrimaryTransactionApi.transactionList();
        },
      );
    });

    test('#14 primary invest-now', () async {
      await expectContractPath(
        smokeCase: _case(14),
        adapter: adapter,
        responseData: {'id': 1},
        action: () async {
          await InvestorPrimaryTransactionApi.wealthManagerInvestment(
            investorId: 1,
            startupId: 1,
            roundId: 1,
            instrument: 'equity',
            shares: 1,
            sharesPrice: 1,
            investedAmount: 1,
            paymentMode: 'RTGS',
            fees: 0,
            gst: 0,
            type: PrimaryInvestmentType.Captable,
          );
        },
      );
    });

    test('#15 primary payment receipt (investor path blocked by interceptor)',
        () async {
      final res = await InvestorPrimaryTransactionApi.paymentReceipt(
        transactionId: 1,
        receipt: _emptyMedia(),
      );
      expect(adapter.requests, isEmpty);
      expect(res.isSuccess, isFalse);
      expect(res.m.toLowerCase(), contains('partner workflow'));
      smokeLedger.record(
        SmokeResult(
          caseId: 15,
          status: SmokeResultStatus.fail,
          detail:
              'Dio interceptor rejects investor upload-payment-receipt for partner session',
        ),
      );
    });

    test('#16 secondary TX list', () async {
      await expectContractPath(
        smokeCase: _case(16),
        adapter: adapter,
        expectList: true,
        action: () async {
          await WSecondaryTransactionApi.secondaryTransactionList();
        },
      );
    });

    test('#17 secondary sell-request list', () async {
      await expectContractPath(
        smokeCase: _case(17),
        adapter: adapter,
        expectList: true,
        action: () async {
          await WSecondaryTransactionApi.sellRequestList();
        },
      );
    });

    test('#18 secondary opportunities', () async {
      await expectContractPath(
        smokeCase: _case(18),
        adapter: adapter,
        expectList: true,
        action: () async {
          await WSecondaryTransactionApi.opportunitiesList();
        },
      );
    });

    test('#19 share receipt approve', () async {
      await expectContractPath(
        smokeCase: _case(19),
        adapter: adapter,
        action: () async {
          await WSecondaryTransactionApi.shareReceiptApprove(
            transactionId: 1,
            shareReceiptId: 1,
          );
        },
      );
    });

    test('#20 secondary buyRequest path (unwired UI)', () async {
      await expectContractPath(
        smokeCase: _case(20),
        adapter: adapter,
        action: () async {
          await WSecondaryTransactionApi.buyRequest(
            sellRequestId: '1',
            shares: 1,
            investorId: 1,
          );
        },
      );
    });

    test('#21 pre-IPO sell TX list', () async {
      await expectContractPath(
        smokeCase: _case(21),
        adapter: adapter,
        expectList: true,
        action: () async {
          await WPreIpoTransactionApi.sellTransactionList();
        },
      );
    });

    test('#22 pre-IPO buy TX list', () async {
      await expectContractPath(
        smokeCase: _case(22),
        adapter: adapter,
        expectList: true,
        action: () async {
          await WPreIpoTransactionApi.transactionList();
        },
      );
    });

    test('#23 send document', () async {
      await expectContractPath(
        smokeCase: _case(23),
        adapter: adapter,
        action: () async {
          await DocumentApi.sendDocument(1, 'agreement');
        },
      );
    });

    test('#24 my earnings', () async {
      await expectContractPath(
        smokeCase: _case(24),
        adapter: adapter,
        action: () async {
          await MyEarningApi.wInvestorEarningList();
        },
      );
      await MyEarningApi.wPartnerEarningList();
      expect(
        adapter.requests.any(
          (r) => pathMatches(r.path, 'v1/business/earning/partner'),
        ),
        isTrue,
      );
    });

    test('#25 MIS', () async {
      await expectContractPath(
        smokeCase: _case(25),
        adapter: adapter,
        expectList: true,
        action: () async {
          await MisApi.wMisList();
        },
      );
    });

    test('#26 notifications', () async {
      await expectContractPath(
        smokeCase: _case(26),
        adapter: adapter,
        expectList: true,
        action: () async {
          await NotificationApi.wNotificationList();
        },
      );
    });

    test('#27 dashboard', () async {
      await expectContractPath(
        smokeCase: _case(27),
        adapter: adapter,
        action: () async {
          await DashboardApi.wealthManagerDashboard();
        },
      );
    });

    test('#28 catalog enquiry create', () async {
      await expectContractPath(
        smokeCase: _case(28),
        adapter: adapter,
        action: () async {
          await WPreIpoTransactionApi.inquiry(
            type: InvestmentTypeEnum.buy,
            companySlug: 'example',
            quantity: 1,
            offerPrice: 1,
          );
        },
      );
    });

    test('#29 my inquiries list', () async {
      await expectContractPath(
        smokeCase: _case(29),
        adapter: adapter,
        expectList: true,
        action: () async {
          await EnquiryApi.list(institution: false);
        },
      );
    });

    test('#30 pre-IPO buy', () async {
      await expectContractPath(
        smokeCase: _case(30),
        adapter: adapter,
        expectList: true,
        action: () async {
          final inv = SelectInvestorModel(
            investorId: 1,
            quantity: 1,
            price: 1,
          );
          await WPreIpoTransactionApi.buy(list: [inv], dealId: 1);
        },
      );
    });

    test('#31 auth login', () async {
      await app.clear();
      await expectContractPath(
        smokeCase: _case(31),
        adapter: adapter,
        responseData: partnerIdentity(),
        action: () async {
          await WAuthApi.login(mobileNo: '9000000000', password: 'x');
        },
      );
    });

    test('#32 public verify-mobile', () async {
      await expectContractPath(
        smokeCase: _case(32),
        adapter: adapter,
        action: () async {
          await IAuthApi.verifyMobileNumber('9000000000');
        },
      );
    });
  });

  group('Priority 3 institution contract paths', () {
    setUp(() async {
      await installSmokeSession(type: 'Institution', id: 9);
    });

    test('#33 institution dashboard', () async {
      await expectContractPath(
        smokeCase: _case(33),
        adapter: adapter,
        responseData: {
          'summary': <String, dynamic>{},
          'access': <String, dynamic>{'is_preipo_access': true},
        },
        action: () async {
          await inst_dash.DashboardApi.getDashboard();
        },
      );
    });

    test('#34 company list', () async {
      await expectContractPath(
        smokeCase: _case(34),
        adapter: adapter,
        expectList: true,
        action: () async {
          await CompanyApi.getCompanyList(skip: 0);
        },
      );
    });

    test('#35 sectors', () async {
      await expectContractPath(
        smokeCase: _case(35),
        adapter: adapter,
        expectList: true,
        action: () async {
          await CompanyApi.getSectorList();
        },
      );
    });

    test('#36 promoters', () async {
      await expectContractPath(
        smokeCase: _case(36),
        adapter: adapter,
        action: () async {
          await CompanyApi.savePromoters(
            companyId: 1,
            promoters: const [],
          );
        },
      );
    });

    test('#37 deal list', () async {
      await expectContractPath(
        smokeCase: _case(37),
        adapter: adapter,
        expectList: true,
        action: () async {
          await DealApi.getDealList(skip: 0, isHotDeal: true);
        },
      );
    });

    test('#38 bulk deals', () async {
      await expectContractPath(
        smokeCase: _case(38),
        adapter: adapter,
        action: () async {
          await DealApi.bulkDeals({'deals': []});
        },
      );
    });

    test('#39 unlisted TX list', () async {
      await expectContractPath(
        smokeCase: _case(39),
        adapter: adapter,
        expectList: true,
        action: () async {
          await PreIPOTransactionApi.getTransactions();
        },
      );
    });

    test('#40 institution enquiries', () async {
      await expectContractPath(
        smokeCase: _case(40),
        adapter: adapter,
        expectList: true,
        action: () async {
          await EnquiryApi.list(institution: true);
        },
      );
    });

    test('#41 institution profile', () async {
      await expectContractPath(
        smokeCase: _case(41),
        adapter: adapter,
        action: () async {
          await InstitutionProfileApi.getProfile();
        },
      );
    });

    test('#42 LP secondary TX skipped (no API)', () async {
      await expectContractPath(
        smokeCase: _case(42),
        adapter: adapter,
        action: () async {},
      );
      expect(smokeLedger[42]?.status, SmokeResultStatus.skip);
    });
  });

  group('Catalog browse contract paths', () {
    test('#43 primary home', () async {
      await expectContractPath(
        smokeCase: _case(43),
        adapter: adapter,
        action: () async {
          await LandingPageApi.wHomePage();
        },
      );
    });

    test('#44 pre-IPO home', () async {
      await expectContractPath(
        smokeCase: _case(44),
        adapter: adapter,
        action: () async {
          await PreIpoLandingPageApi.wPreIPOHome();
        },
      );
    });

    test('#45 secondary home', () async {
      await expectContractPath(
        smokeCase: _case(45),
        adapter: adapter,
        action: () async {
          await PreIpoLandingPageApi.wSecondaryHome();
        },
      );
    });

    test('#46 news sectors', () async {
      await expectContractPath(
        smokeCase: _case(46),
        adapter: adapter,
        action: () async {
          await PreIpoLandingPageApi.newsSectors();
        },
      );
    });
  });
}
