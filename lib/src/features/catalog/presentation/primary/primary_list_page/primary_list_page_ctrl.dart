import 'package:private_deals/src/shared/app_exports.dart';

class PrimaryListPageCtrl extends GetxController {
  final isLoading = false.obs;
  final loadError = ''.obs;
  final list = <StartupRoundModel>[].obs;
  final query = ''.obs;
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  List<StartupRoundModel> get filteredList {
    final text = query.value.trim().toLowerCase();
    return list
        .where(
          (round) =>
              '${round.startup.brandName} ${round.startup.companyName} ${round.startup.sector.name} ${round.startup.city.name}'
                  .toLowerCase()
                  .contains(text),
        )
        .toList();
  }

  String get title {
    final slug = Get.parameters['slug'] ?? '';
    return switch (slug) {
      'raisingnow' => 'Raising now',
      'comingsoon' => 'Coming soon',
      'completed' => 'Completed startups',
      '' => 'Startups',
      _ => slug.replaceAll('-', ' ').capitalizeFirst ?? 'Startups',
    };
  }

  Future<void> getData() async {
    isLoading(true);
    loadError('');
    try {
      final res = await LandingPageApi.wNewStartupList(
        slug: Get.parameters['slug'] ?? '',
      );
      if (isClosed) return;
      if (res.isSuccess && res.r != null) {
        list.assignAll(res.r!);
      } else {
        loadError('We couldn’t load startups. Please try again.');
      }
    } catch (_) {
      if (!isClosed) loadError('We couldn’t load startups. Please try again.');
    } finally {
      if (!isClosed) isLoading(false);
    }
  }

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
