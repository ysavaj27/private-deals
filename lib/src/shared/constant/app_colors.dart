import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  /// Logo navy action — keep in sync with [BrandColors.navyAction].
  static const Color lightPrimary = Color(0xFF2B5996);
  static Color get darkPrimary => const Color(0xFF8BAAD4);
  static const Color primaryStartUp = lightPrimary;
  static const Color secondaryStartUp = Color(0xFFC19767);
  static const Color privateEquity = lightPrimary;

  /// Soft section markers — prefer [SectionAccents] from theme when in a widget.
  static const Color sectionPrivateEquity = Color(0xFFBDB999);
  static const Color sectionLpSecondary = Color(0xFF57B1C4);
  static const Color sectionUnlistedShares = Color(0xFF9D95CA);

  static const Color blue = Color(0xff2A78CC);
  static const Color lightBlue = Color(0xff8FBFF2);
  /// Light scaffold tint — aligns with LightTheme surfaceContainerLow.
  static const Color offWhite = Color(0xFFE4E9F1);

  static Color green(BuildContext c) => const Color(0xff0bbc92);
  static const Color grey = Color(0xff656565);

  /// Shared CTA for Pre-IPO / unlisted investment flow buttons.
  /// Uses theme primary so light/dark stay consistent in one place.
  static Color preIpoButton(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color borderColor(BuildContext context) =>
      context.theme.colorScheme.outlineVariant;

  static Color logoBgColor(BuildContext context) =>
      context.theme.colorScheme.surfaceContainerLow;

  static List<Color> bgGradient(BuildContext context) =>
      context.isDarkMode ? darkGradient : lightGradient;

  static List<Color> graphGradient(BuildContext context) {
    if (context.isDarkMode) {
      return const [
        Color(0xFF0D1117),
        Color(0xFF17283E),
      ];
    }
    return const [
      Color(0xFFD5E2F2),
      Color(0xFF2B5996),
    ];
  }

  /// Segment / series palette tuned for contrast on light vs dark surfaces.
  static List<Color> pieChartPalette(BuildContext context) {
    if (context.isDarkMode) {
      return const [
        Color(0xFF8BAAD4),
        Color(0xFFC19767),
        Color(0xFF34D399),
        Color(0xFFFBBF24),
        Color(0xFFF472B6),
        Color(0xFFA78BFA),
        Color(0xFFFB923C),
        Color(0xFF67E8F9),
        Color(0xFF94A3B8),
        Color(0xFFC4B5FD),
        Color(0xFF6EE7B7),
        Color(0xFFFCD34D),
      ];
    }
    return const [
      Color(0xFF2B5996),
      Color(0xFFC19767),
      Color(0xFF059669),
      Color(0xFFD97706),
      Color(0xFFDB2777),
      Color(0xFF7C3AED),
      Color(0xFFEA580C),
      Color(0xFF0E7490),
      Color(0xFF64748B),
      Color(0xFF6D28D9),
      Color(0xFF0F766E),
      Color(0xFFB45309),
    ];
  }

  static Color chartStrokeColor(BuildContext context) =>
      context.theme.colorScheme.surface;

  static Color chartTooltipBackground(BuildContext context) =>
      context.theme.colorScheme.inverseSurface;

  static Color chartTooltipText(BuildContext context) =>
      context.theme.colorScheme.onInverseSurface;

  static Color chartAxisLabelColor(BuildContext context) =>
      context.theme.colorScheme.onSurfaceVariant;

  /// [shadeSet] is a 4-stop list from light → dark (see [darKList]).
  /// Dark UI uses brighter stops; light UI uses deeper stops for contrast.
  static Color columnBarColor({
    required List<Color> shadeSet,
    required bool isDark,
    required bool isForegroundSeries,
  }) {
    if (shadeSet.length < 4) {
      return isDark ? darkPrimary : lightPrimary;
    }
    if (isDark) {
      return isForegroundSeries ? shadeSet[0] : shadeSet[2];
    }
    return isForegroundSeries ? shadeSet[2] : shadeSet[3];
  }

  static List<Color> get darkGradient => const [
        Color(0xFF0D1117),
        Color(0xFF010409),
      ];

  static List<Color> get lightGradient => const [
        Color(0xFFD5E2F2),
        Color(0xFFF7F9FC),
      ];

  List<Color> lineGraphColors = [
    Color(0xffEB9601),
    Color(0xffA5014F),
    Color(0xff003767),
    Color(0xff008F80),

    Color.fromRGBO(248, 184, 131, 1),
    Color.fromRGBO(229, 101, 144, 1),
    Color.fromRGBO(53, 124, 210, 1),
    Color.fromRGBO(0, 189, 174, 1),

    // ===== 15 new added below =====
    Color(0xff6A4C93),
    Color(0xff1982C4),
    Color(0xff8AC926),
    Color(0xffFFCA3A),
    Color(0xffFF595E),
    Color(0xff52489C),
    Color(0xff4059AD),
    Color(0xffF4B942),
    Color(0xffE36414),
    Color(0xff0F4C5C),
    Color(0xff9A031E),
    Color(0xffCB997E),
    Color(0xff5F0F40),
    Color(0xff0B6E4F),
    Color(0xffB56576),
  ];

  static List<Color> circularGraphColors = [
    Color(0xff2F7CB8),
    Color(0xff418CC6),
    Color(0xff529AD1),
    Color(0xff65AADE),
    Color(0xff80BBE9),
    Color(0xff9FC9E9),
    Color(0xffCDD9E3),
    Color(0xff1F5C8B),
    Color(0xff174766),
    Color(0xff103349),
    Color(0xffA9C9E0),
    Color(0xffBDD6E8),
    Color(0xffE3ECF3),
    Color(0xff3A6E9E),
    Color(0xff5A9AC9),
    Color(0xff7BB0D6),
    Color(0xff96C2E0),
    Color(0xffB1D3EA),
    Color(0xffCCE3F3),
    Color(0xff28486B),
    Color(0xff1A324E),
    Color(0xff0D1E30),
  ];

  static List<List<Color>> darKList = [
    [
      const Color(0xffB4CFF6),
      const Color(0xffAACCFF),
      const Color(0xff4E79F8),
      const Color(0xff3366FF),
    ],
    [
      const Color(0xffD7D397),
      const Color(0xffBDB76B),
      const Color(0xffACA63F),
      const Color(0xff807A17),
    ],
    [
      const Color(0xffE3E0C2),
      const Color(0xffFFFACD),
      const Color(0xffFFBA3C),
      const Color(0xffFFA500),
    ],
    [
      const Color(0xffECE0EB),
      const Color(0xffE0C2DE),
      const Color(0xff7F569E),
      const Color(0xff8C5EAF),
    ],
    [
      const Color(0xffEEBC8B),
      const Color(0xffFFCC99),
      const Color(0xffEF7D1C),
      const Color(0xffFF7F0E),
    ],
    [
      const Color(0xffE45459),
      const Color(0xff9C3840),
      const Color(0xffFF0000),
      const Color(0xff770002),
    ],
    [
      const Color(0xffB4CFF6),
      const Color(0xffAACCFF),
      const Color(0xff4E79F8),
      const Color(0xff3366FF),
    ],
    [
      const Color(0xffD7D397),
      const Color(0xffBDB76B),
      const Color(0xffACA63F),
      const Color(0xff807A17),
    ],
    [
      const Color(0xffE3E0C2),
      const Color(0xffFFFACD),
      const Color(0xffFFBA3C),
      const Color(0xffFFA500),
    ],
    [
      const Color(0xffECE0EB),
      const Color(0xffE0C2DE),
      const Color(0xff7F569E),
      const Color(0xff8C5EAF),
    ],
    [
      const Color(0xffEEBC8B),
      const Color(0xffFFCC99),
      const Color(0xffEF7D1C),
      const Color(0xffFF7F0E),
    ],
    [
      const Color(0xffE45459),
      const Color(0xff9C3840),
      const Color(0xffFF0000),
      const Color(0xff770002),
    ],
    // ===== 15 new added below =====
    [
      const Color(0xffB9F6E4),
      const Color(0xff8DE6C9),
      const Color(0xff1FA98A),
      const Color(0xff0C7A63),
    ],
    [
      const Color(0xffF6C6D9),
      const Color(0xffF199B8),
      const Color(0xffD94A78),
      const Color(0xffA8214F),
    ],
    [
      const Color(0xffCDEAB4),
      const Color(0xffA8DC7F),
      const Color(0xff6FAE3A),
      const Color(0xff4D7C22),
    ],
    [
      const Color(0xffF7D6B0),
      const Color(0xffF0B67A),
      const Color(0xffD97F1F),
      const Color(0xffA85E10),
    ],
    [
      const Color(0xffC9E4F6),
      const Color(0xff9BCFF0),
      const Color(0xff3B93D6),
      const Color(0xff1F6BA8),
    ],
    [
      const Color(0xffE6C9F6),
      const Color(0xffD09BF0),
      const Color(0xff9B3BD6),
      const Color(0xff6E1FA8),
    ],
    [
      const Color(0xffF6E1C9),
      const Color(0xffF0CB9B),
      const Color(0xffD68B3B),
      const Color(0xffA8621F),
    ],
    [
      const Color(0xffC9F6E1),
      const Color(0xff9BF0CB),
      const Color(0xff3BD68B),
      const Color(0xff1FA862),
    ],
    [
      const Color(0xffF6C9C9),
      const Color(0xffF09B9B),
      const Color(0xffD63B3B),
      const Color(0xffA81F1F),
    ],
    [
      const Color(0xffD9D9F6),
      const Color(0xffB6B6F0),
      const Color(0xff5C5CD6),
      const Color(0xff3939A8),
    ],
    [
      const Color(0xffF6EFC9),
      const Color(0xffF0E29B),
      const Color(0xffD6B93B),
      const Color(0xffA88F1F),
    ],
    [
      const Color(0xffC9F6F6),
      const Color(0xff9BF0F0),
      const Color(0xff3BD6D6),
      const Color(0xff1FA8A8),
    ],
    [
      const Color(0xffF6C9EF),
      const Color(0xffF09BE2),
      const Color(0xffD63BB9),
      const Color(0xffA81F8F),
    ],
    [
      const Color(0xffE0E8D0),
      const Color(0xffC5D3A5),
      const Color(0xff8FA35A),
      const Color(0xff62753A),
    ],
    [
      const Color(0xffD0DDE8),
      const Color(0xffA5C0D3),
      const Color(0xff5A85A3),
      const Color(0xff3A5D75),
    ],
  ];
// // static const Color primary = contentColorCyan;
// static const Color menuBackground = Color(0xFF090912);
// static const Color itemsBackground = Color(0xFF1B2339);
// static const Color pageBackground = Color(0xFF282E45);
// static const Color mainTextColor1 = Colors.white;
// static const Color mainTextColor2 = Colors.white70;
// static const Color mainTextColor3 = Colors.white38;
// static const Color mainGridLineColor = Colors.white10;
// static const Color borderColor = Colors.white54;
// static const Color gridLinesColor = Color(0x11FFFFFF);
//
// static const Color contentColorBlack = Colors.black;
// static const Color contentColorWhite = Colors.white;
// static const Color contentColorBlue = Color(0xFF2196F3);
// static const Color contentColorYellow = Color(0xFFFFC300);
// static const Color contentColorOrange = Color(0xFFFF683B);
// static const Color contentColorGreen = Color(0xFF3BFF49);
// static const Color contentColorPurple = Color(0xFF6E1BFF);
// static const Color contentColorPink = Color(0xFFFF3AF2);
// static const Color contentColorRed = Color(0xFFE80054);
// static const Color contentColorCyan = Color(0xFF50E4FF);
// static const MaterialColor primaryM = MaterialColor(
//   500,
//   {
//     50: Color(0xFFF3E5F5),
//     100: Color(0xFFE1BEE7),
//     200: Color(0xFFCE93D8),
//     300: Color(0xFFBA68C8),
//     400: Color(0xFFAB47BC),
//     500: Color(0xFF8C3BE6),
//     600: Color(0xFF8E24AA),
//     700: Color(0xFF7B1FA2),
//     800: Color(0xFF6A1B9A),
//     900: Color(0xFF4A148C),
//   },
// );
}
