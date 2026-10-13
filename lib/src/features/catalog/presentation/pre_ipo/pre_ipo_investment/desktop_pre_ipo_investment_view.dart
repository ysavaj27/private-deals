import 'package:flutter/material.dart';

import 'phone_pre_ipo_investment_view.dart';

/// Keep the same checkout and investor drafts when a phone window is widened.
class DesktopPreIPOInvestmentView extends StatelessWidget {
  const DesktopPreIPOInvestmentView({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 840),
      child: PhonePreIPOInvestmentView(),
    ),
  );
}
