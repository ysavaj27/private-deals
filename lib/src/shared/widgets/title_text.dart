import 'package:private_deals/src/shared/app_exports.dart';

class TitleText extends StatelessWidget {
  final String title;

  const TitleText(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.headlineSmall,
    );
  }
}
