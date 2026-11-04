import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import '../primary_startup_card.dart';
import 'primary_list_page_ctrl.dart';

class PrimaryListPage extends StatelessWidget {
  final PrimaryListPageCtrl c = Get.put(PrimaryListPageCtrl());
  PrimaryListPage({super.key});

  @override
  Widget build(BuildContext context) => const PrimaryListView();
}

class PrimaryListView extends StatelessWidget {
  const PrimaryListView({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<PrimaryListPageCtrl>();
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackLogic(context, didPop),
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: onBackPressed),
          title: Text(c.title),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore companies and review their investment terms.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          key: const ValueKey('primary-list-search'),
                          controller: c.searchController,
                          onChanged: c.query.call,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search_rounded),
                            hintText: 'Search startups, sectors or cities',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (c.isLoading.value) return const Loader();
                      if (c.loadError.value.isNotEmpty) {
                        return SingleChildScrollView(
                          child: PrimaryCatalogState(
                            title: 'Startups are unavailable',
                            message: c.loadError.value,
                            onRetry: c.getData,
                          ),
                        );
                      }
                      final startups = c.filteredList;
                      if (startups.isEmpty) {
                        return const SingleChildScrollView(
                          child: PrimaryCatalogState(
                            title: 'No matching startups',
                            message: 'Try another search or check back for new opportunities.',
                          ),
                        );
                      }
                      return CustomScrollView(
                        controller: c.scrollController,
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                '${startups.length} ${startups.length == 1 ? 'startup' : 'startups'}',
                                style: theme.textTheme.labelLarge,
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                            sliver: PrimaryCatalogSliverGrid(
                              itemCount: startups.length,
                              itemBuilder: (_, index) => PrimaryStartupCard(
                                round: startups[index],
                                comingSoon:
                                    Get.parameters['slug'] == 'comingsoon',
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
