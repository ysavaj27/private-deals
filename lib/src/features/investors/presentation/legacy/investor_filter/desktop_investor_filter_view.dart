import 'package:private_deals/src/features/investors/presentation/legacy/investors_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class DesktopInvestorFilterView extends StatelessWidget {
  final InvestorsPageCtrl c = Get.find<InvestorsPageCtrl>();

  DesktopInvestorFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 33),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TitleText("Filter"),
              IconButton(
                onPressed: Get.back,
                splashRadius: 25,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: context.theme.disabledColor.withValues(alpha: 0.2)),
          const SizedBox(height: 20),
          Text(
            'KYC Complete',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: context.theme.colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 9),
          CustomDropDown(
            label: "",
            value: c.pendingKYC(),
            items: FilterTypeEnum.values.map<DropdownMenuItem<FilterTypeEnum>>((
              FilterTypeEnum value,
            ) {
              return DropdownMenuItem<FilterTypeEnum>(
                value: value,
                child: Text(value.name.capitalFirst),
              );
            }).toList(),
            onChanged: (v) => c.pendingKYC(v),
          ),
          const SizedBox(height: 40),
          Text(
            'Active Investor',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: context.theme.colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 9),
          CustomDropDown(
            label: "",
            value: c.activeInvestor(),
            items: FilterTypeEnum.values.map<DropdownMenuItem<FilterTypeEnum>>((
              FilterTypeEnum value,
            ) {
              return DropdownMenuItem<FilterTypeEnum>(
                value: value,
                child: Text(value.name.capitalFirst),
              );
            }).toList(),
            onChanged: (v) => c.activeInvestor(v),
          ),
          Visibility(
            visible: c.relationManagerList.isNotEmpty,
            child: const SizedBox(height: 20),
          ),
          Visibility(
            visible: c.relationManagerList.isNotEmpty,
            child: Text(
              'Filter By Relation Manager',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: context.theme.colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 5.0,
            runSpacing: 5.0,
            children: c.relationManagerList.map((PartnerUser exercise) {
              return Obx(() {
                return FilterChip(
                  label: Text(exercise.name),
                  selected: c.selectedRelationMangerList.contains(exercise),
                  onSelected: (bool selected) {
                    if (selected) {
                      c.selectedRelationMangerList.add(exercise);
                    } else {
                      c.selectedRelationMangerList.remove(exercise);
                    }
                    c.selectedRelationMangerList.refresh();
                  },
                );
              });
            }).toList(),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: CustomOutlinedButton(onPressed: Get.back, text: "Close"),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomElevatedButton(
                  onPressed: () {
                    Get.back();
                    c.getInvestorList();
                  },
                  text: 'Filter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
