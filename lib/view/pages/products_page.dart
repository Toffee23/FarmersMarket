import 'package:farmers_marketplace/core/constants/assets.dart';
import 'package:farmers_marketplace/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controller.dart';
import '../../models/categories.dart';
import '../../router/route/app_routes.dart';
import '../widgets/app_bar.dart';
import '../widgets/card.dart';
import '../widgets/text_fields.dart';
import 'search_page.dart';

class ProductPage extends ConsumerWidget {
  const ProductPage(this.category, {Key? key}) : super(key: key);
  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryProducts = ref.watch(categoryProductsProvider(category.id));
    final orientation = MediaQuery.of(context).orientation;
    final crossAxisCount = orientation == Orientation.landscape ? 4 : 2;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Products'),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomSearchbar(
                  onTap: () => pushTo(context, const SearchPage()),
                  canRequestFocus: false,
                  prefixIcon: const Icon(
                    CupertinoIcons.search,
                    color: Colors.grey,
                  ),
                  hintText: 'Search...',
                ),
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(categoryProductsProvider(category.id));
                await Future.delayed(const Duration(seconds: 2));
              },
              child: categoryProducts.isNotEmpty
                  ? GridView.builder(
                      itemCount: categoryProducts.length,
                      padding: const EdgeInsets.all(15.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12.0,
                        crossAxisSpacing: 12.0,
                        mainAxisExtent: 250,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final product = categoryProducts.elementAt(index);
                        final heroTag = '${product.image}-ProductsPage-$index';

                        return ProductCard(
                          onPressed: () => controller.gotToProductDetailsPage(
                              context, ref, product.id, heroTag),
                          onIncrement: () =>
                              onCartIncrement(context, ref, product, true),
                          onDecrement: () =>
                              onCartIncrement(context, ref, product, false),
                          onShare: () => controller.shareProduct(product),
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
                    )
                  : Column(
                      children: <Widget>[
                        Image.asset(
                          AppImages.product,
                          width: 220.0,
                        ),
                        Text(
                          'No product',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontSize: 18.0),
                        )
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
