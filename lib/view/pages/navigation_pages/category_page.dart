import 'package:farmers_marketplace/providers.dart';
import 'package:farmers_marketplace/view/widgets/place_holders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../router/route.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/error_widget.dart';
import '../products_page.dart';

class CategoryPage extends ConsumerWidget {
  const CategoryPage({
    Key? key,
    this.leadingActionButton,
  }) : super(key: key);
  final VoidCallback? leadingActionButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesFuture = ref.watch(categoriesFutureProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Categories',
        leadingActionButton: leadingActionButton,
      ),
      body: categoriesFuture.when(
        data: (categories) {
          return GridView.builder(
            itemCount: categories.length,
            padding: const EdgeInsets.all(15.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              final category = categories.elementAt(index);
              return CategoryContainerButton(
                onPressed: () {
                  ref.read(selectedCategory.notifier).update((_) => category);
                  pushTo(context, ProductPage(category));
                },
                image: category.image,
                text: category.name,
                textStyle: const TextStyle(),
              );
            },
          );
        },
        error: (_, __) {
          return CustomErrorWidget(
            onRetry: () {
              ref.invalidate(categoriesFutureProvider);
            },
          );
        },
        loading: () => const ProductGridLoading(count: 6),
      ),
    );
  }
}
