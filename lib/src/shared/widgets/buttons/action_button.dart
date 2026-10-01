import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final void Function()? onTap;

  const ActionButton({
    super.key,
    this.color = Colors.grey,
    this.icon = Icons.delete_outline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
