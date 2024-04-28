import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_handler/service.dart';
import '../../core/utils/validators.dart';
import '../../providers.dart';
import '../../utils.dart';
import '../widgets/app_bar.dart';
import '../widgets/buttons.dart';
import '../widgets/snackbar.dart';
import '../widgets/text_fields.dart';

final _isValidatedProvider = StateProvider.autoDispose<bool>((ref) => false);
final _isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final _hasChangedProvider = StateProvider.autoDispose<bool>((ref) => false);

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    final user = ref.read(userFutureProvider).value;
    _firstnameController.text = user?.firstname ?? '';
    _lastnameController.text = user?.lastname ?? '';
    _emailController.text = user?.email ?? '';

    _firstnameController.addListener(_hasChanged);
    _lastnameController.addListener(_hasChanged);
    _emailController.addListener(_hasChanged);
    super.initState();
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSave(BuildContext context) async {
    final user = ref.read(userFutureProvider).value;

    if (user == null) return;

    ref.read(_isValidatedProvider.notifier).update((state) => true);
    if (!_formKey.currentState!.validate()) return;

    dismissKeyboard();

    // BLOCK USER INTERACTION
    ref.read(_isLoadingProvider.notifier).update((state) => true);

    final firstname = _firstnameController.text;
    final lastname = _lastnameController.text;
    final email = _emailController.text;
    final response =
        await apiService.editProfile(user.id, firstname, lastname, email);

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
        return _onConnectionError();
      case ResponseStatus.unknownError:
        return _onUnknownError();
    }
  }

  void _onSuccessful() {
    ref.invalidate(userFutureProvider);
    ref.read(_hasChangedProvider.notifier).update((state) => false);

    snackbar(
      context: context,
      title: 'Successful',
      message: 'Your profile was updated successfully',
    );
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

  void _hasChanged() {
    final user = ref.read(userFutureProvider).value;

    if (user == null) return;

    ref.watch(_hasChangedProvider.notifier).update((state) =>
        _firstnameController.text.trim() != user.firstname ||
        _lastnameController.text.trim() != user.lastname ||
        _emailController.text.trim() != user.email);
  }

  @override
  Widget build(BuildContext context) {
    final isValidated = ref.watch(_isValidatedProvider);
    final isLoading = ref.watch(_isLoadingProvider);
    final hasChanged = ref.watch(_hasChangedProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Edit Profile',
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
                    labelText: 'First Name',
                    controller: _firstnameController,
                    validator: Validator.validateName,
                    isValidated: isValidated,
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
                    validator: Validator.validateName,
                    isValidated: isValidated,
                  ),
                ],
              ),
            ),
            CustomButton(
              onPressed: hasChanged ? () => _onSave(context) : null,
              isLoading: isLoading,
              text: 'Save changes',
              margin: const EdgeInsets.only(top: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}
