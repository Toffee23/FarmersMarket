import 'package:farmers_marketplace/controller.dart';
import 'package:farmers_marketplace/core/constants/assets.dart';
import 'package:farmers_marketplace/core/extensions/double.dart';
import 'package:farmers_marketplace/main.dart';
import 'package:farmers_marketplace/providers.dart';
import 'package:farmers_marketplace/view/widgets/app_bar.dart';
import 'package:farmers_marketplace/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_handler/service.dart';
import '../../models/models.dart';
import '../widgets/card.dart';
import '../widgets/snackbar.dart';
import 'checkout_page.dart';

class CartPage extends ConsumerWidget {
  const CartPage({Key? key}) : super(key: key);

  Future<void> onCartIncrement(
    BuildContext context,
    WidgetRef ref,
    Cart prod, [
    bool? increment,
  ]) async {
    final user = ref.read(userFutureProvider).value!;

    final count =
        increment == null ? 0 : prod.qty + (increment == true ? 1 : -1);

    ref.read(cartStateProvider.notifier).update((state) {
      final index = state!.indexWhere((p) => p == prod);
      state = <Cart>[
        ...state.sublist(0, index),
        if (count != 0) prod.copyWith(qty: count),
        ...state.sublist(index + 1),
      ];
      return state;
    });

    late final Response response;
    if (count == 0) {
      response = await apiService.deleteCartProduct(prod.prodId, user.id);
    } else if (count == 1) {
      response = await apiService.addCartProduct(user.id, prod.prodId, count);
    } else {
      final action = increment! ? 'plus' : 'minus';
      response =
          await apiService.updateCartProduct(prod.prodId, user.id, action);
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
  }

  void _onPressed(
    BuildContext context,
    WidgetRef ref,
    Cart cart,
    String heroTag,
  ) {
    final product = ref
        .read(productsStateProvider)!
        .singleWhere((p) => p.id == cart.prodId);
    controller.gotToProductDetailsPage(context, ref, product.id, heroTag);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carts = ref.watch(cartStateProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Cart',
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 15.0,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(.2),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Cart Summary',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Sub total',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.grey.shade100,
                    ),
                    child: Row(
                      children: <Widget>[
                        if (carts == null)
                          Image.asset(AppImages.loader, height: 22.0)
                        else if (carts.isEmpty)
                          Text(0.0.toPrice())
                        else
                          Text(
                            carts
                                .map((c) => c.price * c.qty)
                                .reduce((a, b) => a + b)
                                .toPrice(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  if (carts == null)
                    const Text('Loading')
                  else if (carts.isEmpty) ...[
                    const SizedBox(height: 60.0),
                    Image.asset(
                      AppImages.notification,
                      width: 200,
                    ),
                  ] else ...[
                    const SizedBox(height: 10.0),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(cartFutureProvider);
                          await Future.delayed(const Duration(seconds: 2));
                        },
                        child: ListView.separated(
                          itemCount: carts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 15.0),
                          itemBuilder: (BuildContext context, int index) {
                            final product = carts.elementAt(index);
                            final heroTag = '${product.image}-CartPage-$index';

                            return CartProductCard(
                              imageUrl: product.image,
                              name: product.name,
                              weight: product.weight,
                              unit: product.unit,
                              price: product.price,
                              qty: product.qty,
                              heroTag: heroTag,
                              onPressed: () =>
                                  _onPressed(context, ref, product, heroTag),
                              onDelete: () => onCartIncrement(
                                context,
                                ref,
                                product,
                              ),
                              onDecrement: () => onCartIncrement(
                                context,
                                ref,
                                product,
                                false,
                              ),
                              onIncrement: () => onCartIncrement(
                                context,
                                ref,
                                product,
                                true,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ],
              ),
            ),
            CustomButton(
              onPressed: carts == null || carts.isEmpty
                  ? null
                  : () => pushTo(context, const CheckoutPage()),
              text: 'Checkout',
              margin: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
