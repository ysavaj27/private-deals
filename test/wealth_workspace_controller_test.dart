import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/kyc_pending_investor/kyc_pending_investor_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/my_earning/my_earning_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/mis/mis_page_ctrl.dart';

import 'session_and_api_test.dart' show FakeAdapter, response, identity;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity('Wealth Manager'));
  });
  tearDown(() async {
    await app.clear();
    Get.reset();
  });

  test(
    'Late earnings responses cannot overwrite the active source state',
    () async {
      final investorResponse = Completer<ResponseBody>();
      final investorStarted = Completer<void>();
      dioConfig.dio.httpClientAdapter = FakeAdapter((options) async {
        if (options.path == AppUrl.wInvestorEarning) {
          investorStarted.complete();
          return investorResponse.future;
        }
        return response({
          'status': 1,
          'data': {
            'total_partners': 3,
            'total_commission_earned': 75000,
            'list': [],
          },
        });
      });
      final controller = MyEarningPageCtrl();
      final oldLoad = controller.refreshData();
      await investorStarted.future;
      await controller.selectType(MyEarningTypeEnum.channelPartner);
      expect(controller.partner().totalPartners, 3);
      expect(controller.isLoading(), false);
      investorResponse.complete(
        response({'status': 0, 'message': 'Old request failed'}),
      );
      await oldLoad;
      expect(controller.currentIndex(), MyEarningTypeEnum.channelPartner);
      expect(controller.error(), isEmpty);
      expect(controller.partner().totalCommissionEarned, 75000);
    },
  );

  test(
    'Pending category switches stay local without extra API calls',
    () async {
      var calls = 0;
      dioConfig.dio.httpClientAdapter = FakeAdapter((_) async {
        calls++;
        return response({
          'status': 1,
          'data': {
            'pending_kyc': {
              'count': 1,
              'investors': [
                {'id': 2, 'name': 'Fresh investor'},
              ],
            },
            'pending_documents': {
              'count': 1,
              'documents': [
                {
                  'id': 5,
                  'type': 'BuyMandate',
                  'company': {'brand_name': 'Northstar'},
                  'investor': {'name': 'Priya Mehta'},
                },
              ],
            },
            'pending_fund_transfer': {
              'count': 1,
              'transactions': [
                {
                  'id': 9,
                  'payable_amount': 150000,
                  'company': {'brand_name': 'Northstar'},
                  'investor': {'name': 'Fresh investor'},
                },
              ],
            },
          },
        });
      });
      final controller = KycPendingInvestorPageCtrl();
      await controller.refreshData();
      final afterLoad = calls;
      await controller.selectType(PendingTaskEnum.document);
      await controller.selectType(PendingTaskEnum.fundTransfer);
      expect(calls, afterLoad);
      expect(controller.type(), PendingTaskEnum.fundTransfer);
      expect(controller.documents.single.id, 5);
      expect(controller.fundTransfers.single.id, 9);
      expect(controller.isLoading(), false);
    },
  );

  test('Pending refresh loads KYC, documents and fund transfers from v2',
      () async {
    final adapter = FakeAdapter(
      (options) async => response({
        'status': 1,
        'data': {
          'pending_kyc': {
            'count': 4,
            'investors': [
              {'id': 1, 'name': 'Updated investor'},
            ],
          },
          'pending_documents': {
            'count': 2,
            'documents': [
              {
                'id': 11,
                'type': 'BuyMandate',
                'name': 'Buy Mandate',
                'company': {'brand_name': 'Northstar Technologies'},
                'investor': {'name': 'Priya Mehta'},
              },
            ],
          },
          'pending_fund_transfer': {
            'count': 1,
            'transactions': [
              {
                'id': 21,
                'payable_amount': 250000,
                'company': {'brand_name': 'Summit Brands'},
                'investor': {'name': 'Aarav Shah'},
              },
            ],
          },
        },
      }),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    final controller = KycPendingInvestorPageCtrl();
    await controller.refreshData();
    expect(controller.pendingTask().pendingKyc.count, 4);
    expect(controller.pendingTask().pendingDocuments.count, 2);
    expect(controller.pendingTask().pendingFundTransfer.count, 1);
    expect(controller.investors.single.name, 'Updated investor');
    expect(controller.documents.single.company.brandName, 'Northstar Technologies');
    expect(controller.fundTransfers.single.payableAmount, 250000);
    expect(adapter.requests.single.path, AppUrl.wPendingTasks);
    expect(AppUrl.wPendingTasks, contains('v2/'));
    expect(controller.isLoading(), false);
  });

  test(
    'MIS distinguishes business failure from empty success and can retry',
    () async {
      var fail = true;
      dioConfig.dio.httpClientAdapter = FakeAdapter(
        (_) async => response(
          fail
              ? {'status': 0, 'message': 'Unavailable'}
              : {'status': 1, 'data': []},
        ),
      );
      final controller = MISPageCtrl();
      await controller.getData();
      expect(controller.error(), isNotEmpty);
      expect(controller.isLoading(), false);
      fail = false;
      await controller.getData();
      expect(controller.error(), isEmpty);
      expect(controller.list, isEmpty);
      expect(controller.isLoading(), false);
    },
  );
}
