import 'package:private_deals/src/shared/app_exports.dart';

class ShowMoreDialog extends StatelessWidget {
  final InvestorModel user;

  ShowMoreDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30),
      color: context.theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomCardWidget(
            margin: EdgeInsets.zero,
            radius: 8,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            padding: EdgeInsets.fromLTRB(14, 9, 14, 9),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "Startup Name",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: context.theme.primaryColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Amount Invested",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: context.theme.primaryColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Commission Earned",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: context.theme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomCardWidget(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
            child: Column(
              children: [
                ...List.generate(user.startupList.length, (index) {
                  var model = user.startupList[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 9,
                      horizontal: 5,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              model.brandName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.theme.disabledColor,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "${model.amountInvested.toFormattedPrice}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "${model.commissionEarned.toFormattedPrice}",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
