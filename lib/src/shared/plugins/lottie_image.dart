import 'package:private_deals/src/shared/app_exports.dart';
import 'package:lottie/lottie.dart';

class LottieImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Alignment? alignment;
  final bool? repeat;

  const LottieImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit,
    this.alignment,
    this.repeat,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      path,
      width: width,
      height: height,

      fit: fit,
      alignment: alignment,
      repeat: repeat,
    );
  }
}

class LottieAnimationDemo extends StatefulWidget {
  @override
  _LottieAnimationDemoState createState() => _LottieAnimationDemoState();
}

class _LottieAnimationDemoState extends State<LottieAnimationDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
          seconds: 8), // Increase the duration to slow down the animation
    )..repeat(); // Make the animation loop
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      AppAssets.pluses, // Replace with your animation file
      controller: _controller,
      onLoaded: (composition) {
        _controller.duration =
            composition.duration * 2; // Adjust duration to slow down
      },
    );
  }
}
