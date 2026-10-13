import 'package:private_deals/src/features/wealth_manager/data/models/document/partner_document_model.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/send_document/send_document_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/widgets/workspace_widgets.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class DocumentsView extends StatefulWidget {
  const DocumentsView({super.key});

  @override
  State<DocumentsView> createState() => _DocumentsViewState();
}

class _DocumentsViewState extends State<DocumentsView> {
  final c = Get.find<SendDocumentPageCtrl>();

  @override
  Widget build(BuildContext context) => Obx(() {
        final rows = c.filteredDocuments;
        final types = c.typeOptions;
        final busy = c.isLoading() || c.isSending() || c.isDownloading();
        return WorkspacePage(
          title: 'Documents',
          subtitle:
              'List, download, and send client documents for your investors.',
          onRefresh: c.refreshData,
          loading: c.isLoading(),
          error: c.error(),
          header: [
            Text(
              'Document type',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpace.sm),
            Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: [
                ChoiceChip(
                  label: const Text('All types'),
                  selected: c.selectedType().isEmpty,
                  showCheckmark: false,
                  onSelected: busy
                      ? null
                      : (_) => c.selectType(''),
                ),
                for (final option in types)
                  ChoiceChip(
                    label: Text(option.label),
                    selected: c.selectedType() == option.value,
                    showCheckmark: false,
                    onSelected: busy
                        ? null
                        : (_) => c.selectType(option.value),
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.lg),
            Text(
              'Status',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpace.sm),
            Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: c.selectedStatus().isEmpty,
                  showCheckmark: false,
                  onSelected: busy
                      ? null
                      : (_) => c.selectStatus(''),
                ),
                for (final status in PartnerDocumentStatus.all)
                  ChoiceChip(
                    label: Text(PartnerDocumentStatus.label(status)),
                    selected: c.selectedStatus() == status,
                    showCheckmark: false,
                    onSelected: busy
                        ? null
                        : (_) => c.selectStatus(status),
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.xl),
            WorkspaceSearch(
              hint: 'Search investor, type, or transaction',
              onChanged: c.search,
            ),
            const SizedBox(height: AppSpace.md),
            Text(
              c.isLoading()
                  ? 'Loading documents…'
                  : '${rows.length} document${rows.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          itemCount: rows.length,
          empty: WorkspaceEmpty(
            icon: Icons.description_outlined,
            title: 'No documents found',
            message: types.isEmpty
                ? 'Document types are not available from config yet.'
                : 'Try another type or status filter, or refresh.',
            onRetry: c.refreshData,
          ),
          itemBuilder: (context, index) =>
              _DocumentCard(doc: rows[index], busy: busy),
        );
      });
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.doc, required this.busy});

  final PartnerDocumentModel doc;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SendDocumentPageCtrl>();
    final colors = Theme.of(context).colorScheme;
    final tx = doc.transaction;
    return CustomCardWidget(
      padding: AppSpace.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.type.isNotEmpty ? doc.type : 'Document',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (doc.name.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        doc.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              _StatusChip(status: doc.status),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Wrap(
            spacing: AppSpace.xl,
            runSpacing: AppSpace.md,
            children: [
              WorkspaceDetail(label: 'Investor', value: doc.investor.name),
              WorkspaceDetail(
                label: 'Mobile',
                value: doc.investor.mobileDisplay,
              ),
              WorkspaceDetail(label: 'Email', value: doc.investor.email),
              if (tx != null) ...[
                WorkspaceDetail(label: 'Company', value: tx.companyName),
                WorkspaceDetail(label: 'Invoice', value: tx.invoiceNo),
                if (tx.status.isNotEmpty)
                  WorkspaceDetail(label: 'Order status', value: tx.status),
              ],
            ],
          ),
          if (doc.hasOpenSignLink) ...[
            const SizedBox(height: AppSpace.md),
            Text(
              'Signature link is open',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                  ),
            ),
          ],
          const SizedBox(height: AppSpace.md),
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              OutlinedButton.icon(
                onPressed: busy ? null : () => c.download(doc),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download'),
              ),
              FilledButton.tonalIcon(
                onPressed: busy ? null : () => _pickChannel(context, doc),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Send'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickChannel(
    BuildContext context,
    PartnerDocumentModel doc,
  ) async {
    final channel = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Send document',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: const Text('Choose WhatsApp, email, or both'),
            ),
            for (final value in DocumentSendChannel.all)
              ListTile(
                leading: Icon(_channelIcon(value)),
                title: Text(DocumentSendChannel.label(value)),
                onTap: () => Navigator.of(context).pop(value),
              ),
            const SizedBox(height: AppSpace.sm),
          ],
        ),
      ),
    );
    if (channel == null || !context.mounted) return;
    await Get.find<SendDocumentPageCtrl>().send(doc, channel);
  }

  IconData _channelIcon(String channel) {
    switch (channel) {
      case DocumentSendChannel.whatsapp:
        return Icons.chat_rounded;
      case DocumentSendChannel.email:
        return Icons.email_outlined;
      case DocumentSendChannel.both:
        return Icons.alt_route_rounded;
      default:
        return Icons.send_rounded;
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final Color bg;
    final Color fg;
    switch (status) {
      case PartnerDocumentStatus.signed:
        bg = colors.primaryContainer;
        fg = colors.onPrimaryContainer;
        break;
      case PartnerDocumentStatus.expired:
        bg = colors.errorContainer;
        fg = colors.onErrorContainer;
        break;
      case PartnerDocumentStatus.pendingSignature:
        bg = colors.tertiaryContainer;
        fg = colors.onTertiaryContainer;
        break;
      default:
        bg = colors.surfaceContainerHighest;
        fg = colors.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.mdAll,
      ),
      child: Text(
        PartnerDocumentStatus.label(status),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
