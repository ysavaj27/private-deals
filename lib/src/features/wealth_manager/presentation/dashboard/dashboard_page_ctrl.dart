import 'package:private_deals/src/shared/app_exports.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import 'dashboard_debug_data.dart';

class DashboardPageCtrl extends GetxController {
  final isLoading = false.obs;
  final isData = false.obs;
  final error = ''.obs;
  final currentIndex = DashboardTypeEnum.preIpo.obs;
  final model = WDashboardModel.fromJson({}).obs;
  final lastUpdated = Rxn<DateTime>();
  final scrollController = ScrollController();
  final _cache = <DashboardTypeEnum, WDashboardModel>{};
  final _updatedAt = <DashboardTypeEnum, DateTime>{};
  final _showDummyData = false.obs;
  final _debugModels = <DashboardTypeEnum, WDashboardModel>{};
  int _request = 0;

  bool get isPrimary => currentIndex() == DashboardTypeEnum.primary;
  bool get isShowingDummyData => kDebugMode && _showDummyData();

  WDashboardModel get displayedModel {
    if (kDebugMode && isShowingDummyData) {
      return _debugModels.putIfAbsent(
        currentIndex(),
        () => createDashboardDebugData(isPrimary: isPrimary),
      );
    }
    return model();
  }

  Future<void> setShowDummyData(bool value) async {
    if (!kDebugMode) return;
    _showDummyData(value);
    if (!value && !isData() && !isLoading()) await getData();
  }

  @override
  void onInit() {
    super.onInit();
    getAllData();
  }

  Future<void> getAllData() async {
    currentIndex(
      app.wUser.isPreIpoAccess
          ? DashboardTypeEnum.preIpo
          : DashboardTypeEnum.primary,
    );
    await getData();
  }

  Future<void> changeTab(DashboardTypeEnum type) async {
    if (currentIndex() == type) return;
    ++_request;
    currentIndex(type);
    error('');
    final cached = _cache[type];
    isData(cached != null);
    model(cached ?? WDashboardModel.fromJson({}));
    lastUpdated(_updatedAt[type]);
    isLoading(false);
    if (cached == null && !isShowingDummyData) await getData();
  }

  Future<void> getData() async {
    if (isShowingDummyData) return;
    final request = ++_request;
    final selected = currentIndex();
    isLoading(true);
    error('');
    try {
      final response = selected == DashboardTypeEnum.primary
          ? await DashboardApi.wealthManagerDashboard()
          : await DashboardApi.wealthManagerPreIPODashboard();
      if (isClosed || request != _request) return;
      if (response.isSuccess && response.r != null) {
        final now = DateTime.now();
        _cache[selected] = response.r!;
        _updatedAt[selected] = now;
        model(response.r!);
        lastUpdated(now);
        isData(true);
      } else {
        error('We could not update this dashboard. Please try again.');
      }
    } catch (_) {
      if (!isClosed && request == _request) {
        error('We could not update this dashboard. Please try again.');
      }
    } finally {
      if (!isClosed && request == _request) isLoading(false);
    }
  }

  @override
  void onClose() {
    ++_request;
    scrollController.dispose();
    super.onClose();
  }
}
