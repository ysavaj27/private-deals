import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/institution_widgets/app_button.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/widgets/workspace_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppMotion', () {
    testWidgets('duration respects disableAnimations', (tester) async {
      late Duration withAnim;
      late Duration withoutAnim;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              withAnim = AppMotion.duration(context, AppMotion.normal);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(withAnim, AppMotion.normal);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                withoutAnim = AppMotion.duration(context, AppMotion.normal);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(withoutAnim, Duration.zero);
    });
  });

  group('showCustomDialog', () {
    testWidgets('opens and dismisses without leftover overlay', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return FilledButton(
                  onPressed: () {
                    showCustomDialog(
                      Material(
                        color: Colors.white,
                        child: SizedBox(
                          width: 200,
                          height: 120,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Dialog body'),
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(AppMotion.dialog);
      expect(find.text('Dialog body'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('Dialog body'), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });
  });

  group('AppButton', () {
    testWidgets('loading swap keeps outer size stable', (tester) async {
      var loading = false;
      Size? idleSize;
      Size? loadingSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: AppButton(
                    key: const ValueKey('cta'),
                    label: 'Continue',
                    isLoading: loading,
                    onPressed: () => setState(() => loading = true),
                  ),
                );
              },
            ),
          ),
        ),
      );

      final idleBox = tester.renderObject<RenderBox>(find.byKey(const ValueKey('cta')));
      idleSize = idleBox.size;

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(AppMotion.fast);

      final loadingBox =
          tester.renderObject<RenderBox>(find.byKey(const ValueKey('cta')));
      loadingSize = loadingBox.size;

      expect(loadingSize!.height, idleSize!.height);
      expect(
        (loadingSize.width - idleSize.width).abs(),
        lessThan(2),
      );
    });
  });

  group('TabButton', () {
    testWidgets('selection animates without overflow', (tester) async {
      final void Function(FlutterErrorDetails)? old = FlutterError.onError;
      final errors = <FlutterErrorDetails>[];
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = old);

      final current = 'a'.obs;
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                TabButton<String>(
                  title: 'Tab A',
                  type: 'a',
                  currentIndex: current,
                  onTap: () => current('a'),
                ),
                TabButton<String>(
                  title: 'Tab B',
                  type: 'b',
                  currentIndex: current,
                  onTap: () => current('b'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tab B'));
      await tester.pump();
      await tester.pump(AppMotion.fast);
      expect(current(), 'b');
      expect(
        errors.where((e) => e.toString().contains('OVERFLOW')),
        isEmpty,
      );
    });
  });

  group('WorkspacePage', () {
    testWidgets('loading to empty to content settles cleanly', (tester) async {
      var loading = true;
      var count = 0;
      var error = '';

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Expanded(
                      child: WorkspacePage(
                        title: 'Items',
                        subtitle: 'Test list',
                        loading: loading,
                        error: error,
                        itemCount: count,
                        onRefresh: () async {},
                        header: const [],
                        empty: const Text('Empty state'),
                        itemBuilder: (context, index) =>
                            Text('Row $index', key: ValueKey('row-$index')),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        loading = false;
                        error = '';
                        count = 0;
                      }),
                      child: const Text('Show empty'),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        loading = false;
                        error = '';
                        count = 2;
                      }),
                      child: const Text('Show content'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.text('Show empty'));
      await tester.pump();
      await tester.pump(AppMotion.normal);
      expect(find.text('Empty state'), findsOneWidget);

      await tester.tap(find.text('Show content'));
      await tester.pump();
      await tester.pump(AppMotion.normal);
      expect(find.text('Row 0'), findsOneWidget);
      expect(find.text('Row 1'), findsOneWidget);
    });
  });
}
