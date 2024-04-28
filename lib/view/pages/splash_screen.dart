import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller.dart';
import '../../core/constants/assets.dart';
import '../../core/constants/storage.dart';
import '../../router/route.dart';
import 'auth_pages/welcome_page.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    _navigateToNextPage();
    super.initState();
  }

  Future<void> _navigateToNextPage() async {
    final prefs = await SharedPreferences.getInstance();
    // await prefs.remove(StorageKey.userId);
    final int? userId = prefs.getInt(StorageKey.userId);

    Future.delayed(const Duration(seconds: 2)).then((_) {
      if (userId == null) {
        pushReplacementTo(context, const WelcomePage());
      } else {
        controller.gotoHomePage(context, ref);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.splashScreen),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
