import 'package:private_deals/src/features/account/presentation/profile_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class ProfilePhotoSection extends StatelessWidget {
  const ProfilePhotoSection({super.key, required this.controller});

  final ProfilePageCtrl controller;

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    // Obx must wrap the reads of Rx fields (not a parent that only constructs
    // this widget) — otherwise GetX throws and the Account card greys out.
    return Obx(() {
      final selected = controller.selectedLogo.value;
      final photo = controller.photoUrl.value;
      final editing = controller.editing.value;
      final saving = controller.saving.value;
      final picking = controller.picking.value;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: selected?.uint8list != null
                ? Image.memory(selected!.uint8list!, fit: BoxFit.cover)
                : photo.isNotEmpty
                ? Image.network(
                    photo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, error, stack) => Icon(
                      Icons.person_rounded,
                      size: 32,
                      color: scheme.onPrimaryContainer,
                    ),
                  )
                : Icon(
                    Icons.person_rounded,
                    size: 32,
                    color: scheme.onPrimaryContainer,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Display photo',
                  style: context.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Shown on your partner profile. Only the photo can be changed.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (!editing)
                  OutlinedButton.icon(
                    onPressed: saving ? null : controller.editPhoto,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit photo'),
                  )
                else ...[
                  const Text('Image only. Maximum 2 MB.'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed:
                            picking || saving ? null : controller.pickLogo,
                        child: Text(picking ? 'Selecting…' : 'Choose photo'),
                      ),
                      FilledButton(
                        onPressed: saving ||
                                picking ||
                                controller.selectedLogo.value == null
                            ? null
                            : controller.savePhoto,
                        child: Text(saving ? 'Saving…' : 'Save'),
                      ),
                      TextButton(
                        onPressed:
                            saving || picking ? null : controller.cancelPhoto,
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }
}
