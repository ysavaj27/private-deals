import 'package:private_deals/src/shared/app_exports.dart';

class SectorStartupDialog extends StatelessWidget {
  final List<WStartup>? startups;

  const SectorStartupDialog(this.startups, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      radius: 20,
      height: 400,
      width: 500,
      color: context.theme.scaffoldBackgroundColor,
      padding: context.isPhone
          ? const EdgeInsets.symmetric(horizontal: 10)
          : const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: context.isPhone
                ? const EdgeInsets.symmetric(horizontal: 10)
                : const EdgeInsets.symmetric(horizontal: 32),
            child: const Text(
              "Sector Bifurcation startup wise",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: context.isPhone
                ? const EdgeInsets.symmetric(horizontal: 10)
                : const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Investor",
                    style: TextStyle(
                      // fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.theme.disabledColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Startup",
                    style: TextStyle(
                      // fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.theme.disabledColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Total Amount",
                      style: TextStyle(
                        // fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.theme.disabledColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          if (startups != null && startups!.isNotEmpty) ...[
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: context.isPhone
                    ? const EdgeInsets.symmetric(horizontal: 10)
                    : const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: startups!.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                e.investorName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: context.theme.disabledColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                e.startupName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: context.theme.disabledColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "${e.currentValue.toCurrency}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: context.theme.disabledColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()),
              ),
            ),
          ] else ...[
            const InlineEmptyView(),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Padding(
            padding: context.isPhone
                ? const EdgeInsets.symmetric(horizontal: 10)
                : const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Amount",
                  style: TextStyle(
                    // fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.theme.disabledColor,
                  ),
                ),
                Text(
                  "${(startups
                      ?.map((e) => e.investmentAmount) // Replace null amounts with 0
                      .reduce((value, element) => value + element))?.toCurrency}",
                  style: TextStyle(
                    // fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.theme.disabledColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
