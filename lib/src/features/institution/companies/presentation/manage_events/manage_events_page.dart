import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/companies/presentation/manage_events/manage_events_page_ctrl.dart';
import 'package:private_deals/src/features/institution/data/models/company/company_model.dart';
import 'package:private_deals/src/features/institution/support/plugins/loader.dart';
import 'package:private_deals/src/shared/institution_widgets/app_button.dart';
import 'package:private_deals/src/shared/institution_widgets/app_text_field.dart';
import 'package:private_deals/src/shared/institution_widgets/custom_card_widget.dart';
import 'package:private_deals/src/shared/plugins/download_file/download_file.dart';
import 'package:private_deals/src/shared/theme/app_tokens.dart';
import 'package:private_deals/src/shared/widgets/app_page_header.dart';

class CompanyEventsPage extends StatelessWidget {
  CompanyEventsPage({super.key});

  final CompanyEventsCtrl c = Get.put(CompanyEventsCtrl());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.loading.value) {
        return Scaffold(
          appBar: AppBar(title: const Text('Manage events')),
          body: const Loader(),
        );
      }

      if (c.loadError.value.isNotEmpty) {
        return Scaffold(
          appBar: AppBar(title: const Text('Manage events')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.loadError.value, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Retry',
                    onPressed: c.fetchCompanyAndEvents,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      final saving = c.saving.value;

      return PopScope(
        canPop: !saving,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Manage events'),
            automaticallyImplyLeading: !saving,
          ),
          body: AbsorbPointer(
            absorbing: saving,
            child: ListView(
              padding: AppPagePadding.of(context),
              children: [
                AppPageHeader(
                  title: c.companyName.value,
                  subtitle:
                      'Add updates and documents shown on the company detail page.',
                ),
                const SizedBox(height: AppSpace.xl),
                _EventEditor(c: c),
                const SizedBox(height: AppSpace.xl),
                Text('Published events', style: context.textTheme.titleMedium),
                const SizedBox(height: 12),
                if (c.events.isEmpty)
                  CustomCardWidget(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_note_outlined,
                          size: 40,
                          color: context.theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No events yet',
                          style: context.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Create the first event using the form above.',
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                else
                  ...c.events.map((event) => _EventCard(c: c, event: event)),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _EventEditor extends StatelessWidget {
  const _EventEditor({required this.c});

  final CompanyEventsCtrl c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final date = c.selectedDate.value;
      final file = c.pickedFile.value;
      final existingUrl = c.existingFileUrl.value;

      return CustomCardWidget(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: c.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      c.editorTitle,
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                  if (c.isEditing)
                    AppButton(
                      label: 'Cancel edit',
                      variant: AppButtonVariant.text,
                      onPressed: c.startCreate,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              AppTitleTextField(
                title: 'Title *',
                controller: c.titleCtrl,
                validator: c.validateTitle,
              ),
              const SizedBox(height: 16),
              AppTitleTextField(
                title: 'Description *',
                controller: c.descriptionCtrl,
                maxLines: 4,
                minLines: 3,
                validator: c.validateDescription,
              ),
              const SizedBox(height: 16),
              Text('Date *', style: context.textTheme.bodyMedium),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => c.pickDate(context),
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(
                  date == null
                      ? 'Select event date'
                      : c.formatDisplayDate(date),
                ),
              ),
              const SizedBox(height: 16),
              Text('Attachment', style: context.textTheme.bodyMedium),
              const SizedBox(height: 6),
              Text(
                'Optional PDF, PNG, JPG, JPEG, or XLSX. Leave empty on edit to keep the current file.',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppButton(
                    label: file == null ? 'Choose file' : 'Change file',
                    variant: AppButtonVariant.outline,
                    icon: Icons.upload_outlined,
                    onPressed: c.pickEventFile,
                  ),
                  if (file != null) ...[
                    Text(file.name, style: context.textTheme.bodySmall),
                    AppButton(
                      label: 'Clear',
                      variant: AppButtonVariant.text,
                      onPressed: c.clearPickedFile,
                    ),
                  ] else if (existingUrl.isNotEmpty)
                    AppButton(
                      label: 'Download current file',
                      variant: AppButtonVariant.text,
                      onPressed: () => DownloadFile.downloadFromUrl(
                        url: existingUrl,
                        fileName: c.titleCtrl.text.trim().isEmpty
                            ? 'event-file'
                            : c.titleCtrl.text.trim(),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  label: c.isEditing ? 'Update event' : 'Add event',
                  isLoading: c.saving.value,
                  onPressed: c.saveEvent,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.c, required this.event});

  final CompanyEventsCtrl c;
  final CompanyEventModel event;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCardWidget(
        padding: const EdgeInsets.all(16),
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
                      Text(event.title, style: context.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        c.formatDisplayDate(event.date),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit event',
                  onPressed: () => c.startEdit(event),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete event',
                  onPressed: () => c.deleteEvent(event),
                  icon: Icon(Icons.delete_outline, color: colors.error),
                ),
              ],
            ),
            if (event.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(event.description, style: context.textTheme.bodyMedium),
            ],
            if (event.downloadUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => DownloadFile.downloadFromUrl(
                  url: event.downloadUrl,
                  fileName: event.title,
                ),
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Download document'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
