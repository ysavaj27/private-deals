import 'package:private_deals/src/shared/app_exports.dart';
import 'package:dio/dio.dart';
import 'package:pdfx/pdfx.dart';

class PdfViewerDialog extends StatelessWidget {
  final String path;
  final String title;

  const PdfViewerDialog({super.key, required this.path, this.title = ''});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      width: context.width,
      height: context.isPhone ? context.height * 0.55 : context.height,
      color: context.theme.scaffoldBackgroundColor,
      margin: context.isPhone
          ? const EdgeInsets.all(10)
          : EdgeInsets.symmetric(
              vertical: context.height * 0.1, horizontal: context.width * 0.1),
      radius: 10,
      padding: const EdgeInsets.all(10),
      child: PdfViewerDialogView(path: path, title: title),
    );
  }
}

class PdfViewerDialogView extends StatefulWidget {
  final String path;
  final String title;

  const PdfViewerDialogView({super.key, required this.path, this.title = ''});

  @override
  State<PdfViewerDialogView> createState() => _PdfViewerDialogViewState();
}

class _PdfViewerDialogViewState extends State<PdfViewerDialogView> {
  PdfController? _pdfController;
  PdfControllerPinch? _pdfControllerPinch;
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final pdfBytes = await _loadPdfFromUrl(widget.path);

      if (!mounted) return;

      setState(() {
        if (PlatformHelper.isWindows) {
          _pdfController = PdfController(
            document: PdfDocument.openData(pdfBytes),
          );
        } else {
          _pdfControllerPinch = PdfControllerPinch(
            document: PdfDocument.openData(pdfBytes),
          );
        }
      });
    } catch (e, t) {
      logger.d(
        'Error loading PDF: $e',
        stackTrace: t,
      );
    }
  }

  Future<Uint8List> _loadPdfFromUrl(String url) async {
    try {
      final response = await dio.get(url,
          options: Options(responseType: ResponseType.bytes));
      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        throw Exception('Failed to load PDF');
      }
    } on Exception catch (e, t) {
      logger.d(e, stackTrace: t);
      throw Exception('Failed to load PDF ${e}');
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _pdfControllerPinch?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title.isNotEmpty ? widget.title : 'PDF Viewer'),
        leading: PlatformHelper.isWindows ? SizedBox() : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: () {
              if (PlatformHelper.isWindows && _pdfController != null) {
                _pdfController!.previousPage(
                  curve: Curves.ease,
                  duration: const Duration(milliseconds: 100),
                );
              } else if (_pdfControllerPinch != null) {
                _pdfControllerPinch!.previousPage(
                  curve: Curves.ease,
                  duration: const Duration(milliseconds: 100),
                );
              }
            },
          ),
          if (PlatformHelper.isWindows && _pdfController != null)
            PdfPageNumber(
              controller: _pdfController!,
              builder: (_, loadingState, page, pagesCount) => Center(
                child: Text('$page/${pagesCount ?? 0}',
                    style: const TextStyle(fontSize: 18)),
              ),
            )
          else if (_pdfControllerPinch != null)
            PdfPageNumber(
              controller: _pdfControllerPinch!,
              builder: (_, loadingState, page, pagesCount) => Center(
                child: Text('$page/${pagesCount ?? 0}',
                    style: const TextStyle(fontSize: 18)),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: () {
              if (PlatformHelper.isWindows && _pdfController != null) {
                _pdfController!.nextPage(
                  curve: Curves.ease,
                  duration: const Duration(milliseconds: 100),
                );
              } else if (_pdfControllerPinch != null) {
                _pdfControllerPinch!.nextPage(
                  curve: Curves.ease,
                  duration: const Duration(milliseconds: 100),
                );
              }
            },
          ),
          PlatformHelper.isWindows
              ? IconButton(
                  onPressed: Get.back,
                  icon: Icon(
                    Icons.close,
                    color: context.iconColor,
                  ),
                )
              : SizedBox(),
        ],
      ),
      body: PlatformHelper.isWindows
          ? (_pdfController == null
              ? const Loader()
              : PdfView(
                  controller: _pdfController!,
                  pageSnapping: true,
                  reverse: false,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  scrollDirection: Axis.vertical,
                ))
          : (_pdfControllerPinch == null
              ? const Loader()
              : PdfViewPinch(
                  controller: _pdfControllerPinch!,
                  builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                    options: const DefaultBuilderOptions(),
                    documentLoaderBuilder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                    pageLoaderBuilder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                    errorBuilder: (_, error) =>
                        Center(child: Text(error.toString())),
                  ),
                )),
    );
  }
}

class PdfViewerPage extends StatefulWidget {
  final String path;
  final String title;

  const PdfViewerPage({super.key, required this.path, this.title = ''});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  static const int _initialPage = 1;
  PdfController? _pdfController;
  PdfControllerPinch? _pdfControllerPinch;
  Dio dio = Dio();

  @override
  void initState() {
    _loadPdf();
    super.initState();
  }

  Future<void> _loadPdf() async {
    try {
      final pdfBytes = await _loadPdfFromUrl(widget.path);
      setState(() {
        if (PlatformHelper.isWindows) {
          // Initialize PdfController for Windows
          _pdfController = PdfController(
            document: PdfDocument.openData(pdfBytes),
            initialPage: _initialPage,
          );
        } else {
          // Initialize PdfControllerPinch for non-Windows
          _pdfControllerPinch = PdfControllerPinch(
            document: PdfDocument.openData(pdfBytes),
            initialPage: _initialPage,
          );
        }
      });
    } catch (e, t) {
      logger.d('Error loading PDF: $e', stackTrace: t);
    }
  }

  Future<Uint8List> _loadPdfFromUrl(String url) async {
    try {
      final response = await dio.get(url,
          options: Options(responseType: ResponseType.bytes));
      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        throw Exception('Failed to load PDF');
      }
    } on Exception catch (e, t) {
      logger.d(e, stackTrace: t);
      throw Exception('Failed to load PDF ${e}');
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _pdfControllerPinch?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title.isNotEmpty ? widget.title : 'Pdf'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: () {
              _pdfControllerPinch?.previousPage(
                curve: Curves.ease,
                duration: const Duration(milliseconds: 100),
              );
              _pdfController?.previousPage(
                curve: Curves.ease,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
          _pdfControllerPinch == null && _pdfController == null
              ? const Loader()
              : PdfPageNumber(
                  controller: _pdfControllerPinch ?? _pdfController!,
                  builder: (_, loadingState, page, pagesCount) => Container(
                    alignment: Alignment.center,
                    child: Text(
                      '$page/${pagesCount ?? 0}',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: () {
              _pdfControllerPinch?.nextPage(
                curve: Curves.ease,
                duration: const Duration(milliseconds: 100),
              );
              _pdfController?.nextPage(
                curve: Curves.ease,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
        ],
      ),
      body: PlatformHelper.isWindows
          ? (_pdfController == null
              ? const Loader()
              : PdfView(
                  controller: _pdfController!,
                  scrollDirection: Axis.vertical,
                ))
          : (_pdfControllerPinch == null
              ? const Loader()
              : PdfViewPinch(
                  controller: _pdfControllerPinch!,
                  builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                    options: const DefaultBuilderOptions(),
                    documentLoaderBuilder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                    pageLoaderBuilder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                    errorBuilder: (_, error) =>
                        Center(child: Text(error.toString())),
                  ),
                )),
    );
  }
}
