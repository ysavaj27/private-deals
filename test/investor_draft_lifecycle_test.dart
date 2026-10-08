import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/catalog/presentation/investor_draft_lifecycle.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';

class DraftController extends GetxController with InvestorDraftLifecycle {}

SelectInvestorModel draft(int id) => SelectInvestorModel(
  investorId: id,
  quantityCTRL: TextEditingController(text: '10'),
  priceCTRL: TextEditingController(text: '100'),
);

void main() {
  testWidgets(
    'removing a mounted investor row releases its inputs after unmount',
    (tester) async {
      final controller = DraftController();
      final selected = draft(1);
      final quantity = selected.quantityCTRL!;
      final price = selected.priceCTRL!;
      controller.investorList.add(selected);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Obx(
              () => Column(
                children: [
                  for (final row in controller.investorList)
                    TextField(
                      key: ValueKey(row.investorId),
                      controller: row.quantityCTRL,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      controller.removeInvestor(selected);
      // Removal must not dispose inputs still attached to the outgoing widget.
      expect(() => quantity.addListener(() {}), returnsNormally);
      await tester.pump();
      expect(find.byType(TextField), findsNothing);
      expect(() => quantity.addListener(() {}), throwsFlutterError);
      expect(() => price.addListener(() {}), throwsFlutterError);
      expect(tester.takeException(), isNull);
      controller.onDelete();
    },
  );

  testWidgets(
    'clearing and closing before the next frame disposes each draft once',
    (tester) async {
      final controller = DraftController();
      final selected = [draft(1), draft(2)];
      final inputs = [
        for (final row in selected) ...[row.quantityCTRL!, row.priceCTRL!],
      ];
      controller.investorList.addAll(selected);
      controller.clearInvestors();
      controller.onDelete();
      await tester.pump();
      for (final input in inputs) {
        expect(() => input.addListener(() {}), throwsFlutterError);
      }
      expect(tester.takeException(), isNull);
    },
  );
}
