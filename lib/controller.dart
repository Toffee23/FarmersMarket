import 'dart:developer';

import 'package:farmers_marketplace/core/extensions/double.dart';
import 'package:farmers_marketplace/models/product.dart';
import 'package:farmers_marketplace/view/pages/auth_pages/welcome_page.dart';
import 'package:farmers_marketplace/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';

import 'core/api_handler/service.dart';
import 'core/constants/storage.dart';
import 'providers.dart';
import 'router/route/app_routes.dart';
import 'view/pages/details_page.dart';
import 'view/pages/navigation_pages/main_page.dart';
import 'view/widgets/dialogs.dart';

Future<void> onCartIncrement(
  BuildContext context,
  WidgetRef ref,
  Product prod, [
  bool? increment,
]) async {
  final user = ref.read(userFutureProvider).value;

  if (user == null) {
    controller.showMustLoginDialog(
      context,
      'Sorry, you need to be logged in before you can add products to cart.',
    );
    return;
  }

  final cart = ref.read(cartStateProvider);

  if (cart == null) {
    snackbar(
      context: context,
      title: 'Error',
      message: 'Couldn\'t update cart count, Please try again',
      contentType: ContentType.warning,
    );
    ref.invalidate(cartFutureProvider);
    return;
  }

  final count =
      increment == null ? 0 : prod.cartCount + (increment == true ? 1 : -1);

  ref.read(productsStateProvider.notifier).update((state) {
    final index = state!.indexWhere((p) => p.id == prod.id);
    state = <Product>[
      ...state.sublist(0, index),
      prod.copyWith(cartCount: count),
      ...state.sublist(index + 1),
    ];
    return state;
  });

  late final Response response;
  if (count == 0) {
    response = await apiService.deleteCartProduct(prod.id, user.id);
  } else if (count == 1) {
    response = await apiService.addCartProduct(user.id, prod.id, count);
  } else {
    final action = increment! ? 'plus' : 'minus';
    response = await apiService.updateCartProduct(prod.id, user.id, action);
  }

  if (response.status == ResponseStatus.success) {
    if (count == 0) {
      // ignore: use_build_context_synchronously
      snackbar(
        context: context,
        title: 'Successful',
        message: 'Product successfully remove from cart.',
      );
    } else if (count == 1) {
      // ignore: use_build_context_synchronously
      snackbar(
        context: context,
        title: 'Successful',
        message: 'Product successfully added to cart.',
      );
    }
  }
  ref.invalidate(cartFutureProvider);
}

Future<bool> requestOTP(String email, [bool resend = false]) async {
  final response = await apiService.sendOtp(email);

  switch (response.status) {
    case ResponseStatus.pending:
      return await requestOTP(email);
    case ResponseStatus.success:
      return true;
    case ResponseStatus.failed:
      return false;
    case ResponseStatus.connectionError:
      return false;
    case ResponseStatus.unknownError:
      return false;
  }
}

class Controller {
  final playStoreUrl = 'https://play.google.com/store/apps/details?id=';
  final packageName = 'com.reotech.farmers_marketplace';

  void onConnectionError(
    BuildContext context, {
    String? title,
    String? message,
    ContentType? contentType,
  }) {
    snackbar(
      context: context,
      title: title ?? 'Network error',
      contentType: ContentType.failure,
      message: message ??
          'A network connection problem interrupted the process. '
              'Please check your network and try again',
    );
  }

  void onUnknownError(
    BuildContext context, {
    String? title,
    String? message,
    ContentType? contentType,
  }) {
    snackbar(
      context: context,
      title: title ?? 'Unknown server error',
      contentType: contentType ?? ContentType.failure,
      message: message ??
          'An unknown server error occurred, please try again. '
              'If error persist, please report to the admin',
    );
  }

  void gotToProductDetailsPage(
    BuildContext context,
    WidgetRef ref,
    int prodId,
    String heroTag,
  ) {
    pushTo(context, DetailsPage(heroTag: heroTag, prodId: prodId));
  }

  void gotoHomePage(
    BuildContext context,
    WidgetRef ref, [
    bool guestUser = false,
  ]) {
    if (guestUser) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove(StorageKey.userId);
      });
      ref.read(isGuestUserProvider.notifier).update((_) => true);
    } else {
      ref.read(isGuestUserProvider.notifier).update((_) => false);
    }
    ref.invalidate(userFutureProvider);
    pushToAndClearStack(context, const NavigationPage());
  }

  void showMustLoginDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) {
        return ConfirmDialog(
          title: 'Oops!',
          body: message,
          actionLabel: 'Login now',
          iconData: Icons.login,
          onAction: () => pushToAndClearStack(context, const WelcomePage()),
        );
      },
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void shareProduct(Product product) {
    final content = 'Buy ${product.name} ${product.weight > 0 ? ' '
            '(${product.weight}${product.unit})' : ''} for just '
        '*${product.price.toPrice()}* on *Farmer Marketplace*\n'
        'Clink link below to download app now.\n\n'
        '$playStoreUrl$packageName';
    Share.share(content, subject: 'Share Product');
  }

  void shareApp() {
    Share.share('$playStoreUrl$packageName', subject: 'Share app');
  }

  void toggleLike(BuildContext context, WidgetRef ref, int prodId) {
    final user = ref.read(userFutureProvider).value;

    if (user == null) {
      controller.showMustLoginDialog(
        context,
        'Sorry, you need to be logged in before you can like a product.',
      );
      return;
    }

    ref.read(isLikedProvider(prodId).notifier).update((isLiked) {
      ref.read(likeCountProvider(prodId).notifier).update((count) {
        return count + (!isLiked ? 1 : -1);
      });
      return !isLiked;
    });

    apiService
        .like(prodId, user.id)
        .then((response) => _checkResponse(context, ref, response, prodId));
  }

  Future<void> _checkResponse(
    BuildContext context,
    WidgetRef ref,
    Response response,
    int prodId,
  ) async {
    if (response.status == ResponseStatus.success) {
      controller.showToast(response.message!);

      final prefs = await SharedPreferences.getInstance();
      const key = '${StorageKey.likedProduct}-${StorageKey.userId}';
      final likedProducts = prefs.getStringList(key) ?? [];

      if (ref.read(isLikedProvider(prodId))) {
        if (!likedProducts.contains(prodId.toString())) {
          likedProducts.add(prodId.toString());
        }
      } else if (likedProducts.contains(prodId.toString())) {
        likedProducts.remove(prodId.toString());
      }

      await prefs.setStringList(key, likedProducts);
      ref.invalidate(likedProductsFutureProvider);
      log(likedProducts.toString());
    } else {
      ref.read(isLikedProvider(prodId).notifier).update((isLiked) {
        ref.read(likeCountProvider(prodId).notifier).update((count) {
          return count + (!isLiked ? 1 : -1);
        });
        return !isLiked;
      });
      snackbar(
        context: context,
        title: 'Failed',
        message: response.message ?? 'Failed to perform request',
        contentType: ContentType.failure,
      );
    }
  }
}

final controller = Controller();
