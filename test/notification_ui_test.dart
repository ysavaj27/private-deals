import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/notification/notification_page.dart';
import 'package:private_deals/src/shared/app_exports.dart';

void main() {
  group('NotificationModel image parsing', () {
    test('reads flat image_url and resolves relative paths when possible', () {
      final model = NotificationModel.fromJson({
        'id': 1,
        'title': 'Deal update',
        'body': 'Your order moved forward.',
        'image_url': 'https://cdn.example.com/n.png',
        'created_at': DateTime.now().toIso8601String(),
      });
      expect(model.hasImage, isTrue);
      expect(model.image, contains('cdn.example.com'));
    });

    test('reads nested media.url', () {
      final model = NotificationModel.fromJson({
        'title': 'News',
        'body': 'Hello',
        'media': {'url': 'https://cdn.example.com/thumb.jpg'},
        'created_at': DateTime.now().toIso8601String(),
      });
      expect(model.image, 'https://cdn.example.com/thumb.jpg');
    });

    test('isRecent for items within 24 hours', () {
      final model = NotificationModel.fromJson({
        'title': 'Fresh',
        'body': 'Just now',
        'created_at': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
      });
      expect(model.isRecent, isTrue);
    });
  });

  group('NotificationTile', () {
    Future<void> pumpTile(
      WidgetTester tester, {
      required NotificationModel model,
      bool dark = false,
      bool compact = false,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: compact ? 380 : 360,
                child: NotificationTile(model: model, compact: compact),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders title, body, and New badge in light theme',
        (tester) async {
      final model = NotificationModel(
        title: 'KYC approved',
        body: 'Investor Aarav is ready to invest.',
        createdAt: DateTime.now(),
      );
      await pumpTile(tester, model: model);
      expect(find.text('KYC approved'), findsOneWidget);
      expect(find.textContaining('ready to invest'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('renders in dark theme without hardcoded black drawer issues',
        (tester) async {
      final model = NotificationModel(
        title: 'Settlement complete',
        body: 'Funds have settled for deal #42.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      );
      await pumpTile(tester, model: model, dark: true, compact: true);
      expect(find.text('Settlement complete'), findsOneWidget);
      expect(find.text('New'), findsNothing);
    });

    testWidgets('expands long body on show more', (tester) async {
      final longBody = List.filled(40, 'Update').join(' ');
      final model = NotificationModel(
        title: 'Long notice',
        body: longBody,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      );
      await pumpTile(tester, model: model);
      expect(find.text('Show more'), findsOneWidget);
      await tester.tap(find.text('Show more'));
      await tester.pumpAndSettle();
      expect(find.text('Show less'), findsOneWidget);
    });
  });
}
