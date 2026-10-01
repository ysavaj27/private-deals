import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/auth/presentation/inquiry/desktop_Inquiry_view.dart';
import 'package:private_deals/src/features/auth/presentation/inquiry/inquiry_page_ctrl.dart';
import 'package:private_deals/src/features/auth/presentation/inquiry/phone_Inquiry_view.dart';

class InquiryPage extends StatelessWidget {
  final InquiryPageCtrl c = Get.put(InquiryPageCtrl());

  InquiryPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneInquiryView();
    } else {
      return DesktopInquiryView();
    }
  }
}
