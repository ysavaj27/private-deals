import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/core/config/demo_environment.dart';
import 'package:private_deals/src/shared/theme/brand_colors.dart';
import 'package:private_deals/src/shared/widgets/demo_environment_banner.dart';

void main() {
  const liveUrl = 'https://partner.privatedeals.in/';
  const stagingUrl = 'https://staging.privatedeals.in/';
  const demoUrl = 'https://demo.privatedeals.in/';

  group('isDemoEnvironment', () {
    test('is on only for the demo host', () {
      expect(isDemoEnvironment(demoUrl), isTrue);
      expect(isDemoEnvironment('https://demo.privatedeals.in'), isTrue);
      expect(isDemoEnvironment('HTTPS://DEMO.PRIVATEDEALS.IN/'), isTrue);
      expect(isDemoEnvironment(' http://demo.privatedeals.in/ '), isTrue);
    });

    test('stays off for live, staging, and a path that only says demo', () {
      expect(isDemoEnvironment(liveUrl), isFalse);
      expect(isDemoEnvironment('https://www.privatedeals.in'), isFalse);
      expect(isDemoEnvironment(stagingUrl), isFalse);
      expect(isDemoEnvironment('https://www.privatedeals.in/demo'), isFalse);
      expect(
        isDemoEnvironment('https://www.privatedeals.in/demo.privatedeals.in'),
        isFalse,
      );
      expect(
        isDemoEnvironment('https://demo.privatedeals.in.example.com/'),
        isFalse,
      );
      expect(isDemoEnvironment(''), isFalse);
      expect(isDemoEnvironment('demo.privatedeals.in'), isFalse);
    });
  });

  group('isStagingEnvironment', () {
    test('is on only for the staging host', () {
      expect(isStagingEnvironment(stagingUrl), isTrue);
      expect(isStagingEnvironment('https://staging.privatedeals.in'), isTrue);
      expect(
        isStagingEnvironment('HTTPS://STAGING.PRIVATEDEALS.IN/'),
        isTrue,
      );
      expect(
        isStagingEnvironment(' http://staging.privatedeals.in/ '),
        isTrue,
      );
    });

    test('stays off for live, demo, and a path that only says staging', () {
      expect(isStagingEnvironment(liveUrl), isFalse);
      expect(isStagingEnvironment('https://www.privatedeals.in'), isFalse);
      expect(isStagingEnvironment(demoUrl), isFalse);
      expect(
        isStagingEnvironment('https://www.privatedeals.in/staging'),
        isFalse,
      );
      expect(
        isStagingEnvironment(
          'https://www.privatedeals.in/staging.privatedeals.in',
        ),
        isFalse,
      );
      expect(
        isStagingEnvironment('https://staging.privatedeals.in.example.com/'),
        isFalse,
      );
      expect(isStagingEnvironment(''), isFalse);
      expect(isStagingEnvironment('staging.privatedeals.in'), isFalse);
    });
  });

  testWidgets('live builds do not show an environment banner', (tester) async {
    for (final baseUrl in [liveUrl, 'https://www.privatedeals.in']) {
      await _pumpFrame(tester, baseUrl: baseUrl, topInset: 47);
      expect(find.text(DemoEnvironmentBanner.message), findsNothing);
      expect(find.text(StagingEnvironmentBanner.message), findsNothing);
      expect(find.text(DemoEnvironmentBanner.actionLabel), findsNothing);
      expect(find.text('top:47.0'), findsOneWidget);
    }
  });

  testWidgets('the demo host shows the notice and opens the live site', (
    tester,
  ) async {
    final opened = <String>[];
    await _pumpFrame(
      tester,
      baseUrl: demoUrl,
      topInset: 47,
      onOpenLive: opened.add,
    );

    expect(find.text(DemoEnvironmentBanner.message), findsOneWidget);
    expect(find.text(StagingEnvironmentBanner.message), findsNothing);
    expect(find.text(DemoEnvironmentBanner.actionLabel), findsOneWidget);
    expect(find.byIcon(Icons.north_east_rounded), findsOneWidget);
    expect(find.text('top:0.0'), findsOneWidget);
    expect(DemoEnvironmentBanner.liveAppUrl, liveUrl);

    final message = tester.widget<Text>(
      find.text(DemoEnvironmentBanner.message),
    );
    expect(message.style?.color, DemoEnvironmentBanner.messageColor);

    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(DemoEnvironmentBanner),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.color, DemoEnvironmentBanner.background);
    expect(material.color, isNot(BrandColors.navyAction));
    expect(material.color, isNot(BrandColors.gold));
    expect(material.color, isNot(BrandColors.navy));
    expect(material.color, isNot(StagingEnvironmentBanner.background));

    await tester.tap(find.text(DemoEnvironmentBanner.actionLabel));
    expect(opened, [liveUrl]);
  });

  testWidgets('the staging host shows its own notice and opens the live site', (
    tester,
  ) async {
    final opened = <String>[];
    await _pumpFrame(
      tester,
      baseUrl: stagingUrl,
      topInset: 47,
      onOpenLive: opened.add,
    );

    expect(find.text(StagingEnvironmentBanner.message), findsOneWidget);
    expect(find.text(DemoEnvironmentBanner.message), findsNothing);
    expect(find.text(StagingEnvironmentBanner.actionLabel), findsOneWidget);
    expect(find.byIcon(Icons.north_east_rounded), findsOneWidget);
    expect(find.text('top:0.0'), findsOneWidget);
    expect(StagingEnvironmentBanner.liveAppUrl, liveUrl);
    expect(
      StagingEnvironmentBanner.message,
      isNot(DemoEnvironmentBanner.message),
    );
    expect(
      StagingEnvironmentBanner.background,
      isNot(DemoEnvironmentBanner.background),
    );

    final message = tester.widget<Text>(
      find.text(StagingEnvironmentBanner.message),
    );
    expect(message.style?.color, StagingEnvironmentBanner.messageColor);

    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(StagingEnvironmentBanner),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.color, StagingEnvironmentBanner.background);
    expect(material.color, isNot(BrandColors.navyAction));
    expect(material.color, isNot(BrandColors.gold));
    expect(material.color, isNot(BrandColors.navy));
    expect(material.color, isNot(DemoEnvironmentBanner.background));

    await tester.tap(find.text(StagingEnvironmentBanner.actionLabel));
    expect(opened, [liveUrl]);
  });

  testWidgets('demo notice and action stay readable across screen sizes', (
    tester,
  ) async {
    await _expectBannerReadableAcrossSizes(
      tester,
      baseUrl: demoUrl,
      message: DemoEnvironmentBanner.message,
      bannerType: DemoEnvironmentBanner,
    );
  });

  testWidgets('staging notice and action stay readable across screen sizes', (
    tester,
  ) async {
    await _expectBannerReadableAcrossSizes(
      tester,
      baseUrl: stagingUrl,
      message: StagingEnvironmentBanner.message,
      bannerType: StagingEnvironmentBanner,
    );
  });
}

Future<void> _expectBannerReadableAcrossSizes(
  WidgetTester tester, {
  required String baseUrl,
  required String message,
  required Type bannerType,
}) async {
  const liveUrl = 'https://partner.privatedeals.in/';
  for (final width in [280.0, 390.0, 600.0, 1280.0]) {
    for (final textScale in [1.0, 2.0]) {
      final opened = <String>[];
      await _pumpFrame(
        tester,
        baseUrl: baseUrl,
        width: width,
        textScale: textScale,
        onOpenLive: opened.add,
      );

      final notice = find.byWidgetPredicate(
        (widget) => widget is Text && widget.semanticsLabel == message,
      );
      final messageParagraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: notice, matching: find.byType(RichText)),
      );
      expect(
        messageParagraph.didExceedMaxLines,
        isFalse,
        reason: 'width=$width scale=$textScale',
      );
      final bannerRect = tester.getRect(find.byType(bannerType));
      final action = find.byType(TextButton).evaluate().isNotEmpty
          ? find.byType(TextButton)
          : find.byType(IconButton);
      final actionRect = tester.getRect(action);
      expect(bannerRect.height, lessThanOrEqualTo(textScale == 1 ? 58 : 70));
      expect(tester.getCenter(notice).dy, closeTo(actionRect.center.dy, 1));
      expect(bannerRect.contains(actionRect.topLeft), isTrue);
      expect(actionRect.right, lessThanOrEqualTo(bannerRect.right));
      expect(actionRect.bottom, lessThanOrEqualTo(bannerRect.bottom));
      await tester.tap(action);
      expect(opened, [liveUrl]);
      expect(tester.takeException(), isNull);
    }
  }
}

Future<void> _pumpFrame(
  WidgetTester tester, {
  required String baseUrl,
  double topInset = 0,
  double width = 1280,
  double textScale = 1,
  void Function(String url)? onOpenLive,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light, useMaterial3: true),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            padding: media.padding.copyWith(top: topInset),
            textScaler: TextScaler.linear(textScale),
          ),
          child: DemoEnvironmentFrame(
            baseUrl: baseUrl,
            onOpenLive: onOpenLive,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: Builder(
        builder: (context) => Text('top:${MediaQuery.paddingOf(context).top}'),
      ),
    ),
  );
}
