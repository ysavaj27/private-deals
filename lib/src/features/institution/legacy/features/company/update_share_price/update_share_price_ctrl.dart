import 'package:private_deals/src/features/institution/data/api/deal_api.dart';
import 'package:private_deals/src/features/institution/data/deal_payloads.dart';
import 'package:private_deals/src/features/institution/data/models/deal/deal_model.dart';
import 'package:private_deals/src/features/institution/support/plugins/toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:private_deals/src/features/institution/data/api/company_api.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/data/models/company/lite_company_model.dart';
import 'package:private_deals/src/shared/app_exports.dart' show app;
import 'package:private_deals/src/shared/models/settlement_option.dart';

/// Last saved non-hot deal for one company on the current buy or sell tab.
class PreviousSharePrice {
  const PreviousSharePrice({
    required this.companyId,
    required this.companyName,
    required this.basePrice,
    required this.minQty,
    this.totalQty,
    this.settlementDays,
    this.recordedAt,
  });

  final int companyId;
  final String companyName;
  final double basePrice;
  final int minQty;
  final int? totalQty;
  final int? settlementDays;
  final DateTime? recordedAt;

  String get priceText => _plainNumber(basePrice);
}

/// Wealth manager share price: the typed base plus the 1% institution fee,
/// rounded to paise the same way the server builds `share_price`.
double wealthManagerSharePrice(double basePrice) {
  final paise = (basePrice * 100).round();
  return (paise * 101).round() / 10000;
}

class PreviousPriceLookup {
  const PreviousPriceLookup({this.prices = const [], this.error = ''});

  final List<PreviousSharePrice> prices;
  final String error;

  bool get isSuccess => error.isEmpty;
}

final _inr = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

String _plainNumber(num value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  var text = value.toStringAsFixed(2);
  text = text.replaceFirst(RegExp(r'0+$'), '');
  if (text.endsWith('.')) text = text.substring(0, text.length - 1);
  return text;
}

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

  /// Only one per-row settlement editor is open at a time (avoids N dropdowns).
  final editingSettlementCompanyId = RxnInt();
  RxList<SharePriceDraft> get rows =>
      dealType.value == 'sell' ? sellRows : buyRows;
  String get priceLabel => dealType.value == 'buy' ? 'Buy price' : 'Sell price';
  bool get isSell => dealType.value == 'sell';
  List<SettlementOption> get settlementOptions => app.config.settlementDays;

  void selectType(String type) {
    if (saving.value || type == dealType.value) return;
    dealType.value = type;
    editingSettlementCompanyId.value = null;
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
  final listOrder = 0.obs;
  final pinnedCompanyId = Rxn<int>();
  final loadingPrevious = false.obs;

  /// Previous prices already filled, per buy/sell tab. Drives list order.
  final _loadedPrevious = <String, Map<int, PreviousSharePrice>>{
    'sell': {},
    'buy': {},
  };

  final searchController = TextEditingController();
  final scrollController = ScrollController();
  final horizontalScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchCompanies();
  }

  List<SharePriceDraft> get visibleRows {
    listOrder.value;
    final search = query.value.trim().toLowerCase();
    final pinned = pinnedCompanyId.value;
    final loaded = _loadedPrevious[dealType.value] ?? const {};

    final result = rows.where((row) {
      final company = row.company;

      return '${company.brandName} ${company.companyName}'
          .toLowerCase()
          .contains(search);
    }).toList();

    result.sort((a, b) => _compareRows(a, b, loaded));

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

  /// Minimum amount using the wealth manager price (base + 1%) × minimum qty.
  String? minTransactionLabel(SharePriceDraft row) {
    final price = double.tryParse(row.price.text.trim());
    final minimum = int.tryParse(row.minQty.text.trim());
    if (price == null || minimum == null || price <= 0 || minimum < 1) {
      return null;
    }
    final amount = wealthManagerSharePrice(price) * minimum;
    return 'Min transaction ${_inr.format(amount)}';
  }

  /// Loads the latest saved price for this tab and writes it into the fields.
  Future<void> fillPreviousPrices() async {
    if (loadingPrevious.value || saving.value || loading.value) return;
    loadingPrevious.value = true;
    feedback.value = '';
    try {
      final lookup = await lookupPreviousPrices();
      if (isClosed) return;
      if (!lookup.isSuccess) {
        feedbackIsError.value = true;
        feedback.value = lookup.error;
        toast(lookup.error, MessageEnum.error);
        return;
      }
      if (lookup.prices.isEmpty) {
        feedbackIsError.value = true;
        feedback.value = isSell
            ? 'No previous sell price was found.'
            : 'No previous buy price was found.';
        return;
      }
      applyPreviousPrices(lookup.prices);
      toast(feedback.value, MessageEnum.success);
    } finally {
      if (!isClosed) loadingPrevious.value = false;
    }
  }

  /// Loads this institution's latest non-hot deal per company for the open tab.
  Future<PreviousPriceLookup> lookupPreviousPrices() async {
    try {
      final deals = await _fetchUnlistedDeals();
      if (isClosed) return const PreviousPriceLookup();

      final latest = <int, PreviousSharePrice>{};
      for (final deal in deals) {
        if (deal.dealType.toLowerCase() != dealType.value) continue;
        final companyId = deal.company.id;
        if (companyId <= 0) continue;
        final price = _basePriceOf(deal);
        final minimum = deal.minimumQty.round();
        if (price == null || minimum < 1) continue;
        final total = deal.availableQuantity.round();
        final candidate = PreviousSharePrice(
          companyId: companyId,
          companyName: _companyLabel(deal.company),
          basePrice: price,
          minQty: minimum,
          totalQty: total >= 1 ? total : null,
          settlementDays: deal.settlementDays,
          recordedAt: deal.recordedAt,
        );
        final current = latest[companyId];
        if (current == null || _isNewer(candidate, current)) {
          latest[companyId] = candidate;
        }
      }

      final prices = <PreviousSharePrice>[];
      for (final row in rows) {
        final previous = latest[row.company.id];
        if (previous == null) continue;
        prices.add(
          PreviousSharePrice(
            companyId: row.company.id,
            companyName: _companyLabel(row.company),
            basePrice: previous.basePrice,
            minQty: previous.minQty,
            totalQty: previous.totalQty,
            settlementDays: previous.settlementDays,
            recordedAt: previous.recordedAt,
          ),
        );
      }
      prices.sort(_comparePrevious);
      return PreviousPriceLookup(prices: prices);
    } on FormatException catch (error) {
      return PreviousPriceLookup(error: error.message);
    } catch (_) {
      return const PreviousPriceLookup(
        error: 'Unable to load previous prices. Please retry.',
      );
    }
  }

  /// Writes [prices] into the open tab and moves those companies to the top.
  int applyPreviousPrices(List<PreviousSharePrice> prices) {
    if (prices.isEmpty) return 0;
    final byCompany = {for (final price in prices) price.companyId: price};
    var filled = 0;
    for (final row in rows) {
      final previous = byCompany[row.company.id];
      if (previous == null) continue;
      row.price.text = previous.priceText;
      row.minQty.text = previous.minQty.toString();
      row.totalQty.text = previous.totalQty?.toString() ?? '';
      if (isSell && previous.settlementDays != null) {
        row.settlementDays.value = previous.settlementDays;
      }
      row.errors.clear();
      filled++;
    }
    _loadedPrevious[dealType.value] = byCompany;
    pinnedCompanyId.value = null;
    revision.value++;
    listOrder.value++;
    feedbackIsError.value = false;
    feedback.value = filled == 1
        ? 'Filled the previous price for 1 company.'
        : 'Filled previous prices for $filled companies.';
    return filled;
  }

  /// Applies the common cycle to rows still on the previous common value.
  void setCommonSettlement(int? value) {
    final previous = commonSettlementDays.value;
    commonSettlementDays.value = value;
    editingSettlementCompanyId.value = null;
    for (final row in sellRows) {
      if (row.settlementDays.value == previous) {
        row.settlementDays.value = value;
      }
    }
    revision.value++;
    feedback.value = '';
  }

  void beginEditSettlement(SharePriceDraft row) {
    if (saving.value) return;
    editingSettlementCompanyId.value = row.company.id;
  }

  void cancelEditSettlement() {
    editingSettlementCompanyId.value = null;
  }

  void setRowSettlement(SharePriceDraft row, int? value) {
    row.settlementDays.value = value;
    row.errors.remove('settlement_days');
    editingSettlementCompanyId.value = null;
    revision.value++;
    feedback.value = '';
  }

  String settlementLabelFor(int? value) {
    if (value == null) return '';
    for (final option in settlementOptions) {
      if (option.value == value) return option.label;
    }
    return value > 0 ? 'T+$value' : '';
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
    if (row.errors.containsKey('settlement_days')) {
      editingSettlementCompanyId.value = row.company.id;
    }

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

    editingSettlementCompanyId.value = null;
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
          num.tryParse(row.price.text.trim()) == 0) {
        continue;
      }

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

  Future<List<DealModel>> _fetchUnlistedDeals() async {
    const pageSize = 20;
    final all = <DealModel>[];
    var skip = 0;
    while (skip < 1000) {
      final response = await DealApi.getDealList(
        type: CompanyType.unlisted,
        skip: skip,
        isHotDeal: false,
      );
      if (!response.isSuccess || response.r == null) {
        final message = response.m.trim();
        throw FormatException(
          message.isEmpty
              ? 'Unable to load previous prices. Please retry.'
              : message,
        );
      }
      final page = response.r!;
      all.addAll(page);
      if (page.length < pageSize) return all;
      skip += pageSize;
    }
    return all;
  }

  double? _basePriceOf(DealModel deal) {
    final base = deal.basePrice;
    if (base != null && base > 0) return base;
    if (deal.sharePrice > 0) return deal.sharePrice;
    return null;
  }

  String _companyLabel(LiteCompanyModel company) {
    final brand = company.brandName.trim();
    if (brand.isNotEmpty) return brand;
    return company.companyName.trim();
  }

  bool _isNewer(PreviousSharePrice next, PreviousSharePrice current) {
    final nextAt = next.recordedAt;
    final currentAt = current.recordedAt;
    if (nextAt != null && currentAt != null) return nextAt.isAfter(currentAt);
    if (nextAt != null) return true;
    return false;
  }

  int _comparePrevious(PreviousSharePrice a, PreviousSharePrice b) {
    final aAt = a.recordedAt;
    final bAt = b.recordedAt;
    if (aAt != null && bAt != null) {
      final byDate = bAt.compareTo(aAt);
      if (byDate != 0) return byDate;
    } else if (aAt != null) {
      return -1;
    } else if (bAt != null) {
      return 1;
    }
    final byName = a.companyName.toLowerCase().compareTo(
      b.companyName.toLowerCase(),
    );
    if (byName != 0) return byName;
    return a.companyId.compareTo(b.companyId);
  }

  int _compareRows(
    SharePriceDraft a,
    SharePriceDraft b,
    Map<int, PreviousSharePrice> loaded,
  ) {
    final aPrevious = loaded[a.company.id];
    final bPrevious = loaded[b.company.id];
    if ((aPrevious != null) != (bPrevious != null)) {
      return aPrevious != null ? -1 : 1;
    }
    if (aPrevious != null && bPrevious != null) {
      final byPrice = _comparePrevious(aPrevious, bPrevious);
      if (byPrice != 0) return byPrice;
    }
    final byName = _companyLabel(a.company).toLowerCase().compareTo(
      _companyLabel(b.company).toLowerCase(),
    );
    if (byName != 0) return byName;
    return a.company.id.compareTo(b.company.id);
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
