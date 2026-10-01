import 'package:private_deals/src/shared/app_exports.dart';

class BlogListPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxList<BlogModel> blogs = <BlogModel>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }
  Future<void> getData() async {
    isLoading(true);
    var res = await LandingPageApi.blogList();
    isLoading(false);
    if (res.isSuccess) {
      blogs(res.r);
    } else {
      toast(res.m);
    }
  }
}
