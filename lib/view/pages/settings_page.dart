import 'package:farmers_marketplace/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller.dart';
import '../../core/api_handler/service.dart';
import '../../core/constants/storage.dart';
import '../../router/route.dart';
import '../widgets/app_bar.dart';
import '../widgets/dialogs.dart';
import '../widgets/list_tile.dart';
import '../widgets/snackbar.dart';
import 'auth_pages/welcome_page.dart';
import 'change_password_page.dart';

final _isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Future<void> _onDeleteAccount(BuildContext context, WidgetRef ref) async {
    final user = ref.read(userFutureProvider).value;

    if (user == null) {
      snackbar(
        context: context,
        title: 'Oops!!!',
        contentType: ContentType.warning,
        message: ''
            'Something went wrong. Please check you connection and try again.',
      );
      return;
    }
    // BLOCK USER INTERACTION
    ref.read(_isLoadingProvider.notifier).update((state) => true);

    apiService.delete(user.id).then((response) {
      ref.read(_isLoadingProvider.notifier).update((state) => false);
      switch (response.status) {
        case ResponseStatus.pending:
          return;
        case ResponseStatus.success:
          return _onSuccessful(context);
        case ResponseStatus.failed:
          return _onFailed(context, response.message!);
        case ResponseStatus.connectionError:
          return controller.onConnectionError(context);
        case ResponseStatus.unknownError:
          return controller.onUnknownError(context);
      }
    });
  }

  void _onSuccessful(BuildContext context) {
    SharedPreferences.getInstance().then((pref) {
      pref.remove(StorageKey.userId).then((_) {
        pushToAndClearStack(context, const WelcomePage());
      });
    });
  }

  void _onFailed(BuildContext context, String message) {
    snackbar(
      context: context,
      title: 'Something went wrong',
      message: message,
      contentType: ContentType.failure,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Settings',
      ),
      body: Column(
        children: <Widget>[
          // CustomListTile(
          //   onTap: () => _onResetPassword(context),
          //   leadingIconData: Icons.lock_reset_rounded,
          //   title: 'Reset Password',
          // ),
          CustomListTile(
            onTap: () => pushTo(context, const ChangePasswordPage()),
            leadingIconData: CupertinoIcons.lock,
            title: 'Change Password',
          ),
          CustomListTile(
            leadingIconData: CupertinoIcons.delete,
            leadingIconColor: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.error,
            title: 'Delete Account',
            onTap: () => showDialog(
              context: context,
              builder: (_) {
                return ConfirmDialog(
                  title: 'Delete Account',
                  body: 'This action cannot be undone',
                  actionLabel: 'Delete',
                  iconData: CupertinoIcons.delete,
                  actionColor: Colors.red,
                  actionButtonBackgroundColor: Colors.red,
                  onAction: () => _onDeleteAccount(context, ref),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
