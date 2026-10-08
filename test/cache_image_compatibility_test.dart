import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/features/institution/support/plugins/cache_image.dart'
    as institution;
import 'package:private_deals/src/shared/plugins/cache_image.dart';
import 'package:private_deals/src/shared/plugins/loader.dart';
import 'package:private_deals/src/shared/widgets/image_placeholder.dart';

void main() {
  for (final useInstitution in [false, true]) {
    final workspace = useInstitution ? 'Institution' : 'Partner';

    testWidgets('$workspace retains the empty-image fallback and size', (
      tester,
    ) async {
      final image = useInstitution
          ? const institution.CacheImage(url: ' ', width: 72, height: 48)
          : const CacheImage(url: ' ', width: 72, height: 48);
      await tester.pumpWidget(MaterialApp(home: Center(child: image)));
      expect(find.byType(ImagePlaceholder), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(tester.getSize(find.byWidget(image)), const Size(72, 48));
    });

    testWidgets(
      '$workspace preserves the loading visual and custom callbacks',
      (tester) async {
        late BuildContext context;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (value) {
                context = value;
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        final CacheImage image = useInstitution
            ? const institution.CacheImage(
                url: 'https://example.invalid/logo.png',
              )
            : const CacheImage(url: 'https://example.invalid/logo.png');
        // Exercise placeholder construction without starting a network request.
        final networkImage = image.build(context) as CachedNetworkImage;
        await tester.pumpWidget(
          MaterialApp(home: networkImage.placeholder!(context, image.url)),
        );
        expect(
          find.byType(useInstitution ? SpinKitRipple : Loader),
          findsOneWidget,
        );

        final CacheImage custom = useInstitution
            ? institution.CacheImage(
                url: '',
                placeholderBuilder: (_) => const Text('Loading override'),
                errorWidget: (_, _, _) => const Text('Error override'),
              )
            : CacheImage(
                url: '',
                placeholderBuilder: (_) => const Text('Loading override'),
                errorWidget: (_, _, _) => const Text('Error override'),
              );
        await tester.pumpWidget(MaterialApp(home: custom));
        expect(find.text('Error override'), findsOneWidget);
        expect(find.text('Loading override'), findsNothing);
      },
    );

    testWidgets('$workspace logo keeps its dimensions and tap action', (
      tester,
    ) async {
      var taps = 0;
      final image = useInstitution
          ? institution.LogoImage(url: '', onTap: () => taps++)
          : LogoImage(url: '', onTap: () => taps++);
      await tester.pumpWidget(MaterialApp(home: Center(child: image)));
      expect(tester.getSize(find.byWidget(image)), const Size(48, 48));
      await tester.tap(find.byType(InkWell));
      expect(taps, 1);
    });
  }
}
