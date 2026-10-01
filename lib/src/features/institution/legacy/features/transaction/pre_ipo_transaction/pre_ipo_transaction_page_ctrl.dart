import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/legacy/backend/api/pre_ipo_transaction_api.dart';
import 'package:private_deals/src/shared/models/base_model.dart';
import 'package:private_deals/src/features/institution/legacy/backend/model/transaction/pre_ipo_transaction_model.dart';

enum PreIPOTransactionFilter {
  pending('Pending'),
  processing('Processing'),
  completed('Completed');

  const PreIPOTransactionFilter(this.label);
  final String label;
}

typedef TransactionLoader =
    Future<BaseModel<List<PreIPOTransactionModel>>> Function({
      required String status,
      String company,
      required int skip,
      int take,
    });

class PreIPOTransactionPageCtrl extends GetxController {
  PreIPOTransactionPageCtrl({TransactionLoader? loader})
    : _loader = loader ?? PreIPOTransactionApi.getTransactions;
  final TransactionLoader _loader;
  static const pageSize = 20;
  final searchController = TextEditingController();
  final transactions = <PreIPOTransactionModel>[].obs;
  final filter = PreIPOTransactionFilter.pending.obs;
  final loading = false.obs;
  final error = ''.obs;
  final page = 0.obs;
  final hasNext = false.obs;
  String _company = '';
  Timer? _debounce;
  int _requestId = 0;
  int _retryPage = 0;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  void selectFilter(PreIPOTransactionFilter value) {
    if (value == filter.value) return;
    _debounce?.cancel();
    filter.value = value;
    _reset();
    fetch();
  }

  void search(String value) {
    final query = value.trim();
    if (_company == query) return;
    _company = query;
    _debounce?.cancel();
    _reset();
    loading.value = true;
    _debounce = Timer(const Duration(milliseconds: 350), fetch);
  }

  void _reset() {
    _requestId++;
    page.value = 0;
    hasNext.value = false;
    transactions.clear();
    error.value = '';
  }

  Future<void> fetch({int? targetPage}) async {
    final target = targetPage ?? page.value;
    if (target < 0) return;
    final requestId = ++_requestId;
    _retryPage = target;
    loading.value = true;
    error.value = '';
    try {
      final res = await _loader(
        status: filter.value.name,
        company: _company,
        skip: target * pageSize,
        take: pageSize,
      );
      if (isClosed || requestId != _requestId) return;
      if (!res.isSuccess) {
        error.value = 'Unable to load transactions. Please retry.';
        return;
      }
      final items = res.r ?? <PreIPOTransactionModel>[];
      if (items.isEmpty && target > page.value && transactions.isNotEmpty) {
        hasNext.value = false;
        return;
      }
      transactions.assignAll(items);
      page.value = target;
      hasNext.value = items.length == pageSize;
    } catch (_) {
      if (!isClosed && requestId == _requestId) {
        error.value = 'Unable to load transactions. Please retry.';
      }
    } finally {
      if (!isClosed && requestId == _requestId) loading.value = false;
    }
  }

  void nextPage() {
    if (!loading.value && hasNext.value) fetch(targetPage: page.value + 1);
  }

  void previousPage() {
    if (!loading.value && page.value > 0) fetch(targetPage: page.value - 1);
  }

  void retry() {
    if (!loading.value) fetch(targetPage: _retryPage);
  }

  @override
  void onClose() {
    _requestId++;
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
