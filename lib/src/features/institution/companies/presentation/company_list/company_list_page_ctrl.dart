import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/api/company_api.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/data/models/company/company_model.dart';
import 'package:private_deals/src/features/institution/institution_routes.dart';
import 'package:private_deals/src/features/institution/support/plugins/logger.dart';

class CompanyListPageCtrl extends GetxController {
  late CompanyRouteContext companyRoute;

  CompanyType get companyType => companyRoute.type;

  static const pageSize = 20;

  final mySubmissions = false.obs;
  final companies = <CompanyModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final query = ''.obs;

  final currentPage = 0.obs; // Zero-based internally.
  final hasNextPage = false.obs;

  // final searchController = TextEditingController();

  late final Worker _searchWorker;
  int _requestId = 0;
  int _retryPage = 0;

  List<CompanyModel> get filteredCompanies => companies.toList();

  @override
  void onInit() {
    super.onInit();
    getData();
    _searchWorker = debounce<String>(
      query,
      (_) => fetchCompanies(page: 0),
      time: const Duration(milliseconds: 350),
    );
  }

  Future<void> getData() async {
    // logger.d('START GET DATA CALLED');
    companyRoute = CompanyRouteContext.fromPath(Get.currentRoute);
    await fetchCompanies();
    // logger.d('END GET DATA CALLED');
  }

  void updateSearch(String value) {
    final search = value.trim();
    if (query.value == search) return;

    // Prevent an older request from updating the new search.
    _requestId++;

    currentPage.value = 0;
    hasNextPage.value = false;
    companies.clear();
    errorMessage.value = '';
    isLoading.value = true;
    query.value = search;
  }

  void clearSearch() {
    // searchController.clear();
    updateSearch('');
  }

  Future<void> fetchCompanies({int? page}) async {
    final targetPage = page ?? currentPage.value;
    if (targetPage < 0) return;

    final requestId = ++_requestId;
    _retryPage = targetPage;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final res = await CompanyApi.getCompanyList(
        search: query.value,
        mySubmissions: mySubmissions(),
        skip: targetPage * pageSize,
        type: companyType,
        // For a one-based page API, use:
        // skip: targetPage + 1,
      );

      if (isClosed || requestId != _requestId) return;

      if (!res.isSuccess) {
        errorMessage.value = 'Unable to load companies. Please try again.';
        return;
      }

      final items = res.r ?? <CompanyModel>[];

      // Without a total count, a full page may be the last page.
      // Keep the current page visible if Next returns no records.
      if (items.isEmpty &&
          targetPage > currentPage.value &&
          companies.isNotEmpty) {
        hasNextPage.value = false;
        return;
      }

      companies.assignAll(items);
      currentPage.value = targetPage;
      hasNextPage.value = items.length == pageSize;
    } catch (e) {
      if (isClosed || requestId != _requestId) return;

      errorMessage.value = 'Unable to load companies. Please try again.';
      debugPrint('fetchCompanies failed: $e');
    } finally {
      if (!isClosed && requestId == _requestId) {
        isLoading.value = false;
      }
    }
  }

  Future<void> openShareholders(CompanyModel company) async {
    if (!company.isEditable) return;
    final saved = await Get.toNamed(
      InstitutionRoutes.shareholdersPage
          .replaceFirst(':type', companyType.value)
          .replaceFirst(':slug', Uri.encodeComponent(company.slug)),
    );
    if (saved == true && !isClosed) await fetchCompanies();
  }

  Future<void> openPromoters(CompanyModel company) async {
    if (!company.isEditable) return;
    final slug = company.slug;
    var route = InstitutionRoutes.promotersPage
        .replaceFirst(':type', companyType.value)
        .replaceFirst(':slug', Uri.encodeComponent(slug));
    logger.d(route);
    final saved = await Get.toNamed(route);

    if (saved == true) {
      await fetchCompanies();
    }
  }

  void nextPage() {
    if (isLoading.value || !hasNextPage.value) return;
    fetchCompanies(page: currentPage.value + 1);
  }

  void previousPage() {
    if (isLoading.value || currentPage.value == 0) return;
    fetchCompanies(page: currentPage.value - 1);
  }

  void retry() {
    if (isLoading.value) return;
    fetchCompanies(page: _retryPage);
  }

  // Keep your existing navigation methods.

  @override
  void onClose() {
    _requestId++;
    _searchWorker.dispose();
    // searchController.dispose();
    super.onClose();
  }
}

class CompanyRouteContext {
  const CompanyRouteContext({required this.tab});

  final WTabBarEnum tab;

  factory CompanyRouteContext.fromPath(String path) {
    final segments = Uri.parse(path).pathSegments;

    if (segments.length < 3 ||
        segments.first != 'institution' ||
        segments[1] != 'companies') {
      throw StateError('Invalid company route: $path');
    }

    // Use strict matching here. fromSlug() defaults unknown slugs
    // to dashboard, which could hide an invalid company route.
    final tab = WTabBarEnum.values.firstWhereOrNull(
      (value) =>
          (value == WTabBarEnum.preIPOList ||
              value == WTabBarEnum.secondaryList) &&
          value.slug == segments[2],
    );

    if (tab != WTabBarEnum.preIPOList && tab != WTabBarEnum.secondaryList) {
      throw StateError('This route is not a company section: $path');
    }

    return CompanyRouteContext(tab: tab!);
  }

  CompanyType get type => tab == WTabBarEnum.preIPOList
      ? CompanyType.unlisted
      : CompanyType.secondary;

  String get title => tab == WTabBarEnum.preIPOList
      ? 'Unlisted Companies'
      : 'LP Secondary companies';

  String get listPath => '/institution/companies/${tab.slug}';

  String get createPath => '$listPath/create';
}
