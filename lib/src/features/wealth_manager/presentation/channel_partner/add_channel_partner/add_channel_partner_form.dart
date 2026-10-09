import 'package:private_deals/src/shared/app_exports.dart';

import 'add_channel_partner_dialog_ctrl.dart';

class AddChannelPartnerForm extends StatefulWidget {
  const AddChannelPartnerForm({super.key});

  @override
  State<AddChannelPartnerForm> createState() => _AddChannelPartnerFormState();
}

class _AddChannelPartnerFormState extends State<AddChannelPartnerForm> {
  final c = Get.find<AddChannelPartnerDialogCtrl>();
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;

  void _submit() {
    if (c.isLoading()) return;
    if (_formKey.currentState?.validate() ?? false) c.onPress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final types = app.config.enumValues.partnerType;
    final genders = app.config.enumValues.gender;
    return Obx(() {
      final saving = c.isLoading();
      return PopScope(
        canPop: !saving,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GROW YOUR NETWORK',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add channel partner',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Set up their profile, commission and product access.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ExcludeFocus(
                  excluding: saving,
                  child: AbsorbPointer(
                    absorbing: saving,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _section(
                            context,
                            '01',
                            'Partner details',
                            'Contact information for the new partner.',
                          ),
                          const SizedBox(height: 20),
                          _fields([
                            TitleTextField(
                              name: 'Full name',
                              hintText: 'Enter full name',
                              isRequired: true,
                              controller: c.nameCTRL,
                              textInputAction: TextInputAction.next,
                              validator: (v) => (v?.trim().length ?? 0) < 3
                                  ? 'Enter a name with at least 3 characters'
                                  : null,
                            ),
                            TitleTextField(
                              name: 'Mobile number',
                              hintText: '10-digit mobile number',
                              isRequired: true,
                              controller: c.mobileCTRL,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textInputAction: TextInputAction.next,
                              validator: (v) =>
                                  RegExp(r'^\d{10}$').hasMatch(v ?? '')
                                  ? null
                                  : 'Enter a valid 10-digit mobile number',
                            ),
                            TitleTextField(
                              name: 'Email address',
                              hintText: 'name@example.com',
                              isRequired: true,
                              controller: c.emailCTRL,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (v) =>
                                  GetUtils.isEmail((v ?? '').trim())
                                  ? null
                                  : 'Enter a valid email address',
                            ),
                            _PartnerDropdown(
                              label: 'Gender',
                              hintText: 'Select gender',
                              isRequired: true,
                              value: c.gender(),
                              items: [
                                for (final gender in [
                                  genders.male,
                                  genders.female,
                                  genders.other,
                                ])
                                  DropdownMenuItem(
                                    value: gender,
                                    child: Text(gender),
                                  ),
                              ],
                              onChanged: (v) => c.gender.value = v,
                              validator: (v) =>
                                  v == null ? 'Select gender' : null,
                            ),
                          ]),
                          const SizedBox(height: 28),
                          _section(
                            context,
                            '02',
                            'Partner setup',
                            'Choose a role and set the account credentials.',
                          ),
                          const SizedBox(height: 20),
                          _fields([
                            _PartnerDropdown(
                              label: 'Partner type',
                              hintText: 'Select partner type',
                              isRequired: true,
                              value: c.partnerType(),
                              items: [
                                for (final type in [
                                  types.relationManager,
                                  if (app.wUser.type == types.wealthmanager ||
                                      app.wUser.type == types.distributor)
                                    types.retailer,
                                  if (app.wUser.type == types.wealthmanager)
                                    types.distributor,
                                ])
                                  DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                              ],
                              onChanged: (v) => c.partnerType.value = v,
                              validator: (v) =>
                                  v == null ? 'Select partner type' : null,
                            ),
                            TitleTextField(
                              name: 'Password',
                              hintText: 'At least 6 characters',
                              isRequired: true,
                              controller: c.passwordCTRL,
                              obscureText: _hidePassword,
                              maxLines: 1,
                              suffixIcon: IconButton(
                                tooltip: _hidePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                onPressed: () => setState(
                                  () => _hidePassword = !_hidePassword,
                                ),
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                              validator: (v) => (v?.trim().length ?? 0) < 6
                                  ? 'Use at least 6 characters'
                                  : null,
                            ),
                            if (c.partnerType() != types.relationManager)
                              TitleTextField(
                                name: 'Commission (%)',
                                hintText: 'e.g. 2.5',
                                isRequired: true,
                                controller: c.commissionCTRL,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                                validator: (v) {
                                  final value = double.tryParse(v ?? '');
                                  return value == null ||
                                          !value.isFinite ||
                                          value < 0 ||
                                          value >= 100
                                      ? 'Enter a percentage from 0 to below 100'
                                      : null;
                                },
                              ),
                          ]),
                          if (c.partnerType() == types.relationManager) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Commission is not required for a relation manager.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 28),
                          _section(
                            context,
                            '03',
                            'Product access',
                            'Choose the products this partner can access.',
                          ),
                          const SizedBox(height: 16),
                          if (app.wUser.isPrimaryAccess)
                            _access(
                              context,
                              'Private Equity',
                              Icons.business_outlined,
                              c.isPrimary,
                            ),
                          if (app.wUser.isSecondaryAccess)
                            _access(
                              context,
                              'LP Secondary',
                              Icons.swap_horiz_rounded,
                              c.isSecondary,
                            ),
                          if (app.wUser.isPreIpoAccess)
                            _access(
                              context,
                              'Unlisted Shares',
                              Icons.candlestick_chart_outlined,
                              c.isPreIpo,
                            ),
                          if (!app.wUser.isPrimaryAccess &&
                              !app.wUser.isSecondaryAccess &&
                              !app.wUser.isPreIpoAccess)
                            Text(
                              'No products are available for your account.',
                              style: theme.textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: saving ? null : _submit,
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                semanticsLabel: 'Adding partner',
                              ),
                            )
                          : const Text('Add partner'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _fields(List<Widget> fields) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth < 600 ? 1 : 2;
      return Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          for (final field in fields)
            SizedBox(
              width: (constraints.maxWidth - 20 * (columns - 1)) / columns,
              child: field,
            ),
        ],
      );
    },
  );

  Widget _section(
    BuildContext context,
    String number,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            number,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _access(
    BuildContext context,
    String title,
    IconData icon,
    RxBool value,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: value()
            ? colors.primaryContainer.withValues(alpha: 0.4)
            : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: value()
                ? colors.primary.withValues(alpha: 0.5)
                : colors.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: CheckboxListTile(
          title: Text(title),
          secondary: Icon(icon, size: 22),
          value: value(),
          onChanged: (checked) => value(checked ?? false),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
        ),
      ),
    );
  }
}

class _PartnerDropdown extends StatelessWidget {
  const _PartnerDropdown({
    required this.label,
    required this.hintText,
    required this.isRequired,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.validator,
  });
  final String label, hintText;
  final bool isRequired;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text.rich(
        TextSpan(
          children: [
            TextSpan(text: label),
            if (isRequired)
              TextSpan(
                text: ' *',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
        style: TextStyle(
          fontSize: context.isPhone ? 14 : 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 9),
      DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        style: Theme.of(context).textTheme.bodyMedium,
        hint: Text(hintText, overflow: TextOverflow.ellipsis),
        items: items,
        onChanged: onChanged,
        validator: validator,
      ),
    ],
  );
}
