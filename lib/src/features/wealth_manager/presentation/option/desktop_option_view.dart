import 'package:private_deals/src/shared/app_exports.dart';

class DesktopOptionView extends StatelessWidget {
  const DesktopOptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 73),
          Image.asset(
            AppAssets.newLogo,
            height: 90,
          ),
          const SizedBox(height: 10),
          Text(
            "Unlock your Journey",
            style: context.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 80),
          Center(
            child: Obx(() {
              final accents = context.sectionAccents;
              final cards = <Widget>[
                if (app.wUser.isPrimaryAccess)
                  CardWidget(
                    color: accents.privateEquity,
                    title: 'Private Equity',
                    subTitle:
                        'Invest directly in high potential early-stage start-ups',
                    onPressed: () async {
                      await prefs.setValue(
                          key: 'title', value: 'Private Equity');
                      await AppTheme.setTheme(index: 0);
                      Get.offAllNamed('/wealth-manager/${WTabBarEnum.primary.slug}');
                    },
                  ),
                if (app.wUser.isSecondaryAccess)
                  CardWidget(
                    color: accents.lpSecondary,
                    title: 'LP Secondary',
                    subTitle:
                        'Buy/Sell to your interests to enhance liquidity in your portfolios or to take advantage of emerging opportunities',
                    onPressed: () async {
                      await AppTheme.setTheme(index: 1);
                      await prefs.setValue(key: 'title', value: 'LP Secondary');
                      Get.offAllNamed('/wealth-manager/${WTabBarEnum.secondary.slug}');
                    },
                  ),
                if (app.wUser.isPreIpoAccess)
                  CardWidget(
                    color: accents.unlistedShares,
                    title: 'Unlisted Shares',
                    subTitle:
                        'Grab unique opportunity to invest in private companies before they transition to the public market',
                    onPressed: () async {
                      await prefs.setValue(
                          key: 'title', value: 'Unlisted Shares');
                      await AppTheme.setTheme(index: 2);
                      Get.offAllNamed('/wealth-manager/${WTabBarEnum.preIPO.slug}');
                    },
                  ),
              ];

              if (cards.isEmpty) return const SizedBox.shrink();

              return IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 32,
                  children: cards,
                ),
              );
            }),
          ),
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
      child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 375.62, minWidth: 100),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomCardWidget(
            margin: const EdgeInsets.only(top: 4),
            radius: 20,
            child: Clickable(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -2.3),
                    radius: 1.5,
                    colors: [
                      color, // Light glow
                      Colors.transparent, // Fades to transparent
                    ],
                    stops: const [0.3, 0.7],
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 57),
                    Text(
                      title,
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 23),
                    Text(
                      subTitle,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 40),
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
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 9.48,
            width: 80,
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
