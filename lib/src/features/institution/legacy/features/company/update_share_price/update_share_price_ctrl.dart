import 'package:private_deals/src/features/institution/data/api/deal_api.dart';
import 'package:private_deals/src/features/institution/data/deal_payloads.dart';
import 'package:private_deals/src/features/institution/support/plugins/toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/api/company_api.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/data/models/company/lite_company_model.dart';
import 'package:private_deals/src/shared/app_exports.dart' show app;
import 'package:private_deals/src/shared/models/settlement_option.dart';

class SharePriceDraft {
  SharePriceDraft(this.company, {int? settlementDays})
    : settlementDays = RxnInt(settlementDays);

  final LiteCompanyModel company;

  final price = TextEditingController();
  final minQty = TextEditingController();
  final totalQty = TextEditingController();
  final RxnInt settlementDays;

  final errors = <String, String>{}.obs;

  List<TextEditingController> get inputs => [price, minQty, totalQty];

  bool get hasAnyInput => inputs.any((input) => input.text.trim().isNotEmpty);

  bool get shouldSubmit =>
      price.text.trim().isNotEmpty && num.tryParse(price.text.trim()) != 0;

  void clear() {
    for (final input in inputs) {
      input.clear();
    }
    settlementDays.value = null;
    errors.clear();
  }

  void dispose() {
    for (final input in inputs) {
      input.dispose();
    }
  }
}

class UpdateSharePriceCtrl extends GetxController {
  final sellRows = <SharePriceDraft>[].obs;
  final buyRows = <SharePriceDraft>[].obs;
  final dealType = 'sell'.obs;
  final commonSettlementDays = RxnInt();
  RxList<SharePriceDraft> get rows =>
      dealType.value == 'sell' ? sellRows : buyRows;
  String get priceLabel => dealType.value == 'buy' ? 'Buy price' : 'Sell price';
  bool get isSell => dealType.value == 'sell';
  List<SettlementOption> get settlementOptions => app.config.settlementDays;

  void selectType(String type) {
    if (saving.value || type == dealType.value) return;
    dealType.value = type;
    feedback.value = '';
    clearSearch();
  }

  final query = ''.obs;
  final loading = true.obs;
  final saving = false.obs;
  final loadError = ''.obs;
  final feedback = ''.obs;
  final feedbackIsError = false.obs;

  final revision = 0.obs;
  final pinnedCompanyId = Rxn<int>();

  final searchController = TextEditingController();
  final scrollController = ScrollController();
  final horizontalScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchCompanies();
  }

  List<SharePriceDraft> get visibleRows {
    final search = query.value.trim().toLowerCase();
    final pinned = pinnedCompanyId.value;

    final result = rows.where((row) {
      final company = row.company;

      return '${company.brandName} ${company.companyName}'
          .toLowerCase()
          .contains(search);
    }).toList();

    if (pinned != null) {
      final index = result.indexWhere((row) => row.company.id == pinned);

      if (index > 0) {
        final row = result.removeAt(index);
        result.insert(0, row);
      }
    }

    return result;
  }

  int get pendingCount {
    revision.value;
    return rows.where((row) => row.shouldSubmit).length;
  }

  bool get hasAnyInput {
    revision.value;
    return rows.any((row) => row.hasAnyInput);
  }

  Future<void> fetchCompanies() async {
    loading.value = true;
    loadError.value = '';

    try {
      final response = await CompanyApi.getCompanyListLite(
        type: CompanyType.unlisted,
      );
      if (isClosed) return;

      if (response.isSuccess && response.r != null) {
        final unique = {for (final company in response.r!) company.id: company};

        for (final collection in [sellRows, buyRows]) {
          final existing = {for (final row in collection) row.company.id: row};
          collection.assignAll(
            unique.values.map((company) {
              final previous = existing.remove(company.id);
              if (previous != null) return previous;
              final row = SharePriceDraft(
                company,
                settlementDays: collection == sellRows
                    ? commonSettlementDays.value
                    : null,
              );
              for (final input in row.inputs) {
                input.addListener(_onDraftChanged);
              }
              return row;
            }),
          );
          for (final removed in existing.values) {
            removed.dispose();
          }
        }
      } else {
        loadError.value = response.m.isEmpty
            ? 'Unable to load companies. Please retry.'
            : response.m;
      }
    } catch (_) {
      if (!isClosed) {
        loadError.value = 'Unable to load companies. Please retry.';
      }
    } finally {
      if (!isClosed) loading.value = false;
    }
  }

  void _onDraftChanged() {
    revision.value++;
  }

  void updateSearch(String value) {
    query.value = value;
    pinnedCompanyId.value = null;

    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  void clearSearch() {
    searchController.clear();
    updateSearch('');
  }

  void fieldChanged(SharePriceDraft row) {
    row.errors.clear();
    feedback.value = '';
  }

  /// Applies the common cycle to rows still on the previous common value.
  void setCommonSettlement(int? value) {
    final previous = commonSettlementDays.value;
    commonSettlementDays.value = value;
    for (final row in sellRows) {
      if (row.settlementDays.value == previous) {
        row.settlementDays.value = value;
      }
    }
    revision.value++;
    feedback.value = '';
  }

  void setRowSettlement(SharePriceDraft row, int? value) {
    row.settlementDays.value = value;
    row.errors.remove('settlement_days');
    revision.value++;
    feedback.value = '';
  }

  bool validateRow(SharePriceDraft row) {
    row.errors.clear();

    final sell = row.price.text.trim();
    final min = row.minQty.text.trim();
    final total = row.totalQty.text.trim();

    // Bulk API skips rows with no price or a zero price.
    if (sell.isEmpty || num.tryParse(sell) == 0) return true;

    if (sell.isEmpty) {
      row.errors['price'] = 'Enter $priceLabel';
    } else {
      final number = num.tryParse(sell);
      if (number == null || !number.isFinite || number < 0) {
        row.errors['price'] = 'Enter a number of 0 or more';
      }
    }

    final minimum = int.tryParse(min);

    if (min.isEmpty) {
      row.errors['min_qty'] = 'Enter minimum quantity';
    } else if (minimum == null || minimum < 1) {
      row.errors['min_qty'] = 'Enter a whole number of 1 or more';
    }

    if (total.isNotEmpty) {
      final quantity = int.tryParse(total);

      if (quantity == null || quantity < 1) {
        row.errors['total_qty'] = 'Enter a whole number of 1 or more';
      } else if (minimum != null && quantity < minimum) {
        row.errors['total_qty'] = 'Must be at least minimum quantity';
      }
    }

    if (isSell) {
      final cycle = row.settlementDays.value;
      final allowed = settlementOptions.map((option) => option.value).toSet();
      if (cycle == null || !allowed.contains(cycle)) {
        row.errors['settlement_days'] = 'Select a settlement cycle';
      }
    }

    return row.errors.isEmpty;
  }

  void _showInvalidRow(SharePriceDraft row) {
    // Reveal errors even when the company was hidden by search.
    searchController.clear();
    query.value = '';
    pinnedCompanyId.value = row.company.id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed && scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> save() async {
    if (saving.value || loading.value) return;

    feedback.value = '';

    SharePriceDraft? firstInvalid;
    final prices = <Map<String, dynamic>>[];

    for (final row in rows) {
      final valid = validateRow(row);

      if (!valid) {
        firstInvalid ??= row;
        continue;
      }

      if (row.price.text.trim().isEmpty ||
          num.tryParse(row.price.text.trim()) == 0)
        continue;

      prices.add({
        'company_id': row.company.id,
        '${dealType.value}_price': num.parse(row.price.text.trim()),
        'min_qty': int.parse(row.minQty.text.trim()),
        if (row.totalQty.text.trim().isNotEmpty)
          'total_qty': int.parse(row.totalQty.text.trim()),
        if (isSell) 'settlement_days': row.settlementDays.value,
      });
    }

    if (firstInvalid != null) {
      feedbackIsError.value = true;
      feedback.value = 'Please correct the highlighted company fields.';
      _showInvalidRow(firstInvalid);
      return;
    }

    if (prices.isEmpty) {
      feedbackIsError.value = true;
      feedback.value =
          'Enter $priceLabel and minimum quantity for at least one company.';
      return;
    }

    saving.value = true;

    try {
      final payload = DealPayloads.bulk(
        rows
            .map(
              (row) => BulkDealRow(
                companyId: row.company.id,
                type: dealType.value,
                price: row.price.text,
                minimum: row.minQty.text,
                total: row.totalQty.text,
                settlementDays: isSell ? row.settlementDays.value : null,
              ),
            )
            .toList(),
      );
      final res = await DealApi.bulkDeals(payload);
      if (isClosed) return;

      if (!res.isSuccess) {
        feedbackIsError.value = true;
        feedback.value = res.m.isEmpty
            ? 'Unable to save prices. Please retry.'
            : res.m;
        toast(feedback.value, MessageEnum.error);
        return;
      }

      for (final row in rows) {
        row.clear();
      }
      if (isSell) {
        commonSettlementDays.value = null;
      }

      clearSearch();
      feedbackIsError.value = false;
      feedback.value = 'Prices updated for ${prices.length} companies.';
      toast(feedback.value, MessageEnum.success);
    } on FormatException catch (error) {
      if (!isClosed) {
        feedbackIsError.value = true;
        feedback.value = error.message;
      }
    } catch (_) {
      if (!isClosed) {
        feedbackIsError.value = true;
        feedback.value =
            'Unable to save prices. Your entries have been preserved.';
      }
    } finally {
      if (!isClosed) saving.value = false;
    }
  }

  @override
  void onClose() {
    for (final row in [...sellRows, ...buyRows]) {
      row.dispose();
    }

    searchController.dispose();
    scrollController.dispose();
    horizontalScrollController.dispose();
    super.onClose();
  }
}
