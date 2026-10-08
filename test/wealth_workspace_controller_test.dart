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
    'Pending category requests keep their filters and ignore stale results',
    () async {
      final documentResponse = Completer<ResponseBody>();
      final documentStarted = Completer<void>();
      final adapter = FakeAdapter((options) async {
        if (options.queryParameters['pending_doc_sign'] == true) {
          documentStarted.complete();
          return documentResponse.future;
        }
        return response({
          'status': 1,
          'data': [
            {'id': 2, 'current_status': 'Payment pending'},
          ],
        });
      });
      dioConfig.dio.httpClientAdapter = adapter;
      final controller = KycPendingInvestorPageCtrl();
      final oldLoad = controller.selectType(PendingTaskEnum.document);
      await documentStarted.future;
      await controller.selectType(PendingTaskEnum.fundTransfer);
      documentResponse.complete(
        response({
          'status': 1,
          'data': [
            {'id': 1, 'current_status': 'Signature pending'},
          ],
        }),
      );
      await oldLoad;
      expect(controller.transactions.single.id, 2);
      expect(controller.type(), PendingTaskEnum.fundTransfer);
      expect(adapter.requests.last.queryParameters['pending_payment'], true);
      expect(
        adapter.requests.last.queryParameters.containsKey('pending_doc_sign'),
        false,
      );
      expect(controller.isLoading(), false);
    },
  );

  test('Pending refresh reloads both summary and KYC list', () async {
    final adapter = FakeAdapter(
      (options) async => response({
        'status': 1,
        'data': options.path == AppUrl.wPendingTasks
            ? {'pending_kyc': 4, 'document_sign': 2, 'pending_payment': 1}
            : [
                {'name': 'Updated investor'},
              ],
      }),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    final controller = KycPendingInvestorPageCtrl();
    await controller.refreshData();
    expect(controller.pendingTask().pendingKyc, 4);
    expect(controller.investorList.single.name, 'Updated investor');
    expect(
      adapter.requests
          .singleWhere((r) => r.path == AppUrl.wInvestorList)
          .queryParameters['is_kyc'],
      'All',
    );
    expect(controller.countsLoading(), false);
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
