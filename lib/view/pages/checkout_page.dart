import 'package:farmers_marketplace/controller.dart';
import 'package:farmers_marketplace/core/constants/assets.dart';
import 'package:farmers_marketplace/core/extensions/double.dart';
import 'package:farmers_marketplace/main.dart';
import 'package:farmers_marketplace/view/pages/add_address_page.dart';
import 'package:farmers_marketplace/view/pages/addresses_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/flutterwave_keys.dart';
import '../../providers.dart';
import '../../utils.dart';
import '../widgets/app_bar.dart';
import '../widgets/buttons.dart';

import 'package:flutterwave_standard/flutterwave.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  void handlePaymentInitialization(BuildContext context, WidgetRef ref) async {
    final carts = ref.read(cartStateProvider)!;
    final shippingFee = ref.read(shippingFeeProvider).value;
    final primaryAddress = ref.read(primaryAddressProvider);

    if (primaryAddress == null) {
      ref.invalidate(userFutureProvider);
      return;
    }

    if (shippingFee == null) {
      ref.invalidate(userFutureProvider);
      return;
    }

    final amount = (carts.map((c) => c.price * c.qty).reduce((a, b) => a + b));

    final Customer customer = Customer(
      name: primaryAddress.fullName,
      phoneNumber: primaryAddress.phoneNumber,
      email: ref.read(userFutureProvider).value!.email,
    );

    final transactionReference = generateUniqueTransactionId();

    debugPrint(transactionReference);

    final Flutterwave flutterwave = Flutterwave(
      context: context,
      publicKey: FlutterWaveKeys.public,
      currency: "NGN",
      redirectUrl: "https://www.google.com",
      txRef: transactionReference,
      amount: (amount + shippingFee).toString(),
      customer: customer,
      paymentOptions: "ussd, card, barter, credit, banktransfer, account, nqr",
      customization: Customization(title: "My Payment"),
      isTestMode: kDebugMode,
      meta: {},
    );

    final az = await flutterwave.charge();

    debugPrint('Checkout Response $az');
    debugPrint('Checkout Response ${az.status}');
    controller.showToast(az.status ?? 'Failed');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carts = ref.watch(cartStateProvider)!;
    final addressesFuture = ref.watch(addressesFutureProvider);
    final shippingFee = ref.watch(shippingFeeProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Checkout',
        actions: <Widget>[],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Delivery address',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            addressesFuture.when(
              data: (addresses) {
                if (addresses == null || addresses.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 15.0),
                        const Icon(
                          Icons.cancel,
                          size: 32.0,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8.0),
                        const Text('No address'),
                        CustomButton(
                          onPressed: () =>
                              pushTo(context, const AddAddressPage()),
                          text: 'Add an address',
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          height: 38.0,
                          foregroundColor: Theme.of(context).primaryColor,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ],
                    ),
                  );
                }
                if (addresses.where((address) => address.isPrimary).isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 15.0),
                        const Icon(
                          Icons.cancel,
                          size: 32.0,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8.0),
                        const Text('No primary address set'),
                        CustomButton(
                          onPressed: () =>
                              pushTo(context, const AddressesPage()),
                          text: 'Choose a primary address',
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          height: 38.0,
                          foregroundColor: Theme.of(context).primaryColor,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ],
                    ),
                  );
                }
                final primaryAddress =
                    addresses.singleWhere((address) => address.isPrimary);
                return BoxContainer(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 15.0,
                  ),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              primaryAddress.fullName,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              '${primaryAddress.address}, '
                              '${primaryAddress.city}, '
                              '${primaryAddress.state}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 15.0),
                            Row(
                              children: <Widget>[
                                Text(
                                  primaryAddress.phoneNumber,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                if (primaryAddress
                                    .additionalPhoneNumber.isNotEmpty) ...[
                                  Text(
                                    ',',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    primaryAddress.additionalPhoneNumber,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  )
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        decoration: ShapeDecoration(
                          shape: const CircleBorder(),
                          color: Colors.grey.shade100,
                        ),
                        child: IconButton(
                          // onPressed: () => pushTo(
                          //     context, AddAddressPage(address: primaryAddress)),
                          onPressed: () =>
                              pushTo(context, const AddressesPage()),
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: Icon(
                            Icons.edit,
                            size: 20.0,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              error: (_, __) {
                return BoxContainer(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 20.0),
                      const Text('An error occurred, please try again.'),
                      CustomButton(
                        onPressed: () => ref.refresh(addressesFutureProvider),
                        text: 'Retry',
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        height: 38.0,
                        width: 100.0,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ],
                  ),
                );
              },
              loading: () {
                return BoxContainer(
                  child: Image.asset(
                    AppImages.loader,
                    height: 80.0,
                    width: double.infinity,
                  ),
                );
              },
            ),
            const SizedBox(height: 15.0),
            Text(
              'Order Items',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Expanded(
              child: BoxContainer(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: carts.length,
                  padding: const EdgeInsets.all(10.0),
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.grey.shade200),
                  itemBuilder: (BuildContext context, int index) {
                    final cart = carts.elementAt(index);

                    return Row(
                      children: <Widget>[
                        SizedBox.square(
                          dimension: 33.0,
                          child: DecoratedBox(
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: Colors.blue.withOpacity(.3),
                            ),
                            child: Center(
                                child: Text(
                              '${cart.qty}x',
                              style: Theme.of(context).textTheme.bodySmall,
                            )),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(child: Text(cart.name)),
                        const SizedBox(width: 8.0),
                        Text((cart.price * cart.qty).toPrice()),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            BoxContainer(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  CustomRow(
                    name: 'Subtotal',
                    value: carts
                        .map((c) => c.price * c.qty)
                        .reduce((a, b) => a + b)
                        .toPrice(),
                  ),
                  CustomRow(
                    name: 'Shipping fee',
                    value: shippingFee.value?.toPrice(),
                  ),
                  CustomRow(
                      name: 'Total',
                      value: shippingFee.value == null
                          ? null
                          : (carts
                                      .map((c) => c.price * c.qty)
                                      .reduce((a, b) => a + b) +
                                  shippingFee.value!)
                              .toPrice(),
                      valueColor: Theme.of(context).primaryColor),
                  Divider(
                    color: Colors.grey.shade300,
                    height: 8.0,
                  ),
                  const SizedBox(height: 8.0),
                  CustomButton(
                    onPressed: () => handlePaymentInitialization(context, ref),
                    text: 'Complete order',
                    margin: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BoxContainer extends StatelessWidget {
  const BoxContainer({
    Key? key,
    required this.child,
    this.width,
    this.margin,
    this.padding,
    this.color,
  }) : super(key: key);
  final Widget child;
  final double? width;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      padding: padding,
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(20.0),
      //   color: Colors.white,
      //   border: Border.all(
      //     color: Colors.grey.shade200,
      //     width: 1.2,
      //   ),
      //   boxShadow: <BoxShadow>[
      //     BoxShadow(
      //       color: Theme.of(context).primaryColor.withOpacity(.4),
      //       spreadRadius: -5.0,
      //       blurRadius: 10.0,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.2,
        ),
      ),
      child: child,
    );
  }
}

class CustomRow extends StatelessWidget {
  const CustomRow({
    Key? key,
    required this.name,
    this.value,
    this.valueColor,
  }) : super(key: key);
  final String name;
  final String? value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '$name :',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.blueGrey),
          ),
          if (value == null)
            SizedBox(
              height: 19.0,
              child: Image.asset(AppImages.loader),
            )
          else
            Text(
              value!,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: valueColor),
            ),
        ],
      ),
    );
  }
}
