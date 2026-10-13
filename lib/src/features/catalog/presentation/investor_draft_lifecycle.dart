import 'package:private_deals/src/core/permissions/partner_role.dart';
import 'package:private_deals/src/shared/app_exports.dart';

/// Owns the input controllers created for a screen's selected investors.
mixin InvestorDraftLifecycle on GetxController {
  final RxList<SelectInvestorModel> investorList = <SelectInvestorModel>[].obs;
  final Set<SelectInvestorModel> _retiredDrafts = {};

  /// An Institution always buys for its own self investor, never for clients.
  bool get buysAsSelf => app.role == PartnerRole.institution;

  bool hasSelfInvestor() {
    final id = app.wUser.selfInvestorId;
    if (id != null && id > 0) return true;
    toast(
      'Your self investor is not set up yet. Contact support to buy deals.',
      MessageEnum.alert,
    );
    return false;
  }

  /// Replaces the drafts with the Institution's self investor. Returns false
  /// (after telling the user) when the account has no self investor yet.
  bool seedSelfInvestor(double price) {
    if (!hasSelfInvestor()) return false;
    final id = app.wUser.selfInvestorId!;
    if (investorList.length == 1 &&
        investorList.first.investorId == id &&
        investorList.first.price() == price) {
      return true;
    }
    clearInvestors();
    investorList.add(
      SelectInvestorModel(
        investorId: id,
        investorName: 'My account',
        isSelf: true,
        isMarket: true,
        price: price,
        priceCTRL: TextEditingController(text: price.toString()),
        quantityCTRL: TextEditingController(),
      ),
    );
    return true;
  }

  void removeInvestor(SelectInvestorModel investor) {
    if (investorList.remove(investor)) _retire([investor]);
  }

  void clearInvestors() {
    final removed = investorList.toList();
    investorList.clear();
    _retire(removed);
  }

  void _retire(List<SelectInvestorModel> drafts) {
    if (drafts.isEmpty) return;
    _retiredDrafts.addAll(drafts);
    // Reactive rows unmount on the next frame. Their text fields must be able
    // to detach from the old input controllers before those are disposed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final draft in drafts) {
        if (_retiredDrafts.remove(draft)) _disposeDraft(draft);
      }
    });
  }

  void _disposeDraft(SelectInvestorModel draft) {
    draft.quantityCTRL?.dispose();
    draft.priceCTRL?.dispose();
    draft.quantityCTRL = null;
    draft.priceCTRL = null;
  }

  @override
  void onClose() {
    for (final draft in {...investorList, ..._retiredDrafts}) {
      _disposeDraft(draft);
    }
    _retiredDrafts.clear();
    super.onClose();
  }
}
