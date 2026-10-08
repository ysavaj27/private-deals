import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';

/// Owns the input controllers created for a screen's selected investors.
mixin InvestorDraftLifecycle on GetxController {
  final RxList<SelectInvestorModel> investorList = <SelectInvestorModel>[].obs;
  final Set<SelectInvestorModel> _retiredDrafts = {};

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
