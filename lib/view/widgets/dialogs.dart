import 'package:flutter/material.dart';

import '../../router/route.dart';
import 'buttons.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.body,
    required this.actionLabel,
    this.cancelLabel = 'Cancel',
    this.iconData,
    this.actionColor,
    this.cancelButtonBackgroundColor,
    this.actionButtonBackgroundColor,
    this.onCancel,
    this.onAction,
  }) : super(key: key);
  final String title;
  final String body;
  final String actionLabel;
  final String cancelLabel;
  final IconData? iconData;
  final Color? actionColor;
  final Color? cancelButtonBackgroundColor;
  final Color? actionButtonBackgroundColor;
  final VoidCallback? onCancel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: <Widget>[
          if (iconData != null) ...[
            Icon(
              iconData,
              color: actionColor ?? Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8.0),
          ],
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(body),
          const SizedBox(height: 30.0),
          Row(
            children: <Widget>[
              Expanded(
                child: CustomButton(
                  onPressed: onCancel ?? () => pop(context),
                  text: cancelLabel,
                  height: 40.0,
                  backgroundColor:
                      cancelButtonBackgroundColor ?? Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    pop(context);
                    onAction?.call();
                  },
                  text: actionLabel,
                  height: 40.0,
                  backgroundColor: actionButtonBackgroundColor ??
                      Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
      titlePadding: const EdgeInsets.all(16.0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }
}
