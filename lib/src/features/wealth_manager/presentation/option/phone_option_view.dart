import 'package:private_deals/src/shared/app_exports.dart';

class PhoneOptionView extends StatelessWidget {
  const PhoneOptionView({super.key});

  @override
  Widget build(BuildContext context) {
    // Skip picker when the partner only has one product access.
    final accessCount = [
      app.wUser.isPrimaryAccess,
      app.wUser.isSecondaryAccess,
      app.wUser.isPreIpoAccess,
    ].where((e) => e).length;

    if (accessCount == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (app.wUser.isPrimaryAccess) {
          await prefs.setValue(key: 'title', value: 'Private Equity');
          Get.offAllNamed('/wealth-manager/${WTabBarEnum.primary.slug}');
        } else if (app.wUser.isSecondaryAccess) {
          await prefs.setValue(key: 'title', value: 'LP Secondary');
          Get.offAllNamed('/wealth-manager/${WTabBarEnum.secondary.slug}');
        } else if (app.wUser.isPreIpoAccess) {
          await prefs.setValue(key: 'title', value: 'Unlisted Shares');
          Get.offAllNamed('/wealth-manager/${WTabBarEnum.preIPO.slug}');
        }
      });
      return const Scaffold(body: Loader());
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.newLogo,
            height: 40,
          ),
          const SizedBox(height: 10),
          Text(
            "Select your Journey",
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 37),
          Obx(() {
            final accents = context.sectionAccents;
            return Visibility(
              visible: app.wUser.isPrimaryAccess,
              child: CardWidget(
                color: accents.privateEquity,
                title: 'Private Equity',
                subTitle:
                    'Invest directly in high potential early-stage start-ups',
                onPressed: () async {
                  await prefs.setValue(key: 'title', value: 'Private Equity');
                  await AppTheme.setTheme(index: 0);
                  Get.offAllNamed(
                    '/wealth-manager/${WTabBarEnum.primary.slug}',
                  );
                },
              ),
            );
          }),
          Obx(() {
            final accents = context.sectionAccents;
            return Visibility(
              visible: app.wUser.isSecondaryAccess,
              child: CardWidget(
                color: accents.lpSecondary,
                title: 'LP Secondary',
                subTitle:
                    'Buy/Sell to your interests to enhance liquidity in your portfolios or to take advantage of emerging opportunities',
                onPressed: () async {
                  await AppTheme.setTheme(index: 1);
                  await prefs.setValue(key: 'title', value: 'LP Secondary');
                  Get.offAllNamed(
                    '/wealth-manager/${WTabBarEnum.secondary.slug}',
                  );
                },
              ),
            );
          }),
          Obx(() {
            final accents = context.sectionAccents;
            return Visibility(
              visible: app.wUser.isPreIpoAccess,
              child: CardWidget(
                color: accents.unlistedShares,
                title: 'Unlisted Shares',
                subTitle:
                    'Grab unique opportunity to invest in private companies before they transition to the public market',
                onPressed: () async {
                  await prefs.setValue(key: 'title', value: 'Unlisted Shares');
                  await AppTheme.setTheme(index: 2);
                  Get.offAllNamed(
                    '/wealth-manager/${WTabBarEnum.preIPO.slug}',
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
class CardWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color color;
  final void Function()? onPressed;

  const CardWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppFadeIn(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Clickable(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(20),
                child: CustomCardWidget(
                  radius: 20,
                  width: context.width,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: RadialGradient(
                        center: const Alignment(0.0, -2.0),
                        radius: 1.8,
                        colors: context.isDarkMode
                            ? [
                                color,
                                Colors.transparent,
                              ]
                            : [
                                color,
                                Colors.white10,
                              ],
                        stops: const [0.1, 0.8],
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 26),
                        Text(
                          title,
                          style: context.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subTitle,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 14),
                        Semantics(
                          button: true,
                          label: 'Enter $title',
                          child: TextButton.icon(
                            iconAlignment: IconAlignment.end,
                            style: TextButton.styleFrom(
                                foregroundColor: context.iconColor),
                            onPressed: onPressed,
                            label: Text(
                              "Enter",
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            icon: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 4,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
