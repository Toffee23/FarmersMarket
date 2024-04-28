import 'dart:developer';

import 'package:farmers_marketplace/view/pages/auth_pages/reset_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controller.dart';
import '../../../core/api_handler/service.dart';
import '../../../core/constants/assets.dart';
import '../../../core/utils/validators.dart';
import '../../../router/route/app_routes.dart';
import '../../../utils.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/text_fields.dart';
import 'signup.dart';

final _isValidatedProvider = StateProvider.autoDispose<bool>((ref) => false);
final _isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class ForgotPassword extends ConsumerStatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends ConsumerState<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit(BuildContext context) async {
    ref.read(_isValidatedProvider.notifier).update((state) => true);
    if (!_formKey.currentState!.validate()) return;

    dismissKeyboard();

    // BLOCK USER INTERACTION
    ref.read(_isLoadingProvider.notifier).update((state) => true);

    final email = _emailController.text;
    final response = await apiService.forgotPassword(email);

    if (!mounted) return; // USER EXIT PAGE

    // UNBLOCK USER INTERACTION
    ref.read(_isLoadingProvider.notifier).update((state) => false);

    log(response.status.toString());

    switch (response.status) {
      case ResponseStatus.pending:
        return;
      case ResponseStatus.success:
        return _onSuccessful();
      case ResponseStatus.failed:
        return _onFailed(response.message!);
      case ResponseStatus.connectionError:
        return controller.onConnectionError(context);
      case ResponseStatus.unknownError:
        return controller.onUnknownError(context);
    }
  }

  void _onSuccessful() =>
      pushTo(context, ResetPasswordPage(_emailController.text));

  void _onFailed(String message) {
    late final String title;
    if (message == 'User not found') {
      title = 'Incorrect email';
      message = 'The specified email was not found on our database. '
          'Please confirm the email and try again';
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
    final isLoading = ref.watch(_isLoadingProvider);

    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: const CustomAppBar(
            actions: [],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20.0),
                Text(
                  'Forgot Password',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Please enter your email address',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Form(
                  key: _formKey,
                  child: CustomTextField(
                    labelText: 'Email',
                    hintText: 'Enter email address',
                    controller: _emailController,
                    validator: Validator.validateEmail,
                    isValidated: isValidated,
                    margin: const EdgeInsets.only(
                      top: 25.0,
                      bottom: 35.0,
                    ),
                  ),
                ),
                CustomButton(
                  onPressed: () => _onSubmit(context),
                  isLoading: isLoading,
                  text: 'Submit',
                ),
              ],
            ),
          ),
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
                  onPressed: () => pushReplacementTo(context, const Signup()),
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
    );
  }
}
