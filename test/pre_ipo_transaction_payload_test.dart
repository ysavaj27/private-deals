import 'package:dio/dio.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'purchase sends v2 orders with deal_id, investor, shares, and share_price',
    () async {
      final originalInterceptors = dioConfig.dio.interceptors.toList();
      dioConfig.dio.interceptors.clear();
      addTearDown(() {
        dioConfig.dio.interceptors.clear();
        dioConfig.dio.interceptors.addAll(originalInterceptors);
      });
      Map<String, dynamic> payload = {};
      String path = '';
      dioConfig.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.method == 'GET') {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'status': 1,
                    'data': [
                      {'id': 1, 'preipo_kyc_status': 1},
                      {'id': 2, 'preipo_kyc_status': 1},
                    ],
                  },
                ),
              );
              return;
            }
            path = options.path;
            payload = Map<String, dynamic>.from(options.data as Map);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'status': 1,
                  'message': 'Orders placed successfully.',
                  'data': [],
                },
              ),
            );
          },
        ),
      );
      await WPreIpoTransactionApi.buy(
        list: [
          SelectInvestorModel(investorId: 1, quantity: 300, price: 40),
          SelectInvestorModel(investorId: 2, quantity: 350, price: 45),
        ],
        dealId: 15,
      );
      expect(path, 'v2/business/pre-ipo/buy');
      expect(payload.containsKey('orders'), isTrue);
      expect(payload['orders'], [
        {'deal_id': 15, 'investor_id': 1, 'shares': 300, 'share_price': 40},
        {'deal_id': 15, 'investor_id': 2, 'shares': 350, 'share_price': 45},
      ]);
      expect(payload.containsKey('seller_id'), isFalse);
      expect(payload.containsKey('company_id'), isFalse);
      expect(payload.containsKey('distributer_price'), isFalse);
    },
  );

  test(
    'purchase can identify the deal by uuid when numeric id is absent',
    () async {
      final originalInterceptors = dioConfig.dio.interceptors.toList();
      dioConfig.dio.interceptors.clear();
      addTearDown(() {
        dioConfig.dio.interceptors.clear();
        dioConfig.dio.interceptors.addAll(originalInterceptors);
      });
      Map<String, dynamic> payload = {};
      dioConfig.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.method == 'GET') {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'status': 1,
                    'data': [
                      {'id': 22, 'preipo_kyc_status': 1},
                    ],
                  },
                ),
              );
              return;
            }
            payload = Map<String, dynamic>.from(options.data as Map);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'status': 1,
                  'message': 'Orders placed successfully.',
                  'data': [],
                },
              ),
            );
          },
        ),
      );
      await WPreIpoTransactionApi.buy(
        list: [
          SelectInvestorModel(investorId: 22, quantity: 2000, price: 22.73),
        ],
        dealUuid: '36340f5d-bd7d-4b34-8f21-f54ad8e7a18f',
      );
      expect(payload['orders'], [
        {
          'deal_uuid': '36340f5d-bd7d-4b34-8f21-f54ad8e7a18f',
          'investor_id': 22,
          'shares': 2000,
          'share_price': 22.73,
        },
      ]);
      expect((payload['orders'] as List).first.containsKey('deal_id'), isFalse);
    },
  );
}
