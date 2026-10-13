import 'package:private_deals/src/features/institution/data/institution_endpoints.dart';

/// API contracts used by the restored Institution screens.
abstract final class AppUrl {
  static const imageURL =
      'https://s3-ap-south-1.amazonaws.com/privatedeals-main-storage/';
  static const dashboard = InstitutionEndpoints.dashboard;
}
