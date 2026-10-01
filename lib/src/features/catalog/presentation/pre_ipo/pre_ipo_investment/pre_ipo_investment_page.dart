import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/desktop_pre_ipo_investment_view.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/phone_pre_ipo_investment_view.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_investment_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_offer.dart';

class PreIPOInvestmentPage extends StatelessWidget {
  const PreIPOInvestmentPage({super.key});
  @override
  Widget build(BuildContext context) {
    // Quotes are transient. A refreshed checkout must reselect an available offer.
    if (Get.arguments is! PreIPOInvestmentSelection &&
        Get.arguments is! CompanyModel) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select an offer')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Please choose an available offer again to continue.',
                  textAlign: TextAlign.center,
                ),
              ),
              FilledButton(
                onPressed: () => Get.offNamed(
                  Uri.parse(
                    Get.currentRoute,
                  ).path.replaceFirst(RegExp(r'/investment$'), ''),
                ),
                child: const Text('View company offers'),
              ),
            ],
          ),
        ),
      );
    }
    Get.put(PreIPOInvestmentPageCtrl());
    return context.isPhone
        ? PhonePreIPOInvestmentView()
        : DesktopPreIPOInvestmentView();
  }
}
