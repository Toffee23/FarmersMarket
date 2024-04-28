import 'package:farmers_marketplace/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controller.dart';
import '../../../core/api_handler/service.dart';
import '../../../core/constants/assets.dart';
import '../../../core/utils/validators.dart';
import '../../../utils.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/text_fields.dart';
import 'login.dart';
import 'verify_page.dart';

final _isValidatedProvider = StateProvider.autoDispose<bool>((ref) => false);
final _isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final _obscureText1Provider = StateProvider.autoDispose<bool>((ref) => true);
final _obscureText2Provider = StateProvider.autoDispose<bool>((ref) => true);

class Signup extends ConsumerStatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  ConsumerState<Signup> createState() => _SignupState();
}

class _SignupState extends ConsumerState<Signup> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _password1Controller = TextEditingController();
  final _password2Controller = TextEditingController();

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _password1Controller.dispose();
    _password2Controller.dispose();
    super.dispose();
  }

  Future<void> _onCreateAccount(BuildContext context) async {
    ref.read(_isValidatedProvider.notifier).update((state) => true);
    if (!_formKey.currentState!.validate()) return;
    dismissKeyboard();

    // BLOCK USER INTERACTION
    ref.read(_isLoadingProvider.notifier).update((state) => true);

    final firstname = _firstnameController.text;
    final lastname = _lastnameController.text;
    final email = _emailController.text;
    final password = _password1Controller.text;
    final response =
        await apiService.signup(firstname, lastname, email, password);

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

  void _onSuccessful(Map<String, dynamic> data) {
    requestOTP(_emailController.text).then((value) {
      if (value) pushTo(context, VerifyPage(_emailController.text));
    });
  }

  void _onFailed(String message) {
    snackbar(
      context: context,
      title: 'Oops!!!',
      message: message,
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
      body: Stack(
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
                      const SizedBox(height: 10.0),
                      Text(
                        'Register',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Create a new account with us',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <CustomTextField>[
                            CustomTextField(
                              labelText: 'First Name',
                              controller: _firstnameController,
                              validator: Validator.validateName,
                              isValidated: isValidated,
                              margin: const EdgeInsets.only(
                                top: 25.0,
                                bottom: 20.0,
                              ),
                            ),
                            CustomTextField(
                              labelText: 'Last Name',
                              controller: _lastnameController,
                              validator: Validator.validateName,
                              isValidated: isValidated,
                            ),
                            CustomTextField(
                              labelText: 'Email',
                              controller: _emailController,
                              validator: Validator.validateEmail,
                              isValidated: isValidated,
                            ),
                            CustomTextField(
                              labelText: 'Password',
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
                              labelText: 'Confirm Password',
                              controller: _password2Controller,
                              isValidated: isValidated,
                              validator: (value) => Validator.validatePassword2(
                                  value, _password1Controller.text),
                              obscureText: obscureText2,
                              suffixIcon: IconButton(
                                onPressed: () => ref
                                    .read(_obscureText2Provider.notifier)
                                    .update((state) => !state),
                                icon: Icon(obscureText2
                                    ? CupertinoIcons.eye_slash_fill
                                    : CupertinoIcons.eye),
                              ),
                              margin: const EdgeInsets.only(
                                bottom: 35.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CustomButton(
                        onPressed: () => _onCreateAccount(context),
                        isLoading: isLoading,
                        text: 'Create account',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 42.0),
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
                  const Text('Already have account?'),
                  TextButton(
                    onPressed: () => pushReplacementTo(context, const Login()),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 4.0,
                      ),
                      minimumSize: Size.zero,
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
