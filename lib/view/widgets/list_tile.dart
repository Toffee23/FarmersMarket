import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    Key? key,
    this.onTap,
    this.leadingIconData,
    this.leadingIconColor,
    this.textColor,
    required this.title,
  }) : super(key: key);
  final VoidCallback? onTap;
  final IconData? leadingIconData;
  final Color? leadingIconColor;
  final Color? textColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: leadingIconData == null
          ? null
          : Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: (leadingIconColor ?? Theme.of(context).primaryColor)
                    .withOpacity(.08),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                leadingIconData!,
                color: leadingIconColor ?? Colors.grey.shade600,
                size: 20.0,
              ),
            ),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 6.0,
      ),
    );
  }
}
