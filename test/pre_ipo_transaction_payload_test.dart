import 'package:dio/dio.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'purchase sends a seller id for every investor and keeps payment mode',
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
            payload = Map<String, dynamic>.from(options.data as Map);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'status': 1, 'message': 'Created'},
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
        companyId: 8,
        distributorPrice: 40,
        sellerId: 42,
      );
      expect(payload['seller_id'], [42, 42]);
      expect(payload['company_id'], [8, 8]);
      expect(payload['investor_id'], [1, 2]);
      expect(payload['shares'], [300, 350]);
      expect(payload['share_price'], [40, 45]);
      expect(payload['distributer_price'], [40, 40]);
      expect(
        payload['payment_mode'],
        List.filled(
          2,
          app.config.enumValues.primaryTransactionPaymentMode.rtgs,
        ),
      );
    },
  );
}
