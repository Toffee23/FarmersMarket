import 'dart:math';

import 'package:farmers_marketplace/main.dart';
import 'package:farmers_marketplace/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controller.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/card.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/place_holders.dart';
import '../../widgets/text_fields.dart';
import '../products_page.dart';
import '../search_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({
    Key? key,
    required this.tabOnTap,
  }) : super(key: key);
  final ValueChanged<int> tabOnTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userFuture = ref.watch(userFutureProvider);
    final isGuestUser = ref.watch(isGuestUserProvider);

    return userFuture.when(
      data: (user) {
        if (user == null && !isGuestUser) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 150.0),
            child: CustomErrorWidget(
              onRetry: () {
                ref.invalidate(userFutureProvider);
              },
            ),
          );
        }
        final categoriesFuture = ref.watch(categoriesFutureProvider);
        final topRatedProduct = ref.watch(topRatedProductsStateProvider);
        final latestProducts = ref.watch(latestProductsStateProvider);
        final orientation = MediaQuery.of(context).orientation;
        final crossAxisCount = orientation == Orientation.landscape ? 4 : 2;

        return Scaffold(
          appBar: CustomAppBar(
            leadingWidth: 0.0,
            toolbarHeight: 72.0,
            leading: const SizedBox.shrink(),
            titleWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Hi, ${user?.firstname ?? 'Guest'}',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.blueGrey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  'Get the best farm produce right to you doorstep',
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          body: Column(
            children: <Widget>[
              CustomSearchbar(
                onTap: () => pushTo(context, const SearchPage()),
                canRequestFocus: false,
                margin: const EdgeInsets.all(15),
                prefixIcon: const Icon(
                  CupertinoIcons.search,
                  color: Colors.grey,
                ),
                hintText: 'Search...',
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(productsFutureProvider);
                    await Future.delayed(const Duration(seconds: 2));
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15.0,
                            vertical: 5.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Categories',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              TextButton(
                                onPressed: () => tabOnTap(1),
                                style: TextButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 4.0,
                                  ),
                                  minimumSize: Size.zero,
                                ),
                                child: const Row(
                                  children: <Widget>[
                                    Text('See all'),
                                    Icon(Icons.arrow_right),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        categoriesFuture.when(
                          data: (categories) {
                            return GridView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 10.0,
                              ),
                              children: categories
                                  .sublist(0, min(4, categories.length))
                                  .map((category) {
                                return CategoryContainerButton(
                                  onPressed: () {
                                    ref
                                        .read(selectedCategory.notifier)
                                        .update((_) => category);
                                    pushTo(context, ProductPage(category));
                                  },
                                  image: category.image,
                                  text: category.name,
                                );
                              }).toList(),
                            );
                          },
                          error: (_, __) => const Text(
                              'An error occurred, please swipe to refresh'),
                          loading: () {
                            return const CategoryLoadingWidget(
                              padding: EdgeInsets.symmetric(horizontal: 15.0),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 15.0,
                            top: 30.0,
                            bottom: 5.0,
                          ),
                          child: Text(
                            'Top Rated Products',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (topRatedProduct == null)
                          const ProductGridLoading(
                            count: 2,
                          )
                        else
                          SizedBox(
                            height: 260.0,
                            child: ListView.separated(
                              itemCount: min(10, topRatedProduct.length),
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                                vertical: 6.0,
                              ),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 15.0),
                              itemBuilder: (BuildContext context, int index) {
                                final product =
                                    topRatedProduct.elementAt(index);
                                final heroTag =
                                    '${product.image}-HomePage(TopRated)-$index';

                                return ProductCard(
                                  width: 150,
                                  onPressed: () =>
                                      controller.gotToProductDetailsPage(
                                          context, ref, product.id, heroTag),
                                  onIncrement: () => onCartIncrement(
                                      context, ref, product, true),
                                  onDecrement: () => onCartIncrement(
                                      context, ref, product, false),
                                  onShare: () => controller
                                      .shareProduct(product),
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
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, top: 30.0, bottom: 5.0),
                          child: Text(
                            'Latest Products',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (latestProducts == null)
                          ProductGridLoading(
                            count: crossAxisCount,
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            itemCount: latestProducts.length,
                            physics: const NeverScrollableScrollPhysics(),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 12.0,
                              crossAxisSpacing: 12.0,
                              mainAxisExtent: 250.0,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              final product = latestProducts.elementAt(index);
                              final heroTag =
                                  '${product.image}-HomePage(Latest)-$index';

                              return ProductCard(
                                onPressed: () =>
                                    controller.gotToProductDetailsPage(
                                        context, ref, product.id, heroTag),
                                onIncrement: () => onCartIncrement(
                                    context, ref, product, true),
                                onDecrement: () => onCartIncrement(
                                    context, ref, product, false),
                                onShare: () => controller
                                    .shareProduct(product),
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
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      error: (_, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 150.0),
          child: CustomErrorWidget(
            onRetry: () {
              ref.invalidate(userFutureProvider);
            },
          ),
        );
      },
      loading: () {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 0.0,
          ),
          body: const Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    DataLoader(
                      width: 60.0,
                      height: 60.0,
                      radius: 30.0,
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          DataLoader(
                            width: 50.0,
                            height: 10.0,
                          ),
                          SizedBox(height: 10.0),
                          DataLoader(
                            height: 15.0,
                            margin: EdgeInsets.only(right: 50.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                DataLoader(
                  height: 120.0,
                  width: double.infinity,
                ),
                SizedBox(
                  height: 110,
                  child: CategoryLoadingWidget(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                  ),
                ),
                Expanded(
                  child: ProductGridLoading(
                    count: 4,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
