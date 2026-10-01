import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/app/bootstrap/init_screen_ctrl.dart';

class InitScreen extends StatelessWidget {
  final InitScreenCtrl c = Get.put(InitScreenCtrl());

  InitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF121212),
      body: Container(
        width: context.width,
        height: context.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [context.theme.primaryColor, const Color(0xff000000)],
          ),
        ),
        child: Center(
          child: ZoomIn(
            duration: const Duration(milliseconds: 1000),
            child: const Loader(),
          ),
        ),
      ),
    );
  }
}
