import 'package:flutter/material.dart';
import 'package:private_deals/src/core/config/demo_environment.dart';
import 'package:private_deals/src/shared/plugins/logger.dart';
import 'package:private_deals/src/shared/theme/app_tokens.dart';
import 'package:url_launcher/url_launcher.dart';

/// Visual + copy config for a non-production environment notice.
class EnvironmentBannerStyle {
  const EnvironmentBannerStyle({
    required this.label,
    required this.compactLabel,
    required this.message,
    required this.actionLabel,
    required this.liveAppUrl,
    required this.background,
    required this.gradientColors,
    required this.borderColor,
    required this.messageColor,
    required this.actionColor,
  });

  final String label;
  final String compactLabel;
  final String message;
  final String actionLabel;
  final String liveAppUrl;
  final Color background;
  final List<Color> gradientColors;
  final Color borderColor;
  final Color messageColor;
  final Color actionColor;
}

/// Demo host notice — violet palette, distinct from partner themes.
const EnvironmentBannerStyle demoEnvironmentBannerStyle =
    EnvironmentBannerStyle(
  label: 'Demo app',
  compactLabel: 'Demo',
  message:
      'This is a demo app for testing. Use the live app to make investments.',
  actionLabel: 'Go to live app',
  liveAppUrl: 'https://partner.privatedeals.in/',
  background: Color(0xFF6D28D9),
  gradientColors: [Color(0xFF6D28D9), Color(0xFF7C3AED), Color(0xFF9333EA)],
  borderColor: Color(0xFFC4B5FD),
  messageColor: Color(0xFFF3E8FF),
  actionColor: Colors.white,
);

/// Staging host notice — amber palette so it is not mistaken for demo or live.
const EnvironmentBannerStyle stagingEnvironmentBannerStyle =
    EnvironmentBannerStyle(
  label: 'Staging app',
  compactLabel: 'Staging',
  message:
      'This is the staging app for QA. Do not use it for live investments.',
  actionLabel: 'Go to live app',
  liveAppUrl: 'https://partner.privatedeals.in/',
  background: Color(0xFFB45309),
  gradientColors: [Color(0xFFB45309), Color(0xFFD97706), Color(0xFFF59E0B)],
  borderColor: Color(0xFFFDE68A),
  messageColor: Color(0xFFFFFBEB),
  actionColor: Colors.white,
);

/// Persistent, theme-independent notice shown above every route on the demo host.
class DemoEnvironmentBanner extends StatelessWidget {
  const DemoEnvironmentBanner({super.key, this.onOpenLive});

  static String get label => demoEnvironmentBannerStyle.label;
  static String get message => demoEnvironmentBannerStyle.message;
  static String get actionLabel => demoEnvironmentBannerStyle.actionLabel;
  static String get liveAppUrl => demoEnvironmentBannerStyle.liveAppUrl;
  static Color get background => demoEnvironmentBannerStyle.background;
  static Color get messageColor => demoEnvironmentBannerStyle.messageColor;
  static Color get actionColor => demoEnvironmentBannerStyle.actionColor;

  /// Replaces the live-site launch in tests.
  final void Function(String url)? onOpenLive;

  @override
  Widget build(BuildContext context) {
    return EnvironmentBanner(
      style: demoEnvironmentBannerStyle,
      onOpenLive: onOpenLive,
    );
  }
}

/// Persistent, theme-independent notice shown above every route on staging.
class StagingEnvironmentBanner extends StatelessWidget {
  const StagingEnvironmentBanner({super.key, this.onOpenLive});

  static String get label => stagingEnvironmentBannerStyle.label;
  static String get message => stagingEnvironmentBannerStyle.message;
  static String get actionLabel => stagingEnvironmentBannerStyle.actionLabel;
  static String get liveAppUrl => stagingEnvironmentBannerStyle.liveAppUrl;
  static Color get background => stagingEnvironmentBannerStyle.background;
  static Color get messageColor => stagingEnvironmentBannerStyle.messageColor;
  static Color get actionColor => stagingEnvironmentBannerStyle.actionColor;

  /// Replaces the live-site launch in tests.
  final void Function(String url)? onOpenLive;

  @override
  Widget build(BuildContext context) {
    return EnvironmentBanner(
      style: stagingEnvironmentBannerStyle,
      onOpenLive: onOpenLive,
    );
  }
}

/// Shared layout for demo / staging environment notices.
class EnvironmentBanner extends StatelessWidget {
  const EnvironmentBanner({
    super.key,
    required this.style,
    this.onOpenLive,
  });

  final EnvironmentBannerStyle style;
  final void Function(String url)? onOpenLive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: style.background,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: style.gradientColors),
          border: Border(bottom: BorderSide(color: style.borderColor)),
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.lg,
                  vertical: 5,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final scaledWidth =
                        constraints.maxWidth /
                        (MediaQuery.textScalerOf(context).scale(14) / 14);
                    final compact = scaledWidth < 1100;
                    final iconOnly = scaledWidth < 320;
                    final notice = scaledWidth < 200
                        ? style.compactLabel
                        : (compact ? style.label : style.message);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              notice,
                              maxLines: 1,
                              softWrap: false,
                              semanticsLabel: style.message,
                              style: TextStyle(
                                color: style.messageColor,
                                fontSize: 14,
                                height: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpace.md),
                        _LiveAppLink(
                          style: style,
                          iconOnly: iconOnly,
                          onPressed: () => _openLiveApp(style, onOpenLive),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Places [child] under a demo or staging banner when [baseUrl] matches.
///
/// Live builds return [child] unchanged. The banner keeps the top safe-area
/// inset and clears it for the page so screens do not pad twice.
class DemoEnvironmentFrame extends StatelessWidget {
  const DemoEnvironmentFrame({
    super.key,
    required this.baseUrl,
    required this.child,
    this.onOpenLive,
  });

  final String baseUrl;
  final Widget child;
  final void Function(String url)? onOpenLive;

  @override
  Widget build(BuildContext context) {
    final Widget? banner;
    if (isDemoEnvironment(baseUrl)) {
      banner = DemoEnvironmentBanner(onOpenLive: onOpenLive);
    } else if (isStagingEnvironment(baseUrl)) {
      banner = StagingEnvironmentBanner(onOpenLive: onOpenLive);
    } else {
      return child;
    }

    return Column(
      children: [
        banner,
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          ),
        ),
      ],
    );
  }
}

class _LiveAppLink extends StatelessWidget {
  const _LiveAppLink({
    required this.style,
    required this.onPressed,
    required this.iconOnly,
  });

  final EnvironmentBannerStyle style;
  final bool iconOnly;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (iconOnly) {
      return Semantics(
        label: style.actionLabel,
        child: IconButton(
          onPressed: onPressed,
          color: style.actionColor,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          icon: const Icon(Icons.north_east_rounded, size: 18),
        ),
      );
    }

    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: style.actionColor,
        backgroundColor: Colors.transparent,
        overlayColor: Colors.white,
        minimumSize: const Size(48, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.sm,
          vertical: AppSpace.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        textStyle: Theme.of(context).textTheme.labelLarge
            ?.copyWith(fontSize: 13, height: 1.2, fontWeight: FontWeight.w700),
      ),
      iconAlignment: IconAlignment.end,
      icon: const Icon(Icons.north_east_rounded, size: 18),
      label: Text(style.actionLabel),
    );
  }
}

void _openLiveApp(
  EnvironmentBannerStyle style,
  void Function(String url)? onOpenLive,
) {
  final url = style.liveAppUrl;
  if (onOpenLive != null) {
    onOpenLive(url);
    return;
  }
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication).catchError((
    Object error,
  ) {
    logger.e('Unable to open live app: $error');
    return false;
  });
}
