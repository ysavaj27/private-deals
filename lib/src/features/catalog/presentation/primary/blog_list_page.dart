import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import 'primary_landing_content.dart' show PrimaryBlogCard;
import '../widgets/catalog_article_card.dart';

class BlogListPage extends StatefulWidget {
  const BlogListPage({super.key});

  @override
  State<BlogListPage> createState() => _BlogListPageState();
}

class _BlogListPageState extends State<BlogListPage> {
  late Future<BaseModel<List<BlogModel>>> _blogs = LandingPageApi.blogList();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Blogs'),
      leading: BackButton(onPressed: onBackPressed),
    ),
    body: FutureBuilder<BaseModel<List<BlogModel>>>(
      future: _blogs,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Loader();
        }
        final result = snapshot.data;
        if (snapshot.hasError || result == null || !result.isSuccess) {
          return Center(
            child: TextButton.icon(
              onPressed: () =>
                  setState(() => _blogs = LandingPageApi.blogList()),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry loading blogs'),
            ),
          );
        }
        final blogs = result.r ?? [];
        if (blogs.isEmpty) return const NoDataView(isRefreshButton: false);
        return CatalogArticleGrid(
          itemCount: blogs.length,
          itemBuilder: (_, index) => PrimaryBlogCard(blog: blogs[index]),
        );
      },
    ),
  );
}
