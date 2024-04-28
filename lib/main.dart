import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'view/pages/splash_screen.dart';
export 'router/route/app_routes.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const ProviderScope(child: FarmersMarketplace()));
}

class FarmersMarketplace extends StatelessWidget {
  const FarmersMarketplace({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmers Marketplace',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        primaryColor: const Color(0xFF00A46C),
        useMaterial3: true,
        // fontFamily: 'Poppins',
        fontFamily: 'NotoSans',
        textTheme: TextTheme(
          bodyMedium: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.blueGrey),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
