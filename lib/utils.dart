import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

void dismissKeyboard() => FocusManager.instance.primaryFocus!.unfocus();

void sendEmail() async {
  // String encodeQueryParameters(Map<String, String> params) {
  //   return params.entries.map((MapEntry<String, String> e) {
  //     return '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}';
  //   }).join('&');
  // }

  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'hello@farmersmarketplace.ng',
    // query: encodeQueryParameters(<String, String>{
    //   'subject': '',
    //   'body': '',
    // }),
  );

  launchUrl(emailLaunchUri);
}

void sendWhatsAppMessage() async {
  const String number = '+234 902 813 5986';

  final msg = Uri.encodeComponent('');
  final whatsappUrl = Uri.parse("whatsapp://send?phone=$number&text=$msg");

  if (await canLaunchUrl(whatsappUrl)) {
    await launchUrl(whatsappUrl);
  } else {
    debugPrint('WhatsApp is not installed on this device.');
  }
}

String generateUniqueTransactionId() {
  final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final String uuid = const Uuid().v4().toString();
  return '$uuid-$timestamp';
}
