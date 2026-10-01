// import 'package:private_deals/src/shared/app_exports.dart';
// import 'package:get/get.dart';
// import 'package:shuru_up/src/backend/master/master_api.dart';
// import 'package:shuru_up/src/models/master/master_type.dart';
//
// import '../models/master/api_config_model.dart';
//
// final MasterConfig masterConfig = MasterConfig.instance;
//
// class MasterConfig extends GetxService {
//   static final MasterConfig instance = MasterConfig();
//   Rx<ApiConfigModel> configData = ApiConfigModel.fromJson({}).obs;
//   RxList<MasterTypeModel> sectorList = <MasterTypeModel>[].obs;
//   RxList<MasterTypeModel> instrumentsList = <MasterTypeModel>[].obs;
//   RxList<MasterTypeModel> investorList = <MasterTypeModel>[].obs;
//
//   ApiConfigModel get config => configData();
//
//   List<String> get docExtension => configData().documentExtensions.split(",");
//
//   List<MasterTypeModel> get sectors => sectorList();
//
//   List<MasterTypeModel> get instruments => instrumentsList();
//
//   List<MasterTypeModel> get investors => investorList();
//
//   Future<void> getAll() async {
//     try {
//       await MasterApi.getConfigData();
//       await MasterApi.getAllSectors();
//       await MasterApi.instrumentType();
//       await MasterApi.getInvestorType();
//     } on Exception catch (e) {
//       logger.d("Error Found :$e");
//     }
//   }
// }
