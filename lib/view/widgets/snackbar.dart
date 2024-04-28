import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

export 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

void snackbar({
  required BuildContext context,
  required String title,
  required String message,
  ContentType? contentType,
}) {
  final snackBar = SnackBar(
    /// need to set following properties for best effect of awesome_snackbar_content
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    margin: EdgeInsets.zero,
    content: AwesomeSnackbarContent(
      title: title,
      message: message,
      contentType: contentType ?? ContentType.success,
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
