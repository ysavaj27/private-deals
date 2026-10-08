import 'package:private_deals/src/shared/app_exports.dart';

class PrimaryDetailPageCtrl extends GetxController
    with GetSingleTickerProviderStateMixin {
  RxBool isLoading = false.obs;
  RxBool isCommitting = false.obs;
  var startupId = Get.arguments ?? 0;
  bool fromSecondary = Get.previousRoute == Routes.secondary;
  final TextEditingController commitCTRL = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Rx<StartupModel> startupDetailModel = StartupModel.fromJson({}).obs;
  Rx<StartupDetailEnum> currentTab = StartupDetailEnum.idea.obs;
  ScrollController scrollController = ScrollController();
  final List<GlobalKey> keys = List.generate(
    StartupDetailEnum.values.length,
    (index) => GlobalKey(),
  );
  RxInt selectedIndex = 0.obs;

  ScrollController parentController = ScrollController();
  ScrollController childController = ScrollController();

  TabController? _tabController;
  TabController get tabController => _tabController!;

  // Observable to control which scroll view should be active
  var isParentScrolling = true.obs;

  // Method to handle parent scroll events
  void handleParentScroll() {
    // Check if parent has reached its max extent
    if (isParentScrolling.value &&
        parentController.offset >= maxParentScrollExtent) {
      isParentScrolling.value = false; // Switch to child scroll
    }
    bool childCanScroll = childController.position.maxScrollExtent > 0;

    // If the child cannot scroll, enable parent scrolling
    if (!childCanScroll) {
      isParentScrolling.value = true;
    }
  }

  // Method to handle child scroll events
  void handleChildScroll() {
    // Check if child has reached its min extent (top of the scroll)
    if (!isParentScrolling.value &&
        childController.offset <= minChildScrollExtent) {
      isParentScrolling.value = true; // Switch back to parent scroll
    }
  }

  // Getter to access maximum scroll extent of parent scroll view
  double get maxParentScrollExtent => parentController.position.maxScrollExtent;

  // Getter to access maximum scroll extent of child scroll view
  double get maxChildScrollExtent => childController.position.maxScrollExtent;

  // Minimum scroll extent is always 0 for both scroll views
  double get minParentScrollExtent => 0.0;

  double get minChildScrollExtent => 0.0;

  void scrollToSelectedIndex(int index) {
    final keyContext = keys[index].currentContext;
    if (keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox;
      final position = box.localToGlobal(
        Offset.zero,
        ancestor: Get.context?.findRenderObject(),
      );
      final screenWidth = MediaQuery.of(Get.context!).size.width;
      final targetScrollOffset =
          scrollController.offset +
          position.dx -
          (screenWidth / 2) +
          (box.size.width / 2);
      scrollController.animateTo(
        targetScrollOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      selectedIndex(index);
    }
  }

  StartupModel get model => startupDetailModel();

  void listener() {
    parentController.addListener(handleParentScroll);
    childController.addListener(handleChildScroll);
    // if(app.fromSecondary){
    //   currentTab(StartupDetailEnum.market);
    // }
  }

  Future<void> getData() async {
    isLoading(true);
    final startup = Get.parameters['slug'] ?? "";
    var res = await LandingPageApi.wStartupDetail(startup);
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      startupDetailModel(res.r);
    } else {
      toast(res.m);
    }
  }

  Future<void> applyPitch({
    required int startupId,
    required int pitchId,
  }) async {
    var res = await LivePitchApi.applyPitch(
      pitchId: pitchId,
      startupId: startupId,
    );
    if (res.isSuccess) {
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }

  Future<void> commit() async {
    // isCommitting(true);
    // var res = await StartUpDetailApi.commit(startupId, commitCTRL.text.trim());
    // isCommitting(false);
    // if (res.isSuccess) {
    //   Get.back();
    //   toast(res.m, MessageEnum.success);
    // } else {
    //   toast(res.m, MessageEnum.error);
    // }
  }

  @override
  void onInit() {
    listener();
    getData();
    _tabController?.dispose();
    _tabController = TabController(length: 7, vsync: this);
    super.onInit();
  }

  @override
  void onClose() {
    parentController.dispose();
    childController.dispose();
    // app.fromSecondary = false;
    commitCTRL.dispose();
    scrollController.dispose();
    _tabController?.dispose();
    super.onClose();
  }
}
