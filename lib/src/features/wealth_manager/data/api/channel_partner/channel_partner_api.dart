import 'dart:convert';
import 'dart:io';

import 'package:private_deals/src/shared/app_exports.dart';

// #region agent log
void _agentDebugLog({
  required String location,
  required String message,
  required String hypothesisId,
  Map<String, dynamic>? data,
  String runId = 'pre-fix',
}) {
  try {
    final payload = <String, dynamic>{
      'sessionId': 'cb4ba8',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'location': location,
      'message': message,
      'hypothesisId': hypothesisId,
      'runId': runId,
      'data': ?data,
    };
    File(
      '/Users/kd/Development/Project/PrivateDeals/Application/private_deals/.cursor/debug-cb4ba8.log',
    ).writeAsStringSync('${jsonEncode(payload)}\n', mode: FileMode.append);
  } catch (_) {}
}
// #endregion

class ChannelPartnerApi {
  static Future<BaseModel> addChannelPartner({
    required String name,
    required String email,
    required String mobile,
    required String password,
    required String commission,
    required String partner,
    required String gender,
    bool isPrimaryAccess = false,
    bool isSecondaryAccess = false,
    bool isPreIpoAccess = false,
  }) async {
    try {
      Map<String, dynamic> body = {
        'name': name,
        'mobile_number': mobile,
        'email': email,
        // 'commission': commission,
        'gender': gender,
        'partner_type': partner,
        'is_primary_access': isPrimaryAccess ? 1 : 0,
        'is_secondary_access': isSecondaryAccess ? 1 : 0,
        'is_preipo_access': isPreIpoAccess ? 1 : 0,
        'parent_partner_id': app.wUser.id,
        'partner_id': app.wUser.id,
      };

      body.addIf(commission.isNotEmpty, "commission", commission);
      body.addIf(password.isNotEmpty, "password", password);

      // #region agent log
      _agentDebugLog(
        location: 'channel_partner_api.dart:addChannelPartner',
        message: 'POST body before request',
        hypothesisId: 'A,E,F',
        data: {
          'endpoint': AppUrl.wAddChannelPartner,
          'bodyKeys': body.keys.toList(),
          'partner_type': body['partner_type'],
          'hasPartnerKey': body.containsKey('partner'),
          'partner_id': body['partner_id'],
          'parent_partner_id': body['parent_partner_id'],
          'is_primary_access': body['is_primary_access'],
          'is_primary_access_runtimeType': body['is_primary_access']
              ?.runtimeType
              .toString(),
          'accessFieldsMatchPassword':
              body['is_primary_access'] == password &&
              body['is_secondary_access'] == password &&
              body['is_preipo_access'] == password,
          'wUserId': app.wUser.id,
          'wUserType': app.wUser.type,
        },
      );
      // #endregion

      var res = await dioConfig.post(AppUrl.wAddChannelPartner, body);
      final result = BaseModel.fromMessage(res.data);

      // #region agent log
      _agentDebugLog(
        location: 'channel_partner_api.dart:addChannelPartner',
        message: 'POST response',
        hypothesisId: 'A,B,C',
        data: {
          'status': result.s,
          'message': result.m,
          'isSuccess': result.isSuccess,
        },
      );
      // #endregion

      return result;
    } catch (e) {
      logger.e(e);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<PartnerUser>>> channelPartnerList() async {
    try {
      var res = await dioConfig.get(AppUrl.wChannelPartnerList, {});
      BaseModel<List<PartnerUser>> baseModel = BaseModel.fromListJson(
        res.data,
        (p0) => p0.map((e) => PartnerUser.fromJson(e)).toList(),
      );
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Channel Partner List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<PartnerUser>>> relationManagerGet() async {
    try {
      var res = await dioConfig.get(AppUrl.wRelationManager, {});
      BaseModel<List<PartnerUser>> baseModel = BaseModel.fromListJson(
        res.data,
        (p0) => p0.map((e) => PartnerUser.fromJson(e)).toList(),
      );
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Relation Manager List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
