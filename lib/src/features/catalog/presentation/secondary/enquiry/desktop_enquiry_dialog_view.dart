import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/secondary/enquiry/enquiry_dialog_ctrl.dart';

class DesktopEnquiryDialogView extends StatelessWidget {
  final String slug;

  late final EnquiryDialogCtrl c;

  DesktopEnquiryDialogView(this.slug, {super.key}) {
    c = Get.put(EnquiryDialogCtrl(slug: slug));
  }

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      width: 600,
      color: context.theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(40),
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
                child: Obx(() => _LabeledField(
                      label: "Quantity",
                      controller: c.quantityCtrl,
                      hint: "e.g. 100",
                      keyboardType: TextInputType.number,
                      errorText: c.quantityError.value.isEmpty
                          ? null
                          : c.quantityError.value,
                    )),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Obx(() => _LabeledField(
                      label: "Offer price",
                      controller: c.offerPriceCtrl,
                      hint: "e.g. 250.50",
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      errorText: c.offerPriceError.value.isEmpty
                          ? null
                          : c.offerPriceError.value,
                    )),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Offer valid till
          const Text("Offer valid till", style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Obx(() {
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: OfferValidTillOption.values.map((option) {
                final isCustomSelected =
                    option == OfferValidTillOption.custom &&
                        c.validTillOption.value == OfferValidTillOption.custom;
                final label = isCustomSelected &&
                        c.customValidTillDate.value != null
                    ? "${option.label}: ${_formatDate(c.customValidTillDate.value!)}"
                    : option.label;
                return _ChoiceTile(
                  label: label,
                  selected: c.validTillOption.value == option,
                  onTap: () => c.selectValidTillOption(option),
                );
              }).toList(),
            );
          }),
          Obx(() => c.validTillError.value.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    c.validTillError.value,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                )),

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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomOutlinedButton(
                onPressed: Get.back,
                width: 169,
                height: 49,
                text: "Close",
              ),
              const SizedBox(width: 50),
              Obx(() {
                return CustomElevatedButton(
                  onPressed: c.onPress,
                  isLoading: c.isLoading.value,
                  width: 169,
                  height: 49,
                  text: "Submit",
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
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

class _ChoiceTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Theme.of(context).primaryColor
                : AppColors.borderColor(context),
          ),
          color: selected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
              : null,
        ),
        child: Text(label, style: const TextStyle(fontSize: 13)),
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
