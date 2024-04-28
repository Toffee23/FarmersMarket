import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controller.dart';
import '../../../core/api_handler/service.dart';
import '../../../core/constants/storage.dart';
import '../../../models/user.dart';
import '../../../router/route.dart';
import '../../../utils.dart';
import '../../widgets/snackbar.dart';
import '../navigation_pages/main_page.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/buttons.dart';

final _isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class VerifyPage extends ConsumerStatefulWidget {
  const VerifyPage(this.email, {Key? key}) : super(key: key);
  final String email;

  @override
  ConsumerState<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends ConsumerState<VerifyPage> {
  String _code = '';

  Future<void> _onVerify(BuildContext context, String code) async {
    if (code.length != 6) {
      snackbar(
        context: context,
        title: 'Incomplete code',
        message:
            'Please provide the code sent to your email to verify your account',
        contentType: ContentType.failure,
      );
      return;
    }

    dismissKeyboard();

    // BLOCK USER INTERACTION
    ref.read(_isLoadingProvider.notifier).update((state) => true);

    final response = await apiService.verifyOtp(widget.email, code);

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
        return _onConnectionError();
      case ResponseStatus.unknownError:
        return _onUnknownError();
    }

    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       title: const Text("Verification Code"),
    //       content: Text('Code entered is $code'),
    //     );
    //   },
    // );
  }

  Future<void> _onSuccessful(Map<String, dynamic> data) async {
    final user = User.fromJson(data);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageKey.userId, user.id);
    _navigateToPage();
  }

  void _navigateToPage() {
    controller.gotoHomePage(context, ref);
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
    final isLoading = ref.watch(_isLoadingProvider);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Verify your account',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Please enter the code we just sent to your email',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30.0),
            OtpTextField(
              numberOfFields: 6,
              focusedBorderColor: Theme.of(context).primaryColor,
              autoFocus: true,
              showFieldAsBox: true,
              handleControllers: (controllers) =>
                  _code = controllers.map((e) => e?.text).join(),
              onSubmit: (String code) => _onVerify(context, code),
              onCodeChanged: (String code) => _code = code,
            ),
            const SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Didn\'t get the code?'),
                TextButton(
                  onPressed: () => requestOTP(widget.email, true),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 4.0,
                    ),
                    minimumSize: Size.zero,
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text('Resend'),
                ),
              ],
            ),
            const SizedBox(height: 15.0),
            CustomButton(
              onPressed: () => _onVerify(context, _code),
              isLoading: isLoading,
              text: 'Submit',
            ),
          ],
        ),
      ),
    );
  }
}
