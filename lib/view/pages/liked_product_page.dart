import 'package:farmers_marketplace/core/constants/assets.dart';
import 'package:farmers_marketplace/view/pages/navigation_pages/main_page.dart';
import 'package:farmers_marketplace/view/widgets/place_holders.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controller.dart';
import '../../models/models.dart';
import '../../providers.dart';
import '../../router/route.dart';
import '../widgets/app_bar.dart';
import '../widgets/buttons.dart';
import '../widgets/card.dart';
import '../widgets/error_widget.dart';

class LikedProductPage extends ConsumerWidget {
  const LikedProductPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedProductsFuture = ref.watch(likedProductsFutureProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Saved products'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: likedProductsFuture.when(
          data: (likedProducts) {
            if (likedProducts == null) {
              return CustomErrorWidget(
                onRetry: () => ref.invalidate(addressesFutureProvider),
              );
            }
            if (likedProducts.isEmpty) {
              return Column(
                children: <Widget>[
                  const SizedBox(height: 40.0),
                  Image.asset(AppImages.product, width: 150.0),
                  const SizedBox(height: 10.0),
                  const Text('No favourite product'),
                  const SizedBox(height: 40.0),
                  CustomButton(
                    onPressed: () =>
                        pushToAndClearStack(context, const NavigationPage()),
                    text: 'Explore',
                    margin: EdgeInsets.zero,
                  ),
                ],
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(addressesFutureProvider);
                await Future.delayed(const Duration(seconds: 2));
              },
              child: ListView.separated(
                itemCount: likedProducts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 15.0),
                itemBuilder: (BuildContext context, int index) {
                  final product = likedProducts.elementAt(index);
                  final heroTag = '${product.image}-CartPage-$index';
                  return LikedProductCard(
                    product: product,
                    heroTag: heroTag,
                    onPressed: () => controller.gotToProductDetailsPage(
                        context, ref, product.id, heroTag),
                    onDislike: () =>
                        controller.toggleLike(context, ref, product.id),
                  );
                },
              ),
            );
          },
          error: (_, __) {
            return CustomErrorWidget(
              onRetry: () => ref.invalidate(addressesFutureProvider),
            );
          },
          loading: () => const CustomLoadingWidget(),
        ),
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  const AddressCard({
    Key? key,
    required this.address,
    this.isLoading = false,
    required this.onEdit,
    required this.onDelete,
    required this.onSetAsPrimary,
  }) : super(key: key);
  final Address address;
  final bool isLoading;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetAsPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        color: address.isPrimary
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.grey.shade200,
      ),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      address.fullName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontSize: 18.0),
                    ),
                    Text(
                      '${address.address}, ${address.city}, ${address.state}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.blueGrey.shade600),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: <Widget>[
                        Text(
                          address.phoneNumber,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (address.additionalPhoneNumber.isNotEmpty) ...[
                          Text(
                            ',',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            address.additionalPhoneNumber,
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        ],
                      ],
                    ),
                  ],
                ),
                if (address.isPrimary)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10.0,
                      right: 8.0 + 24.0,
                      bottom: 2.0,
                    ),
                    child: Text(
                      'Primary Address',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0, right: 24.0),
                    child: TextButton(
                      onPressed: isLoading ? null : onSetAsPrimary,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.amber,
                        backgroundColor: isLoading
                            ? Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(.4)
                            : null,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 4.0),
                        minimumSize: Size.zero,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          const Text('Set as primary address'),
                          if (isLoading)
                            SizedBox.square(
                              dimension: 16.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                backgroundColor: Colors.grey.shade100,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
          Positioned(
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                ),
                color: Theme.of(context).colorScheme.errorContainer,
              ),
              child: IconButton(
                onPressed: onDelete,
                tooltip: 'Delete address',
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                    ),
                  ),
                ),
                icon: Icon(
                  CupertinoIcons.delete,
                  size: 20.0,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0.0,
            bottom: 0.0,
            child: IconButton(
              onPressed: onEdit,
              tooltip: 'Edit address',
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.white70,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                  ),
                ),
              ),
              icon: Icon(
                Icons.edit,
                size: 20.0,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
