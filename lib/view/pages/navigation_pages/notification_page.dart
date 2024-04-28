import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/assets.dart';
import '../../widgets/app_bar.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({
    Key? key,
    this.leadingActionButton,
  }) : super(key: key);
  final VoidCallback? leadingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        leadingActionButton: leadingActionButton,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 72.0),
            Image.asset(AppImages.notification, width: 150.0),
            const SizedBox(height: 10.0),
            const Text('No addresses set'),
            const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }
}
