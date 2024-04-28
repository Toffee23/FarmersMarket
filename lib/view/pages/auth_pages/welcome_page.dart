import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controller.dart';
import '../../../core/constants/assets.dart';
import '../../../router/route/app_routes.dart';
import '../terms_and_conditions.dart';
import '../../widgets/buttons.dart';
import 'login.dart';
import 'signup.dart';

final _isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  void _onSignup(BuildContext context) => pushTo(context, const Signup());

  void _onLogin(BuildContext context) => pushTo(context, const Login());

  void _onLoginAsGuest(BuildContext context, WidgetRef ref) {
    ref.read(_isLoadingProvider.notifier).update((_) => true);
    controller.gotoHomePage(context, ref, true);
  }

  void _onTermsAndCondition(BuildContext context) =>
      pushTo(context, const TermsAndConditions());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 100.0),
            Image.asset(AppImages.icon, width: 120.0),
            const SizedBox(height: 10.0),
            Text(
              'Welcome to Farmers Marketplace',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 15.0),
            const Text(
              'Discover the world of farm-to-fork goodness '
              'with our mobile app. From juicy fruits to '
              'organic vegetables, we\'re your go-to '
              'destination for quality farm produce.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25.0),
            CustomButton(
              onPressed: () => _onSignup(context),
              text: 'Signup',
            ),
            CustomButton(
              onPressed: () => _onLogin(context),
              type: CustomButtonType.outlined,
              text: 'Login',
              margin: const EdgeInsets.only(bottom: 8.0),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Consumer(builder: (context, WidgetRef ref, _) {
                return CustomButton(
                  onPressed: () => _onLoginAsGuest(context, ref),
                  text: 'Login as Guest',
                  icon: const Icon(Icons.arrow_forward, size: 16.0),
                  type: CustomButtonType.text,
                  isLoading: ref.watch(_isLoadingProvider),
                );
              }),
            ),
            const Spacer(),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'By using Farmers marketplace you agree to our ',
                style: Theme.of(context).textTheme.bodyMedium,
                children: <InlineSpan>[
                  TextSpan(
                    text: 'Terms and conditions',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _onTermsAndCondition(context),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
