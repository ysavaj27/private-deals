import 'package:private_deals/src/core/config/api_endpoints.dart' as core;
import 'package:private_deals/src/features/institution/data/institution_endpoints.dart';

/// API contracts used by the restored Institution screens.
abstract final class AppUrl {
  static const imageURL = core.AppUrl.imageURL;
  static const dashboard = InstitutionEndpoints.dashboard;
}
