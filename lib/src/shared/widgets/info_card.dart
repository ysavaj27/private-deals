import 'package:private_deals/src/shared/app_exports.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String data;

  InfoCard({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      width: 210,
      margin: EdgeInsets.only(right: 10),
      radius: 8,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            data,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
