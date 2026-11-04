import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdfx/pdfx.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class _Document extends PdfDocument {
  _Document({int pages = 3})
    : super(sourceName: 'test', id: 'test', pagesCount: pages);
  @override
  Future<void> close() async {
    isClosed = true;
  }

  @override
  Future<PdfPage> getPage(
    int pageNumber, {
    bool autoCloseAndroid = false,
  }) async => _Page(this, pageNumber);
}

class _Page extends PdfPage {
  _Page(PdfDocument doc, int page)
    : super(
        document: doc,
        id: '$page',
        pageNumber: page,
        width: 600,
        height: 800,
        autoCloseAndroid: false,
      );
  @override
  Future<void> close() async {
    isClosed = true;
  }

  @override
  Future<PdfPageImage?> render({
    required double width,
    required double height,
    PdfPageImageFormat format = PdfPageImageFormat.jpeg,
    String? backgroundColor,
    Rect? cropRect,
    int quality = 100,
    bool forPrint = false,
    bool removeTempFile = true,
  }) async => null;
  @override
  Future<PdfPageTexture> createTexture() async => _Texture(pageNumber);
}

class _Texture extends PdfPageTexture {
  _Texture(int page) : super(id: page, pageId: '$page', pageNumber: page);
  @override
  int? textureWidth;
  @override
  int? textureHeight;
  @override
  bool get hasUpdatedTexture => textureWidth != null;
  @override
  Future<void> dispose() async {}
  @override
  Future<bool> updateRect({
    required String documentId,
    int destinationX = 0,
    int destinationY = 0,
    int? width,
    int? height,
    int sourceX = 0,
    int sourceY = 0,
    int? textureWidth,
    int? textureHeight,
    double? fullWidth,
    double? fullHeight,
    String? backgroundColor,
    bool allowAntiAliasing = true,
  }) async {
    this.textureWidth = textureWidth;
    this.textureHeight = textureHeight;
    return true;
  }
}

Future<void> _pump(
  WidgetTester tester,
  Future<PdfDocument> Function(String) loader, {
  double width = 1280,
  bool dark = false,
  String path = 'https://example.com/Deck.pdf',
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: Scaffold(
        body: PdfViewerDialogView(
          path: path,
          title: 'Northstar Technologies — Pitch deck',
          documentLoader: loader,
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('responsive document reader, page boundaries and navigation', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final width in [320.0, 390.0, 1280.0]) {
      for (final dark in [false, true]) {
        await tester.pumpWidget(const SizedBox());
        await _pump(tester, (_) async => _Document(), width: width, dark: dark);
        await tester.pumpAndSettle();
        expect(find.text('Page 1 of 3'), findsOneWidget);
        expect(
          tester
              .widget<IconButton>(
                find.widgetWithIcon(IconButton, Icons.chevron_left_rounded),
              )
              .onPressed,
          isNull,
        );
        await tester.tap(
          find.widgetWithIcon(IconButton, Icons.chevron_right_rounded),
        );
        await tester.pumpAndSettle();
        expect(find.text('Page 2 of 3'), findsOneWidget);
        await tester.tap(
          find.widgetWithIcon(IconButton, Icons.chevron_right_rounded),
        );
        await tester.pumpAndSettle();
        expect(find.text('Page 3 of 3'), findsOneWidget);
        expect(
          tester
              .widget<IconButton>(
                find.widgetWithIcon(IconButton, Icons.chevron_right_rounded),
              )
              .onPressed,
          isNull,
        );
        await tester.tap(
          find.widgetWithIcon(IconButton, Icons.chevron_left_rounded),
        );
        await tester.pumpAndSettle();
        expect(find.text('Page 2 of 3'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('loading disables navigation; failed downloads can be retried', (
    tester,
  ) async {
    final pending = Completer<PdfDocument>();
    var calls = 0;
    await _pump(tester, (_) {
      calls++;
      return calls == 1 ? pending.future : Future.value(_Document());
    });
    expect(find.text('Opening document…'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.chevron_right_rounded),
          )
          .onPressed,
      isNull,
    );
    pending.completeError(Exception('Network unavailable'));
    await tester.pumpAndSettle();
    expect(find.text('Unable to open this document'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Page 1 of 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('closing during download disposes late document safely', (
    tester,
  ) async {
    final pending = Completer<PdfDocument>();
    await _pump(tester, (_) => pending.future);
    await tester.pumpWidget(const SizedBox());
    final document = _Document();
    pending.complete(document);
    await tester.pump();
    expect(document.isClosed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing documents ignores old responses and resets page', (
    tester,
  ) async {
    final pending = Completer<PdfDocument>();
    await _pump(tester, (_) => pending.future);
    await _pump(
      tester,
      (_) async => _Document(pages: 1),
      path: 'https://example.com/New.pdf',
    );
    await tester.pumpAndSettle();
    final old = _Document();
    pending.complete(old);
    await tester.pumpAndSettle();
    expect(old.isClosed, isTrue);
    expect(find.text('Page 1 of 1'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.chevron_right_rounded),
          )
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('dialog and full-screen reader both close back to the caller', (
    tester,
  ) async {
    for (final dialog in [true, false]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () {
                  if (dialog) {
                    showDialog<void>(
                      context: context,
                      builder: (_) =>
                          const PdfViewerDialog(path: '', title: 'Pitch deck'),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const PdfViewerPage(path: '', title: 'Pitch deck'),
                      ),
                    );
                  }
                },
                child: const Text('Open document'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open document'));
      await tester.pumpAndSettle();
      expect(find.text('Pitch deck'), findsOneWidget);
      await tester.tap(find.byTooltip('Close document'));
      await tester.pumpAndSettle();
      expect(find.text('Pitch deck'), findsNothing);
      expect(find.text('Open document'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('invalid URLs give a recoverable error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PdfViewerDialogView(path: '')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Unable to open this document'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
