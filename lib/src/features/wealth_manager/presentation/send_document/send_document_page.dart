import 'package:private_deals/src/features/wealth_manager/presentation/send_document/documents_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/send_document/send_document_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class SendDocumentPage extends StatelessWidget {
  SendDocumentPage({super.key}) {
    Get.put(SendDocumentPageCtrl());
  }

  @override
  Widget build(BuildContext context) => const DocumentsView();
}
