import 'dart:math';
import 'package:farmers_marketplace/core/extensions/double.dart';
import 'package:farmers_marketplace/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controller.dart';
import '../../router/route.dart';
import '../widgets/buttons.dart';
import '../widgets/card.dart';
import '../widgets/place_holders.dart';
import 'checkout_page.dart';
import 'image_viewer_page.dart';

class DetailsPage extends ConsumerWidget {
  const DetailsPage({
    Key? key,
    required this.heroTag,
    required this.prodId,
  }) : super(key: key);
  final String heroTag;
  final int prodId;

  void _viewImage(BuildContext context, WidgetRef ref, int currentIndex) {
    final product = ref.read(selectedProductProvider(prodId));
    final productImages =
        ref.watch(productImagesProvider(prodId)).value?.map((e) => e.image);

    pushTo(
      context,
      ImageViewerPage(
        productName: product.name,
        imagesUrl: [product.image, ...productImages ?? []],
        initialIndex: currentIndex,
        heroTag: heroTag,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relatedProductsFuture = ref.watch(relatedProductsFutureProvider);
    final product = ref.watch(selectedProductProvider(prodId));
    final productImagesFuture = ref.watch(productImagesProvider(prodId));
    final isLiked = ref.watch(isLikedProvider(prodId));
    final likeCount = ref.watch(likeCountProvider(prodId));

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: MediaQuery.sizeOf(context).height * .35 + 40.0,
            child: MaterialButton(
              onPressed: () => _viewImage(context, ref, 0),
              padding: EdgeInsets.zero,
              child: Hero(
                tag: heroTag,
                child: ImageLoader(
                  imageUrl: product.image,
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.only(top: 15.0),
              height: MediaQuery.sizeOf(context).height * .65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(50),
                ),
                border: Border.all(
                  color: Colors.grey.shade100,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.grey.shade400,
                    spreadRadius: -5.0,
                    blurRadius: 10.0,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 35.0,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          '${product.name}'
                                          '${product.weight > 0 ? ' (${product.weight}${product.unit})' : ''}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!,
                                        ),
                                      ),
                                      ...List.generate(
                                        5,
                                        (index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(1.0),
                                            child: Icon(
                                              product.rating > index
                                                  ? CupertinoIcons.star_fill
                                                  : CupertinoIcons.star,
                                              size: 12.0,
                                              color: Colors.amber.shade700,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    product.price.toPrice(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Wrap(
                                    spacing: 10.0,
                                    runSpacing: 10.0,
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                          vertical: 4.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(.3),
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Text(
                                            '${product.quantity} item${product.quantity > 1 ? 's' : ''} in stock'),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                          vertical: 4.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(.3),
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Text(
                                          '$likeCount ${likeCount > 1 ? 'people' : 'person'}'
                                          ' liked this product',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(color: Colors.grey.shade300),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    'Description',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(product.description),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, top: 30.0, bottom: 5.0),
                              child: Text(
                                'Related Products',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            SizedBox(
                              height: 260.0,
                              child: relatedProductsFuture.when(
                                data: (products) {
                                  return ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: min(10, products.length),
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                      vertical: 6.0,
                                    ),
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 15.0),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final product = products.elementAt(index);
                                      final heroTag =
                                          '${product.image}-DetailsPage(Related)-$index';

                                      return ProductCard(
                                        width: 150,
                                        onPressed: () =>
                                            controller.gotToProductDetailsPage(
                                                context,
                                                ref,
                                                product.id,
                                                heroTag),
                                        onIncrement: () => onCartIncrement(
                                            context, ref, product, true),
                                        onDecrement: () => onCartIncrement(
                                            context, ref, product, false),
                                        onShare: () =>
                                            controller.shareProduct(product),
                                        heroTag: heroTag,
                                        image: product.image,
                                        name: product.name,
                                        price: product.price,
                                        rating: product.rating,
                                        count: product.cartCount,
                                        weight: product.weight,
                                        unit: product.unit,
                                      );
                                    },
                                  );
                                },
                                error: (_, __) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    width: double.infinity,
                                    margin: const EdgeInsets.all(15.0),
                                    child: Text(_.toString()),
                                  );
                                },
                                loading: () {
                                  return ListView.separated(
                                    itemCount: 5,
                                    scrollDirection: Axis.horizontal,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                      vertical: 6.0,
                                    ),
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 15.0),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return const ProductCardLoader();
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Theme.of(context).disabledColor,
                          spreadRadius: -5.0,
                          blurRadius: 10.0,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        if (product.cartCount > 0) ...[
                          IconButton(
                            onPressed: () =>
                                onCartIncrement(context, ref, product, false),
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(4.0),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: Icon(
                              CupertinoIcons.minus_circle,
                              color: Theme.of(context).primaryColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Text(product.cartCount.toString()),
                          const SizedBox(width: 10.0),
                          IconButton(
                            onPressed: () =>
                                onCartIncrement(context, ref, product, true),
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(4.0),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: Icon(
                              CupertinoIcons.plus_circle_fill,
                              color: Theme.of(context).primaryColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: CustomButton(
                              onPressed: () =>
                                  pushTo(context, const CheckoutPage()),
                              text: 'Checkout',
                              margin: EdgeInsets.zero,
                            ),
                          ),
                        ] else
                          Expanded(
                            child: CustomButton(
                              onPressed: () =>
                                  onCartIncrement(context, ref, product, true),
                              text: 'Add to cart',
                              margin: EdgeInsets.zero,
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20.0,
            bottom: MediaQuery.sizeOf(context).height * .65 - 25.0,
            child: LikeButton(
              isLiked: isLiked,
              onToggle: () => controller.toggleLike(context, ref, prodId),
            ),
          ),
          Positioned(
            right: 10.0,
            bottom: MediaQuery.sizeOf(context).height * .65 - 25.0,
            child: productImagesFuture.when(
              data: (images) {
                final imagesUrl = <String>[
                  product.image,
                  ...images.map((e) => e.image).toList()
                ].sublist(0, min(3, images.length + 1));
                final extra = images.length + 1 - imagesUrl.length;
                return Padding(
                  padding: const EdgeInsets.only(right: 25.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: imagesUrl
                          .asMap()
                          .entries
                          .map((entry) => Hero(
                                tag: '${entry.key}-${entry.value}-DetailsPage',
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  margin: const EdgeInsets.all(4.0),
                                  child: MaterialButton(
                                    onPressed: () =>
                                        _viewImage(context, ref, entry.key),
                                    color: Colors.grey.shade200,
                                    padding: EdgeInsets.zero,
                                    clipBehavior: Clip.hardEdge,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      fit: StackFit.expand,
                                      children: <Widget>[
                                        Center(
                                          child: ImageLoader(
                                            imageUrl: entry.value,
                                            decoration: const BoxDecoration(),
                                          ),
                                        ),
                                        if (entry.key == 2 && extra > 0)
                                          Container(
                                            color: Colors.black.withOpacity(.4),
                                            child: Center(
                                                child: Text(
                                              '+$extra',
                                              style: TextStyle(
                                                  color:
                                                      Colors.blueGrey.shade50,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.bold),
                                            )),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                              ))
                          .toList()),
                );
              },
              error: (_, __) {
                return Text('error $_');
              },
              loading: () {
                return Row(
                  children: List.generate(
                    3,
                    (index) {
                      return const DataLoader(
                        width: 44,
                        height: 44,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 15.0,
            top: 32.0,
            child: Container(
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: Colors.white70,
                shadows: <BoxShadow>[
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(.5),
                    spreadRadius: -5.0,
                    blurRadius: 10.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => pop(context),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                color: Theme.of(context).primaryColor,
                icon: const Icon(Icons.chevron_left),
              ),
            ),
          ),
          Positioned(
            right: 15.0,
            top: 32.0,
            child: Container(
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: Colors.white70,
                shadows: <BoxShadow>[
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(.5),
                    spreadRadius: -5.0,
                    blurRadius: 10.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => controller.shareProduct(product),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                color: Theme.of(context).primaryColor,
                icon: const Icon(Icons.share),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
