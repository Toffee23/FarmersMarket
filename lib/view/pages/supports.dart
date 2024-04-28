import 'package:farmers_marketplace/main.dart';
import 'package:farmers_marketplace/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/constants/assets.dart';
import '../widgets/app_bar.dart';
import '../widgets/buttons.dart';

class SupportsPage extends StatelessWidget {
  const SupportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Support',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image.asset(AppImages.support),
            const Text('Hello, how can we help you today?'),
            const SizedBox(height: 10),
            CardButton(
              onPressed: () => sendEmail(),
              icon: const Icon(Icons.mail),
              text: 'Send us a mail',
            ),
            CardButton(
              onPressed: () => pushTo(context, const SupportsPage()),
              icon: const Icon(CupertinoIcons.chat_bubble_2_fill),
              text: 'Chat with us',
            ),
            CardButton(
              onPressed: () => sendWhatsAppMessage(),
              icon: const Icon(Icons.wechat_rounded),
              text: 'Message us on Whatsapp',
            ),
          ],
        ),
      ),
    );
  }
}
