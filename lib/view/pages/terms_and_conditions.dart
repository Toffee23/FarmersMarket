import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markup_text/markup_text.dart';

import '../../core/constants/assets.dart';
import '../widgets/app_bar.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Terms and conditions',
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FutureBuilder<String>(
              future: _termsAndConditions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return const Text('Error loading text file.');
                  }
                  return MarkupText(snapshot.data!);
                } else {
                  return const CircularProgressIndicator(); // or any loading indicator
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

Future<String> _termsAndConditions() async =>
    await rootBundle.loadString(AppData.termsAndConditions);
