import 'package:dio/dio.dart';
import 'package:pdfx/pdfx.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class PdfViewerDialog extends StatelessWidget {
  final String path;
  final String title;

  const PdfViewerDialog({super.key, required this.path, this.title = ''});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: EdgeInsets.all(size.width < 600 ? 12 : 32),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: SizedBox(
        width: 1200,
        height: size.height * .9,
        child: PdfViewerDialogView(path: path, title: title),
      ),
    );
  }
}

class PdfViewerPage extends StatelessWidget {
  final String path;
  final String title;

  const PdfViewerPage({super.key, required this.path, this.title = ''});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: PdfViewerDialogView(path: path, title: title),
    ),
  );
}

/// The same document reader is used in dialogs and full-screen routes.
class PdfViewerDialogView extends StatefulWidget {
  final String path;
  final String title;
  final Future<PdfDocument> Function(String path)? documentLoader;

  const PdfViewerDialogView({
    super.key,
    required this.path,
    this.title = '',
    this.documentLoader,
  });

  @override
  State<PdfViewerDialogView> createState() => _PdfViewerDialogViewState();
}

class _PdfViewerDialogViewState extends State<PdfViewerDialogView> {
  final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 45),
    ),
  );
  CancelToken? _request;
  PdfController? _controller;
  PdfControllerPinch? _pinchController;
  int _generation = 0;
  int _page = 1;
  int _pages = 0;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PdfViewerDialogView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) _load();
  }

  Future<PdfDocument> _download(String path, CancelToken token) async {
    final uri = Uri.tryParse(path);
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw const FormatException('Invalid document URL');
    }
    final response = await _dio.get<List<int>>(
      path,
      cancelToken: token,
      options: Options(responseType: ResponseType.bytes),
    );
    if (response.statusCode != 200 ||
        response.data == null ||
        response.data!.isEmpty) {
      throw const FormatException('Document unavailable');
    }
    return PdfDocument.openData(Uint8List.fromList(response.data!));
  }

  Future<void> _load() async {
    final generation = ++_generation;
    _request?.cancel();
    final token = _request = CancelToken();
    final oldController = _controller;
    final oldPinchController = _pinchController;
    setState(() {
      _controller = null;
      _pinchController = null;
      _ready = false;
      _failed = false;
      _page = 1;
      _pages = 0;
    });
    // Let the old viewer detach before disposing its controller.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldController?.dispose();
      oldPinchController?.dispose();
    });
    try {
      final document =
          await (widget.documentLoader?.call(widget.path) ??
              _download(widget.path, token));
      if (!mounted || generation != _generation) {
        await document.close();
        return;
      }
      if (document.pagesCount < 1) {
        await document.close();
        throw const FormatException('Empty document');
      }
      setState(() {
        if (PlatformHelper.isWindows) {
          _controller = PdfController(document: Future.value(document));
        } else {
          _pinchController = PdfControllerPinch(
            document: Future.value(document),
          );
        }
      });
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() => _failed = true);
      }
    }
  }

  void _loaded(PdfDocument document) {
    if (!mounted) return;
    setState(() {
      _pages = document.pagesCount;
      _ready = true;
    });
  }

  void _pageChanged(int page) {
    if (mounted) setState(() => _page = page);
  }

  void _documentError(Object error) {
    if (mounted) {
      setState(() {
        _failed = true;
        _ready = false;
      });
    }
  }

  void _turnPage(int delta) {
    if (!_ready || _page + delta < 1 || _page + delta > _pages) return;
    const duration = Duration(milliseconds: 220);
    final target = _page + delta;
    _controller?.animateToPage(
      target,
      duration: duration,
      curve: Curves.easeOut,
    );
    _pinchController?.animateToPage(
      pageNumber: target,
      duration: duration,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    ++_generation;
    _request?.cancel();
    _dio.close(force: true);
    _controller?.dispose();
    _pinchController?.dispose();
    super.dispose();
  }

  Widget _status(BuildContext context, {bool failed = false}) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (failed)
              Icon(
                Icons.description_outlined,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant,
              )
            else
              const SizedBox.square(
                dimension: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            const SizedBox(height: 20),
            Text(
              failed ? 'Unable to open this document' : 'Opening document…',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              failed
                  ? 'Check your connection and try again.'
                  : 'Your PDF will appear here shortly.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (failed) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _document(BuildContext context) {
    if (_failed) return _status(context, failed: true);
    if (_controller != null) {
      return PdfView(
        key: ValueKey(_generation),
        controller: _controller!,
        scrollDirection: Axis.vertical,
        onDocumentLoaded: _loaded,
        onDocumentError: _documentError,
        onPageChanged: _pageChanged,
        builders: PdfViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: _status,
          pageLoaderBuilder: _status,
          errorBuilder: (context, _) => _status(context, failed: true),
        ),
      );
    }
    if (_pinchController != null) {
      return PdfViewPinch(
        key: ValueKey(_generation),
        controller: _pinchController!,
        padding: 16,
        onDocumentLoaded: _loaded,
        onDocumentError: _documentError,
        onPageChanged: _pageChanged,
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: _status,
          pageLoaderBuilder: _status,
          errorBuilder: (context, _) => _status(context, failed: true),
        ),
      );
    }
    return _status(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(AppRadii.control),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_outlined,
                    color: colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title.trim().isEmpty
                            ? 'Document preview'
                            : widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'PDF document',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Close document',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ColoredBox(
              color: colors.surfaceContainerLowest,
              child: _document(context),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Previous page',
                  onPressed: _ready && _page > 1 ? () => _turnPage(-1) : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _ready ? 'Page $_page of $_pages' : 'PDF preview',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Next page',
                  onPressed: _ready && _page < _pages
                      ? () => _turnPage(1)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
