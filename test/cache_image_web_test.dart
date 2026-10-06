@TestOn('browser')
library;

import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/plugins/cache_image.dart';
import 'package:private_deals/src/features/institution/support/plugins/cache_image.dart'
    as institution;

// Flutter's browser test server serves files under test/ at its root. These
// requests exercise the real web loader without depending on a remote CDN.
String logoUrl(String name) =>
    Uri.base.resolve('/fixtures/cache_image/$name.png').toString();

Future<void> waitForImage(WidgetTester tester) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    final images = tester.widgetList<RawImage>(find.byType(RawImage));
    if (images.isNotEmpty && images.every((image) => image.image != null)) {
      await tester.pump(const Duration(seconds: 2));
      return;
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
  }
  fail('The network logo did not finish loading');
}

Future<void> expectCenterPixel(
  WidgetTester tester,
  Key boundaryKey,
  List<int> expected,
) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(boundaryKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final offset = ((image.height ~/ 2) * image.width + image.width ~/ 2) * 4;
    expect(data.buffer.asUint8List(data.offsetInBytes + offset, 4), expected);
    image.dispose();
  });
}

void main() {
  final originalCacheManager = CachedNetworkImageProvider.defaultCacheManager;
  late CacheManager cacheManager;
  var cacheId = 0;
  setUp(() {
    // Do not share file-cache futures across widget tests' fake async zones.
    cacheManager = CacheManager(Config('image-web-test-${cacheId++}'));
    CachedNetworkImageProvider.defaultCacheManager = cacheManager;
  });
  tearDown(() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    await cacheManager.dispose();
    CachedNetworkImageProvider.defaultCacheManager = originalCacheManager;
  });

  for (final useInstitution in [false, true]) {
    testWidgets(
      '${useInstitution ? 'institution' : 'shared'} logo changes to the correct company',
      (tester) async {
        const boundaryKey = ValueKey('logo-pixels');
        Widget build(String url) => MaterialApp(
          home: Center(
            child: RepaintBoundary(
              key: boundaryKey,
              child: SizedBox(
                width: 40,
                height: 40,
                child: useInstitution
                    ? institution.CacheImage(url: url, fit: BoxFit.fill)
                    : CacheImage(url: url, fit: BoxFit.fill),
              ),
            ),
          ),
        );

        await tester.pumpWidget(build(logoUrl('red')));
        await waitForImage(tester);
        await expectCenterPixel(tester, boundaryKey, [255, 0, 0, 255]);
        // Inspect the provider actually used by the Image, not a separate test
        // provider: HTML-element decoding is the web cache-eviction regression.
        final provider =
            tester.widget<Image>(find.byType(Image)).image
                as CachedNetworkImageProvider;
        expect(
          provider.imageRenderMethodForWeb,
          ImageRenderMethodForWeb.HttpGet,
        );

        await tester.pumpWidget(build(logoUrl('blue')));
        await waitForImage(tester);
        await expectCenterPixel(tester, boundaryKey, [0, 0, 255, 255]);

        await tester.pumpWidget(build(logoUrl('red')));
        await waitForImage(tester);
        await expectCenterPixel(tester, boundaryKey, [255, 0, 0, 255]);
        await tester.pumpWidget(const SizedBox.shrink());
        // Let flutter_cache_manager's delayed housekeeping finish in this
        // test's fake clock before the next test gets a new timer zone.
        await tester.pump(const Duration(seconds: 11));
      },
    );
  }

  testWidgets('scrolling away, evicting, and returning preserves logo pixels', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ListView.builder(
          controller: controller,
          itemCount: 40,
          itemExtent: 100,
          itemBuilder: (_, index) => Center(
            child: RepaintBoundary(
              key: ValueKey('row-$index'),
              child: CacheImage(
                url: logoUrl(index.isEven ? 'red' : 'blue'),
                width: 40,
                height: 40,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    );
    await waitForImage(tester);
    await expectCenterPixel(tester, const ValueKey('row-0'), [255, 0, 0, 255]);
    await expectCenterPixel(tester, const ValueKey('row-1'), [0, 0, 255, 255]);

    controller.jumpTo(3000);
    await tester.pump();
    await waitForImage(tester);
    expect(find.byKey(const ValueKey('row-0')), findsNothing);
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    controller.jumpTo(0);
    await tester.pump();
    await waitForImage(tester);
    await expectCenterPixel(tester, const ValueKey('row-0'), [255, 0, 0, 255]);
    await expectCenterPixel(tester, const ValueKey('row-1'), [0, 0, 255, 255]);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 11));
  });
}
