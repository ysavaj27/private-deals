import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/secondary/enquiry/enquiry_dialog_ctrl.dart';
import 'package:private_deals/src/shared/widgets/settlement_days_dropdown.dart';

class DesktopEnquiryDialogView extends StatefulWidget {
  final String slug;

  const DesktopEnquiryDialogView(this.slug, {super.key});

  @override
  State<DesktopEnquiryDialogView> createState() => _EnquiryDialogState();
}

class _EnquiryDialogState extends State<DesktopEnquiryDialogView> {
  late final EnquiryDialogCtrl c = EnquiryDialogCtrl(slug: widget.slug);

  @override
  void dispose() {
    // Keep text controllers alive until the closing dialog has unmounted.
    c.onDelete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: CustomCardWidget(
        width: 600,
        color: context.theme.scaffoldBackgroundColor,
        padding: EdgeInsets.all(context.isPhone ? 20 : 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enquiry",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),

            // Enquiry type — buy / sell radio tiles
            const Text("Enquiry For", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: _RadioTile<InvestmentTypeEnum>(
                      label: InvestmentTypeEnum.buy.label,
                      value: InvestmentTypeEnum.buy,
                      groupValue: c.enquiryType.value,
                      onChanged: c.selectEnquiryType,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RadioTile<InvestmentTypeEnum>(
                      label: InvestmentTypeEnum.sell.label,
                      value: InvestmentTypeEnum.sell,
                      groupValue: c.enquiryType.value,
                      onChanged: c.selectEnquiryType,
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 24),

            // Quantity + Offer price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Obx(
                    () => _LabeledField(
                      label: "Quantity",
                      controller: c.quantityCtrl,
                      hint: "e.g. 100",
                      keyboardType: TextInputType.number,
                      errorText: c.quantityError.value.isEmpty
                          ? null
                          : c.quantityError.value,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Obx(
                    () => _LabeledField(
                      label: "Offer price",
                      controller: c.offerPriceCtrl,
                      hint: "e.g. 250.50",
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      errorText: c.offerPriceError.value.isEmpty
                          ? null
                          : c.offerPriceError.value,
                    ),
                  ),
                ),
              ],
            ),

            Obx(() {
              if (!c.requiresSettlement) return const SizedBox.shrink();
              final options = app.config.settlementDays;
              return Padding(
                padding: const EdgeInsets.only(top: 24),
                child: SettlementDaysDropdown(
                  key: ValueKey('enquiry-create-${c.settlementDays.value}'),
                  options: options,
                  value: c.settlementDays.value,
                  enabled: !c.isLoading.value && options.isNotEmpty,
                  labelText: 'Settlement cycle *',
                  errorText: c.settlementError.value.isEmpty
                      ? null
                      : c.settlementError.value,
                  onChanged: (value) {
                    c.settlementDays.value = value;
                    c.settlementError.value = '';
                  },
                ),
              );
            }),

            const SizedBox(height: 24),

            // Notes / remarks
            const Text("Notes", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: c.notesCtrl,
              maxLines: 2,
              maxLength: 2000,
              hintText: "Any remarks...",
            ),

            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 12,
              children: [
                CustomOutlinedButton(
                  onPressed: Get.back,
                  width: context.isPhone ? 110 : 169,
                  height: 49,
                  text: "Close",
                ),
                Obx(() {
                  return CustomElevatedButton(
                    onPressed: c.onPress,
                    isLoading: c.isLoading.value,
                    width: context.isPhone ? 110 : 169,
                    height: 49,
                    text: "Submit",
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioTile<T> extends StatelessWidget {
  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;

  const _RadioTile({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? Theme.of(context).primaryColor
                : AppColors.borderColor(context),
          ),
        ),
        child: Row(
          children: [
            Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: (v) => onChanged(v as T),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final String? errorText;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.keyboardType,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.bodyMedium),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          keyboardType: keyboardType,
          hintText: hint,
        ),
        if (errorText != null && errorText!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
