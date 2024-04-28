import 'package:farmers_marketplace/core/extensions/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controller.dart';
import '../../../core/constants/storage.dart';
import '../../../providers.dart';
import '../../../router/route.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/list_tile.dart';
import '../../widgets/place_holders.dart';
import '../addresses_page.dart';
import '../auth_pages/welcome_page.dart';
import '../edit_profile.dart';
import '../liked_product_page.dart';
import '../orders_page.dart';
import '../settings_page.dart';
import '../supports.dart';
import '../terms_and_conditions.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({
    Key? key,
    this.leadingActionButton,
  }) : super(key: key);
  final VoidCallback? leadingActionButton;

  Future<void> _onLogout(BuildContext context) async {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(StorageKey.userId).then((value) {
        return pushToAndClearStack(context, const WelcomePage());
      });
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userFuture = ref.watch(userFutureProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        leadingActionButton: leadingActionButton,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(20.0),
                    child: MaterialButton(
                      elevation: 0,
                      onPressed: () => pushTo(context, const EditProfilePage()),
                      color: Theme.of(context).primaryColor.withOpacity(.2),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(height: 15.0),
                                userFuture.when(
                                  data: (user) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '${user!.firstname.title}'
                                          ' ${user.lastname.title}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          user.email,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        const SizedBox(height: 16.0),
                                        Row(
                                          children: <Widget>[
                                            const Text('Gender:'),
                                            const SizedBox(width: 4.0),
                                            Text(
                                              'Male',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                      ],
                                    );
                                  },
                                  error: (_, __) {
                                    return Text(
                                      'An error has occurred.\n$_',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                    );
                                  },
                                  loading: () {
                                    return const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        DataLoader(
                                          baseColor: Colors.white54,
                                          highlightColor: Colors.white,
                                          height: 12.0,
                                          width: 150.0,
                                          margin: EdgeInsets.only(bottom: 10.0),
                                        ),
                                        DataLoader(
                                          baseColor: Colors.white54,
                                          highlightColor: Colors.white,
                                          height: 15.0,
                                          margin: EdgeInsets.only(
                                              right: 30.0, bottom: 5.0),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: Colors.grey.shade100,
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              size: 20.0,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CustomListTile(
                    onTap: () => pushTo(context, const AddressesPage()),
                    leadingIconData: Icons.location_on_outlined,
                    title: 'My Addresses',
                  ),
                  CustomListTile(
                    onTap: () => pushTo(context, const OrdersPage()),
                    leadingIconData: CupertinoIcons.cart,
                    title: 'My Orders',
                  ),
                  CustomListTile(
                    onTap: () => pushTo(context, const LikedProductPage()),
                    leadingIconData: CupertinoIcons.cart,
                    title: 'My Favorites',
                  ),
                  CustomListTile(
                    onTap: () => pushTo(context, const SupportsPage()),
                    leadingIconData: Icons.support_agent_rounded,
                    title: 'Support',
                  ),
                  CustomListTile(
                    onTap: () => pushTo(context, const SettingsPage()),
                    leadingIconData: CupertinoIcons.gear,
                    title: 'Settings',
                  ),
                  CustomListTile(
                    onTap: () => pushTo(context, const TermsAndConditions()),
                    leadingIconData: CupertinoIcons.question_circle,
                    title: 'Terms and conditions',
                  ),
                  CustomListTile(
                    onTap: () => controller.shareApp(),
                    leadingIconData: CupertinoIcons.question_circle,
                    title: 'Share this app',
                  ),
                ],
              ),
            ),
          ),
          CustomListTile(
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return ConfirmDialog(
                  title: 'Logout',
                  body: 'You sure you want to logout of your account?',
                  actionLabel: 'Logout',
                  iconData: Icons.logout,
                  actionColor: Colors.red,
                  actionButtonBackgroundColor: Colors.red,
                  onAction: () => _onLogout(context),
                );
              },
            ),
            leadingIconData: Icons.logout_rounded,
            title: 'Logout',
          ),
        ],
      ),
    );
  }
}
