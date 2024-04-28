import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controller.dart';
import '../../../core/api_handler/service.dart';
import '../../../core/constants/assets.dart';
import '../../../core/constants/storage.dart';
import '../../../core/utils/validators.dart';
import '../../../models/user.dart';
import '../../../router/route/app_routes.dart';
import '../../../utils.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/text_fields.dart';
import '../navigation_pages/main_page.dart';
import 'forgot_password.dart';
import 'signup.dart';
import 'verify_page.dart';

final _isValidatedProvider = StateProvider.autoDispose<bool>((ref) => false);
final _isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final _obscureTextProvider = StateProvider.autoDispose<bool>((ref) => true);

class Login extends ConsumerStatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    ref.read(_isValidatedProvider.notifier).update((state) => true);

    if (kDebugMode) {
      if (_emailController.text.isEmpty) {
        _emailController.text = 'agboolaodunayo2016@gmail.com';
        // _emailController.text = 'larryani24@gmail.com';
      }
      if (_passwordController.text.isEmpty) {
        _passwordController.text = 'Azagpword!1';
        // _passwordController.text = 'pyrokinetics';
      }
    }
    if (!_formKey.currentState!.validate()) return;

    dismissKeyboard();

    // BLOCK USER INTERACTION
    ref.read(_isLoadingProvider.notifier).update((state) => true);

    final email = _emailController.text;
    final password = _passwordController.text;
    final response = await apiService.login(email, password);

    if (!mounted) return; // USER EXIT PAGE

    // UNBLOCK USER INTERACTION
    ref.read(_isLoadingProvider.notifier).update((state) => false);

    switch (response.status) {
      case ResponseStatus.pending:
        return;
      case ResponseStatus.success:
        return _onSuccessful(response.data!);
      case ResponseStatus.failed:
        return _onFailed(response.message!);
      case ResponseStatus.connectionError:
        return controller.onConnectionError(context);
      case ResponseStatus.unknownError:
        return controller.onUnknownError(context);
    }
  }

  Future<void> _onSuccessful(Map<String, dynamic> data) async {
    final user = User.fromJson(data);

    if (user.isVerified) {
      controller.gotoHomePage(context, ref);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(StorageKey.userId, user.id);
    } else {
      requestOTP(_emailController.text).then((value) {
        if (value) pushTo(context, VerifyPage(_emailController.text));
      });
    }
  }

  void _onFailed(String message) {
    late final String title;
    if (message == 'User not found' || message == 'Wrong password') {
      title = 'Incorrect credentials';
      message =
          'We could\'t log you in because of an incorrect email or password.';
    } else {
      title = 'Oops!!!';
      message = '$message. Please try again';
    }
    snackbar(
      context: context,
      title: title,
      message: message,
      contentType: ContentType.failure,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isValidated = ref.watch(_isValidatedProvider);
    final obscureText = ref.watch(_obscureTextProvider);
    final isLoading = ref.watch(_isLoadingProvider);

    return Scaffold(
      body: IgnorePointer(
        ignoring: isLoading,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                const CustomAppBar(
                  actions: [],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 20.0),
                        Text(
                          'Login',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Login to continue',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <CustomTextField>[
                              CustomTextField(
                                labelText: 'Email',
                                hintText: 'Enter email address',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: Validator.validateEmail,
                                isValidated: isValidated,
                                margin: const EdgeInsets.only(
                                  top: 25.0,
                                  bottom: 20.0,
                                ),
                              ),
                              CustomTextField(
                                labelText: 'Password',
                                hintText: 'Enter password',
                                controller: _passwordController,
                                validator: Validator.validateLoginPassword,
                                isValidated: isValidated,
                                margin: EdgeInsets.zero,
                                obscureText: obscureText,
                                suffixIcon: IconButton(
                                  onPressed: () => ref
                                      .read(_obscureTextProvider.notifier)
                                      .update((state) => !state),
                                  icon: Icon(obscureText
                                      ? CupertinoIcons.eye_slash_fill
                                      : CupertinoIcons.eye),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                pushTo(context, const ForgotPassword()),
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                            ),
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        CustomButton(
                          onPressed: _onLogin,
                          isLoading: isLoading,
                          text: 'Login',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 56,
              right: 0,
              child: Image.asset(
                AppImages.authGrapes,
                width: 72,
              ),
            ),
            Positioned(
              left: -5,
              bottom: -5,
              child: Image.asset(
                AppImages.authCorn,
                width: 72,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Don\'t have account?'),
                    TextButton(
                      onPressed: () =>
                          pushReplacementTo(context, const Signup()),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        minimumSize: Size.zero,
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text('Create one'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
