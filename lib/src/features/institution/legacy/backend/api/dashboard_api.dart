import 'package:private_deals/src/features/institution/legacy/backend/model/dashboard/dashboard_model.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/features/institution/legacy/utils/constant/app_url.dart';

class DashboardApi {
  static Future<DashboardModel> getDashboard() async {
    final response = await dioConfig.get(AppUrl.dashboard, {});
    return DashboardModel.fromJson(Map<String, dynamic>.from(response.data));
  }
}
