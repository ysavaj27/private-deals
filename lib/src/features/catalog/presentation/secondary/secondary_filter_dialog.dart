import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_landing_page_ctrl.dart';

class SecondaryFilterDialog extends StatelessWidget {
  final SecondaryLandingPageCtrl c = Get.find<SecondaryLandingPageCtrl>();

  SecondaryFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.isPhone ? EdgeInsets.all(15) : EdgeInsets.all(25),
      decoration: BoxDecoration(
        border: Border.all(color: context.theme.disabledColor.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(20),
        color: context.theme.scaffoldBackgroundColor,
      ),
      // constraints: BoxConstraints(
      //     maxWidth: context.width * 0.8, maxHeight: context.height * 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TitleText('Filter'),
              IconButton(
                splashRadius: 20,
                onPressed: Get.back,
                padding: EdgeInsets.zero,
                icon: Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 372,
            child: CustomLabelDropDown<int>(
              hintText: "Select sector",
              isRequired: false,
              value: c.currentSector().isNotEmpty ? c.currentSector() : null,
              label: 'Sector',
              items: c.sectorList
                  .map(
                    (e) => DropdownMenuItem<int>(
                      child: Text(e.name),
                      value: e.id,
                    ),
                  )
                  .toList(),
              onChanged: (int? e) {
                c.currentSector(e);
              },
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomOutlinedButton(
                width: context.isPhone ? 110 : 150,
                height: context.isPhone ? 40 : 50,
                onPressed: () {
                  c.currentSector(0);
                  // c.searchBySector();
                  Get.back();
                },
                text: 'Reset',
              ),
              SizedBox(width: 20),
              CustomElevatedButton(
                padding: EdgeInsets.zero,
                width: context.isPhone ? 110 : 150,
                height: context.isPhone ? 40 : 50,
                onPressed: () {
                  // c.searchBySector();
                  Get.back();
                },
                text: 'Apply',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
