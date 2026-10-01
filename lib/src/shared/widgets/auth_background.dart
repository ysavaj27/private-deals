import 'package:private_deals/src/shared/app_exports.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Soft geometric auth backdrop (brand primary blues).
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFFD5E2F2)),
          SvgPicture.asset(
            AppAssets.authBg,
            fit: BoxFit.cover,
            placeholderBuilder: (_) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
