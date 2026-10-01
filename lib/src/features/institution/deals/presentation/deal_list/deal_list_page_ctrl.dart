import 'dart:async';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/api/deal_api.dart';
import 'package:private_deals/src/features/institution/data/models/deal/deal_model.dart';

class DealListPageCtrl extends GetxController {
  DealRouteContext? _dealRoute;

  CompanyType get type => _dealRoute!.type;
  String get title => _dealRoute!.title;

  Future<void> getData() async {
    final route = DealRouteContext.fromPath(Get.currentRoute);
    if (_dealRoute?.type == route.type) return;

    _dealRoute = route;
    _requestId++;
    searchController.clear();
    query.value = '';
    currentPage.value = 0;
    hasNextPage.value = false;
    deals.clear();
    deleteError.value = '';
    await fetchDeals(page: 0);
  }

  final isDeleting = false.obs;
  final deleteError = ''.obs;

  static const pageSize = 20;

  final deals = <DealModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final query = ''.obs;

  final currentPage = 0.obs;
  final hasNextPage = false.obs;

  final searchController = TextEditingController();

  late final Worker _searchWorker;

  int _requestId = 0;
  int _retryPage = 0;

  // Refresh status when a deal expires while this page is open.
  final now = DateTime.now().obs;
  Timer? _expiryTimer;

  List<DealModel> get filteredDeals => deals.toList();

  @override
  void onInit() {
    super.onInit();
    getData();

    _searchWorker = debounce<String>(
      query,
      (_) => fetchDeals(page: 0),
      time: const Duration(milliseconds: 350),
    );

    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = DateTime.now();

      final statusChanged = deals.any(
        (deal) =>
            now.value.isBefore(deal.expiredAt) != next.isBefore(deal.expiredAt),
      );

      if (statusChanged) {
        now.value = next;
      }
    });
  }

  void updateSearch(String value) {
    final search = value.trim();
    if (query.value == search) return;

    // Prevent an older request from updating the new search.
    _requestId++;

    currentPage.value = 0;
    hasNextPage.value = false;
    deals.clear();
    errorMessage.value = '';
    isLoading.value = true;
    query.value = search;
  }

  void clearSearch() {
    searchController.clear();
    updateSearch('');
  }

  Future<bool> deleteDeal(DealModel deal) async {
    if (isClosed || isDeleting.value) return false;

    deleteError.value = '';

    if (!deal.isMine || deal.uuid.trim().isEmpty) {
      deleteError.value = 'This deal cannot be deleted.';
      return false;
    }

    isDeleting.value = true;

    try {
      final res = await DealApi.deleteDeal(deal.uuid);

      if (isClosed) return false;

      if (!res.isSuccess) {
        deleteError.value = 'Unable to delete this deal. Please try again.';
        return false;
      }

      // Remove only after the API confirms success.
      deals.removeWhere((item) => item.uuid == deal.uuid);

      // Move back if the deleted record was the last item on this page.
      final targetPage = deals.isEmpty && currentPage.value > 0
          ? currentPage.value - 1
          : currentPage.value;

      // Reload to refill the page and update hasNextPage.
      // Existing request-ID protection prevents stale responses.
      await fetchDeals(page: targetPage);

      // Deletion succeeded even if the list refresh reports an error.
      return true;
    } catch (e) {
      if (!isClosed) {
        deleteError.value = 'Unable to delete this deal. Please try again.';
        debugPrint('deleteDeal failed: $e');
      }

      return false;
    } finally {
      if (!isClosed) {
        isDeleting.value = false;
      }
    }
  }

  Future<void> fetchDeals({int? page}) async {
    final targetPage = page ?? currentPage.value;
    if (targetPage < 0) return;

    final requestId = ++_requestId;
    _retryPage = targetPage;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Same API calling pattern as your company controller.
      final res = await DealApi.getDealList(
        search: query.value,
        type: type,
        skip: targetPage * pageSize,
      );
      // logger.d('Deal Length :${res.r?.length}');

      if (isClosed || requestId != _requestId) return;

      if (!res.isSuccess) {
        errorMessage.value = 'Unable to load deals. Please try again.';
        return;
      }

      final items = res.r ?? <DealModel>[];

      // Keep the current page visible if Next returns no records.
      if (items.isEmpty && targetPage > currentPage.value && deals.isNotEmpty) {
        hasNextPage.value = false;
        return;
      }

      now.value = DateTime.now();
      deals.assignAll(items);
      currentPage.value = targetPage;
      hasNextPage.value = items.length == pageSize;
    } catch (e) {
      if (isClosed || requestId != _requestId) return;

      errorMessage.value = 'Unable to load deals. Please try again.';

      debugPrint('fetchDeals failed: $e');
    } finally {
      if (!isClosed && requestId == _requestId) {
        isLoading.value = false;
      }
    }
  }

  void nextPage() {
    if (isLoading.value || !hasNextPage.value) return;
    fetchDeals(page: currentPage.value + 1);
  }

  void previousPage() {
    if (isLoading.value || currentPage.value == 0) return;
    fetchDeals(page: currentPage.value - 1);
  }

  void retry() {
    if (isLoading.value) return;
    fetchDeals(page: _retryPage);
  }

  // Keep your existing navigation methods here.

  @override
  void onClose() {
    _requestId++;
    _searchWorker.dispose();
    _expiryTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }
}

class DealRouteContext {
  const DealRouteContext({required this.type});

  final CompanyType type;

  factory DealRouteContext.fromPath(String path) {
    final segments = Uri.parse(path).pathSegments;
    if (segments.length >= 3 &&
        segments[0] == 'institution' &&
        segments[1] == 'deals') {
      if (segments[2] == 'unlisted')
        return const DealRouteContext(type: CompanyType.unlisted);
      if (segments[2] == 'secondary')
        return const DealRouteContext(type: CompanyType.secondary);
    }
    throw StateError('This route is not a hot deals section: $path');
  }

  String get title =>
      type == CompanyType.unlisted ? 'Unlisted Deals' : 'LP Secondary Deals';
}
