import 'package:private_deals/src/shared/app_exports.dart';

class ActionMenuWidget extends StatelessWidget {
  final void Function()? onShare;
  final void Function()? onEdit;
  final void Function()? onDelete;
  final bool isShare;

  const ActionMenuWidget({
    super.key,
    this.onShare,
    this.onEdit,
    this.onDelete,
    this.isShare = true,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      splashRadius: 25,
      iconColor: Colors.black87,
      iconSize: 22,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      onSelected: (value) async {
        switch (value) {
          case ActionEnum.share:
            onShare?.call();
          case ActionEnum.edit:
            onEdit?.call();
          case ActionEnum.delete:
            onDelete?.call();
        }
      },
      itemBuilder: (context) {
        List<ActionEnum> list = [];
        if (isShare) {
          list.addAll(ActionEnum.values);
        } else {
          list.addAll(ActionEnum.values.where((e) => e != ActionEnum.share));
        }
        return list.map(
          (e) {
            return PopupMenuItem<ActionEnum>(
              value: e,
              child: Row(
                children: [
                  icon(e),
                  const SizedBox(width: 8),
                  Text(e.name.capitalizeFirst ?? ""),
                ],
              ),
            );
          },
        ).toList();
      },
    );
  }

  Icon icon(ActionEnum type) {
    switch (type) {
      case ActionEnum.share:
        return const Icon(Icons.share_outlined,
            size: 20, color: Colors.blueAccent);
      case ActionEnum.edit:
        return const Icon(Icons.edit_outlined, size: 20, color: Colors.green);
      case ActionEnum.delete:
        return const Icon(Icons.delete_outline, size: 20, color: Colors.red);
    }
  }
}
