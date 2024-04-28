import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controller.dart';
import '../../core/constants/assets.dart';
import '../../providers.dart';
import '../widgets/app_bar.dart';
import '../widgets/card.dart';
import '../widgets/place_holders.dart';
import '../widgets/text_fields.dart';

final _searchProvider = StateProvider.autoDispose<String>((ref) => '');

class SearchPage extends ConsumerWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(_searchProvider);
    final products = ref.watch(productsStateProvider);
    final sorted = products?.where(
        (product) => product.name.toLowerCase().contains(search.toLowerCase()));

    return Scaffold(
      appBar: const CustomAppBar(title: 'Search'),
      body: Column(
        children: <Widget>[
          CustomSearchbar(
            margin: const EdgeInsets.all(15),
            prefixIcon: const Icon(
              CupertinoIcons.search,
              color: Colors.grey,
            ),
            hintText: 'Search...',
            autofocus: true,
            onChanged: (text) =>
                ref.read(_searchProvider.notifier).update((_) => text),
          ),
          if (sorted == null)
            const CustomLoadingWidget()
          else if (sorted.isEmpty)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 100.0),
                    Image.asset(
                      AppImages.search,
                      width: 200.0,
                    ),
                    Text(
                      'No result found',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 18.0),
                    )
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: sorted.length,
                padding: const EdgeInsets.all(15.0),
                separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                itemBuilder: (BuildContext context, int index) {
                  final product = sorted.elementAt(index);
                  final heroTag = '${product.image}-SearchPage-$index';
                  return SearchProductCard(
                    onPressed: () => controller.gotToProductDetailsPage(
                        context, ref, product.id, heroTag),
                    onShare: () => controller.shareProduct(product),
                    search: search,
                    imageUrl: product.image,
                    name: product.name,
                    heroTag: heroTag,
                    rating: product.rating,
                    price: product.price,
                    weight: product.weight,
                    unit: product.unit,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
