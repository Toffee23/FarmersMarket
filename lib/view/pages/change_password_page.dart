import 'package:farmers_marketplace/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_handler/service.dart';
import '../../core/utils/validators.dart';
import '../../utils.dart';
import '../widgets/app_bar.dart';
import '../widgets/buttons.dart';
import '../widgets/snackbar.dart';
import '../widgets/text_fields.dart';

final _isValidatedProvider = StateProvider.autoDispose<bool>((ref) => false);
final _isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final _obscureText1Provider = StateProvider.autoDispose<bool>((ref) => true);
final _obscureText2Provider = StateProvider.autoDispose<bool>((ref) => true);
final _obscureText3Provider = StateProvider.autoDispose<bool>((ref) => true);

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _password1Controller = TextEditingController();
  final _password2Controller = TextEditingController();
  final _password3Controller = TextEditingController();

  @override
  void dispose() {
    _password1Controller.dispose();
    _password2Controller.dispose();
    _password3Controller.dispose();
    super.dispose();
  }

  Future<void> _onReset(BuildContext context) async {
    final user = ref.read(userFutureProvider).value;

    if (user == null) {
      snackbar(
        context: context,
        title: 'Oops!!!',
        contentType: ContentType.warning,
        message: 'Something went wrong. Please'
            'check you connection and try again.',
      );
      return;
    }

    ref.read(_isValidatedProvider.notifier).update((state) => true);
    if (!_formKey.currentState!.validate()) return;

    dismissKeyboard();

    // BLOCK USER INTERACTION
    ref.read(_isLoadingProvider.notifier).update((state) => true);

    final oldPassword = _password1Controller.text;
    final newPassword = _password2Controller.text;
    final response =
        await apiService.changePassword(user.id, oldPassword, newPassword);

    if (!mounted) return; // USER EXIT PAGE

    // UNBLOCK USER INTERACTION
    ref.read(_isLoadingProvider.notifier).update((state) => false);

    switch (response.status) {
      case ResponseStatus.pending:
        return;
      case ResponseStatus.success:
        return _onSuccessful(response.message!);
      case ResponseStatus.failed:
        return _onFailed(response.message!);
      case ResponseStatus.connectionError:
        return _onConnectionError();
      case ResponseStatus.unknownError:
        return _onUnknownError();
    }
  }

  void _onSuccessful(String message) {
    snackbar(
      context: context,
      title: 'Successful',
      message: message,
    );
  }

  void _onFailed(String message) {
    late final String title;
    if (message == 'Old password not correct' ||
        message == 'Old Password is not correct') {
      title = 'Wrong password!';
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

  void _onConnectionError() {
    const String message =
        'A network connection problem interrupted the process. '
        'Please check your network and try again';
    snackbar(
      context: context,
      title: 'Network error',
      message: message,
      contentType: ContentType.failure,
    );
  }

  void _onUnknownError() {
    const String message =
        'An unknown server error occurred, please try again. '
        'If error persist, please report to the admin';
    snackbar(
      context: context,
      title: 'Unknown server error',
      message: message,
      contentType: ContentType.failure,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isValidated = ref.watch(_isValidatedProvider);
    final obscureText1 = ref.watch(_obscureText1Provider);
    final obscureText2 = ref.watch(_obscureText2Provider);
    final obscureText3 = ref.watch(_obscureText3Provider);
    final isLoading = ref.watch(_isLoadingProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Change Password',
        actions: <Widget>[],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <CustomTextField>[
                  CustomTextField(
                    labelText: 'Old Password',
                    hintText: 'Enter old password',
                    controller: _password1Controller,
                    validator: Validator.validateLoginPassword,
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
                    labelText: 'New Password',
                    hintText: 'Enter new password',
                    controller: _password2Controller,
                    validator: Validator.validatePassword1,
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
                  CustomTextField(
                    labelText: 'Confirm new Password',
                    hintText: 'Re-enter new password',
                    controller: _password3Controller,
                    validator: (value) => Validator.validatePassword2(
                        value, _password2Controller.text),
                    isValidated: isValidated,
                    obscureText: obscureText3,
                    suffixIcon: IconButton(
                      onPressed: () => ref
                          .read(_obscureText3Provider.notifier)
                          .update((state) => !state),
                      icon: Icon(obscureText3
                          ? CupertinoIcons.eye_slash_fill
                          : CupertinoIcons.eye),
                    ),
                  ),
                ],
              ),
            ),
            CustomButton(
              onPressed: () => _onReset(context),
              isLoading: isLoading,
              text: 'Reset',
              margin: const EdgeInsets.only(top: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}
