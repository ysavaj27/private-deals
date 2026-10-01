import 'package:private_deals/src/shared/app_exports.dart';

class BlogDetailPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  Rx<BlogModel> model = BlogModel.fromJson({}).obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    final data = Get.parameters['slug'] ?? "";
    if (data.isNotEmpty) {
      isLoading(true);
      var res = await LandingPageApi.blogDetail(slug: data);
      model(res.r);
      isLoading(false);
    }
  }
}
