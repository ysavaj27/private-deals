import 'package:private_deals/src/shared/app_exports.dart';

enum PrimaryCatalogTab {
  raisingNow('Raising now', 'raisingnow'),
  comingSoon('Coming soon', 'comingsoon'),
  completed('Completed', 'completed');

  const PrimaryCatalogTab(this.label, this.slug);
  final String label;
  final String slug;
}

class PrimaryLandingPageCtrl extends GetxController {
  final isLoading = false.obs;
  final loadError = ''.obs;
  final blogsLoading = false.obs;
  final blogsError = ''.obs;
  final sectorsLoading = false.obs;
  final sectorsError = ''.obs;
  final blogs = <BlogModel>[].obs;
  final sectors = <SectorModel>[].obs;
  final model = LandingPageModel.fromJson({}).obs;
  final tab = PrimaryCatalogTab.raisingNow.obs;
  final query = ''.obs;
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  List<StartupRoundModel> startupsFor(PrimaryCatalogTab category) =>
      switch (category) {
        PrimaryCatalogTab.raisingNow => model().raisingNow,
        PrimaryCatalogTab.comingSoon => model().comingSoon,
        PrimaryCatalogTab.completed => model().completed,
      };

  // Availability is based on API data, not the current search results.
  List<PrimaryCatalogTab> get availableTabs => PrimaryCatalogTab.values
      .where((category) => startupsFor(category).isNotEmpty)
      .toList();

  PrimaryCatalogTab? get selectedTab {
    final available = availableTabs;
    if (available.contains(tab.value)) return tab.value;
    return available.isEmpty ? null : available.first;
  }

  List<StartupRoundModel> get currentStartups {
    final selected = selectedTab;
    final source = selected == null
        ? <StartupRoundModel>[]
        : startupsFor(selected);
    final text = query.value.trim().toLowerCase();
    return source
        .where(
          (round) =>
              '${round.startup.brandName} ${round.startup.companyName} ${round.startup.sector.name} ${round.startup.city.name}'
                  .toLowerCase()
                  .contains(text),
        )
        .toList();
  }

  Future<void> getData() async {
    isLoading(true);
    loadError('');
    try {
      final res = await LandingPageApi.wHomePage();
      if (isClosed) return;
      if (res.isSuccess && res.r != null) {
        model(res.r);
      } else {
        loadError('We couldn’t load startups. Please try again.');
      }
    } catch (_) {
      if (!isClosed) loadError('We couldn’t load startups. Please try again.');
    } finally {
      if (!isClosed) isLoading(false);
    }
  }

  Future<void> blogList() async {
    blogsLoading(true);
    blogsError('');
    try {
      final res = await LandingPageApi.blogList();
      if (isClosed) return;
      if (res.isSuccess && res.r != null) {
        blogs(res.r);
      } else {
        blogsError('We couldn’t load articles. Please try again.');
      }
    } catch (_) {
      if (!isClosed) blogsError('We couldn’t load articles. Please try again.');
    } finally {
      if (!isClosed) blogsLoading(false);
    }
  }

  Future<void> sectorList() async {
    sectorsLoading(true);
    sectorsError('');
    try {
      final res = await MasterApi.sectorList();
      if (isClosed) return;
      if (res.isSuccess && res.r != null) {
        sectors(res.r);
      } else {
        sectorsError('We couldn’t load sectors. Please try again.');
      }
    } catch (_) {
      if (!isClosed) {
        sectorsError('We couldn’t load sectors. Please try again.');
      }
    } finally {
      if (!isClosed) sectorsLoading(false);
    }
  }

  @override
  void onInit() {
    super.onInit();
    getData();
    blogList();
    sectorList();
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
