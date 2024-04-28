import 'package:flutter/cupertino.dart';
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
import 'login.dart';
import 'signup.dart';

final _isValidatedProvider = StateProvider.autoDispose<bool>((ref) => false);
final _isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final _obscureText1Provider = StateProvider.autoDispose<bool>((ref) => true);
final _obscureText2Provider = StateProvider.autoDispose<bool>((ref) => true);

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage(
    this.email, {
    Key? key,
  }) : super(key: key);
  final String email;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _password1Controller = TextEditingController();
  final _password2Controller = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    _password1Controller.dispose();
    _password2Controller.dispose();
    super.dispose();
  }

  Future<void> _onReset() async {
    ref.read(_isValidatedProvider.notifier).update((state) => true);

    if (!_formKey.currentState!.validate()) return;

    dismissKeyboard();

    // BLOCK USER INTERACTION
    ref.read(_isLoadingProvider.notifier).update((state) => true);

    final otp = _otpController.text;
    final password = _password1Controller.text;
    final response = await apiService.confirmReset(widget.email, otp, password);

    if (!mounted) return; // USER EXIT PAGE

    // UNBLOCK USER INTERACTION
    ref.read(_isLoadingProvider.notifier).update((state) => false);

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

  Future<void> _onSuccessful() async {
    pushReplacementTo(context, const Login());
    snackbar(
      context: context,
      title: 'Successful',
      message: 'Your password has been reset successfully.',
    );
  }

  void _onFailed(String message) {
    snackbar(
      context: context,
      title: message,
      message: 'Please check you email and provide the correct code.',
      contentType: ContentType.failure,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isValidated = ref.watch(_isValidatedProvider);
    final obscureText1 = ref.watch(_obscureText1Provider);
    final obscureText2 = ref.watch(_obscureText2Provider);
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
                          'Reset Password',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Please enter the OTP sent to your email and set a new password.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <CustomTextField>[
                              CustomTextField(
                                labelText: 'OTP Code',
                                hintText: 'Enter otp code',
                                controller: _otpController,
                                keyboardType: TextInputType.number,
                                validator: Validator.otpCode,
                                isValidated: isValidated,
                                margin: const EdgeInsets.only(
                                  top: 25.0,
                                  bottom: 20.0,
                                ),
                              ),
                              CustomTextField(
                                labelText: 'New Password',
                                hintText: 'Enter new password',
                                controller: _password1Controller,
                                validator: Validator.validatePassword1,
                                isValidated: isValidated,
                                obscureText: obscureText1,
                                suffixIcon: IconButton(
                                  onPressed: () => ref
                                      .read(_obscureText1Provider.notifier)
                                      .update((state) => !state),
                                  icon: Icon(obscureText1
                                      ? CupertinoIcons.eye_slash_fill
                                      : CupertinoIcons.eye),
                                ),
                              ),
                              CustomTextField(
                                labelText: 'Confirm new Password',
                                hintText: 'Re-enter new password',
                                controller: _password2Controller,
                                validator: (value) =>
                                    Validator.validatePassword2(
                                        value, _password1Controller.text),
                                isValidated: isValidated,
                                obscureText: obscureText2,
                                suffixIcon: IconButton(
                                  onPressed: () => ref
                                      .read(_obscureText2Provider.notifier)
                                      .update((state) => !state),
                                  icon: Icon(obscureText2
                                      ? CupertinoIcons.eye_slash_fill
                                      : CupertinoIcons.eye),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        CustomButton(
                          onPressed: _onReset,
                          isLoading: isLoading,
                          text: 'Reset',
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
