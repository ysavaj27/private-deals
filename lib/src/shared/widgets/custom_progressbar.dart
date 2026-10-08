import 'package:private_deals/src/shared/app_exports.dart';

class CustomProgressBar extends StatefulWidget {
  final double progress;
  final double width;
  final double height;
  final Color? backgroundColor;
  final List<Color> gradientColors;
  final double radius;

  const CustomProgressBar({
    super.key,
    required this.progress,
    this.width = double.infinity,
    this.height = 13.0,
    this.backgroundColor,
    this.gradientColors = const [
      Color(0xFF0B0B0B),
      Color(0xFF405D24),
      Color(0xFF50752B),
      Color(0xFF608D35),
    ],
    this.radius = 5,
  });

  @override
  State<CustomProgressBar> createState() => _CustomProgressBarState();
}

class _CustomProgressBarState extends State<CustomProgressBar> {
  double progress = 0;

  @override
  void initState() {
    changeValue();
    super.initState();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void changeValue() async {
    await 1.delay();
    if (_disposed || !mounted) return;
    setState(() {
      progress = widget.progress;
    });
  }

  @override
  void didUpdateWidget(covariant CustomProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      setState(() {
        progress = widget.progress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? context.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
      ),
      alignment: Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
        child: AnimatedFractionallySizedBox(
          widthFactor: progress,
          duration: const Duration(seconds: 2),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomPercentageProgressBar extends StatefulWidget {
  final double progress;

  const CustomPercentageProgressBar(this.progress, {super.key});

  @override
  State<CustomPercentageProgressBar> createState() =>
      _CustomPercentageProgressBarState();
}

class _CustomPercentageProgressBarState
    extends State<CustomPercentageProgressBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 20,
      decoration: BoxDecoration(
        color: context.theme.disabledColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.all(Radius.circular(19)),
      ),
      alignment: Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(19)),
        child: AnimatedFractionallySizedBox(
          widthFactor: widget.progress / 100,
          duration: const Duration(seconds: 1),
          child: Container(
            decoration: const BoxDecoration(color: Color(0xff1A5808)),
          ),
        ),
      ),
    );
  }
}
