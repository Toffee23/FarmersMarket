import 'dart:convert';

import 'package:country_state_city/country_state_city.dart';
import 'package:farmers_marketplace/core/api_handler/service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/assets.dart';
import 'core/constants/storage.dart';
import 'models/models.dart';

final isGuestUserProvider = StateProvider<bool>((ref) => true);

final userFutureProvider = FutureProvider<User?>((ref) async {
  if (ref.read(isGuestUserProvider)) return null;
  return apiService.getUser();
});

final cartsProvider = StateProvider<List<Cart>>((ref) => []);

final cartFutureProvider = FutureProvider<List<Cart>>((ref) {
  final user = ref.watch(userFutureProvider).value;
  if (user == null) return List.empty();
  return apiService.cart(user.id);
});

final cartStateProvider = StateProvider<List<Cart>?>((ref) {
  return ref.watch(cartFutureProvider).value;
});

final categoriesFutureProvider =
    FutureProvider<List<Category>>((ref) => apiService.categoriesFuture());

final selectedCategory = StateProvider<Category?>((ref) => null);

final productsFutureProvider = FutureProvider<List<Product>>((ref) async {
  final user = ref.read(userFutureProvider).value;
  final products = await apiService.productsFuture(user?.id ?? -1);

  return products;
});

final productsStateProvider = StateProvider<List<Product>?>((ref) {
  return ref.watch(productsFutureProvider).value;
});

final productProvider = StateProvider.family<Product, int>((ref, prodId) {
  return ref.watch(productsStateProvider)!.singleWhere((p) => prodId == p.id);
});

final selectedProductProvider =
    StateProvider.family<Product, int>((ref, prodId) {
  return ref.watch(productsStateProvider)!.singleWhere((p) => prodId == p.id);
});

final productImagesProvider =
    FutureProvider.family<List<ProductImage>, int>((ref, prodId) {
  return apiService.productsImagesFuture(prodId);
});

final isLikedFutureProvider =
    FutureProvider.family<bool, int>((ref, prodId) async {
  final user = ref.read(userFutureProvider).value;

  if (user == null) return false;

  final response = await apiService.getProductLikeStatus(user.id, prodId);

  if (response.status == ResponseStatus.success) return response.data;

  return false;
});

final isLikedProvider = StateProvider.family<bool, int>((ref, prodId) {
  return ref.watch(isLikedFutureProvider(prodId)).value ?? false;
});

final likedProductsFutureProvider = FutureProvider<List<Product>?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  const key = '${StorageKey.likedProduct}-${StorageKey.userId}';
  final prodIds = prefs.getStringList(key) ?? [];
  final products = ref.watch(productsStateProvider);

  if (products == null) return null;

  List<Product> result = [];

  for (var prodId in prodIds) {
    final lst = products.where((p) => int.parse(prodId) == p.id);

    if (lst.isNotEmpty) {
      result.add(lst.first);
    }
  }
  return result;
});

final likeCountFutureProvider =
    FutureProvider.family<int, int>((ref, prodId) async {
  final response = await apiService.getProductLikeCount(prodId);

  if (response.status == ResponseStatus.success) return response.data;

  return 0;
});

final likeCountProvider = StateProvider.family<int, int>(
    (ref, prodId) => ref.watch(likeCountFutureProvider(prodId)).value ?? 0);

final topRatedProductsStateProvider = StateProvider<List<Product>?>((ref) {
  final products = ref.watch(productsStateProvider);

  if (products == null) return null;

  final sortedProducts = List.from(products).cast<Product>();
  sortedProducts.sort((p1, p2) => p2.rating.compareTo(p1.rating));

  return sortedProducts;
});

final latestProductsStateProvider = StateProvider<List<Product>?>((ref) {
  final products = ref.watch(productsStateProvider);

  if (products == null) return null;

  final sortedProducts = List.from(products).cast<Product>();
  sortedProducts.sort((p1, p2) => p2.updatedAt.compareTo(p1.updatedAt));

  return sortedProducts;
});

final categoryProductsProvider =
    StateProvider.family<List<Product>, int>((ref, catId) {
  final products = ref.watch(productsStateProvider) ?? [];

  return products.where((product) => product.categoryId == catId).toList();
});

final relatedProductsFutureProvider =
    FutureProvider<List<Product>>((ref) async {
  final user = ref.watch(userFutureProvider).value;

  final category = ref.watch(selectedCategory);
  final categories = ref.watch(categoriesFutureProvider).value ?? [];

  if (category == null && categories.isEmpty) {
    return List.empty();
  }
  final cat = category ?? categories.first;
  final response = await apiService.relatedProducts(cat.id, user?.id ?? -1);

  if (response.status == ResponseStatus.success) {
    return response.data
        .map<Product>((json) => Product.fromJson(json))
        .toList();
  }

  return [];
});

final allStatesFutureProvider =
    FutureProvider<List<State>>((ref) => getStatesOfCountry('NG'));

final allCitiesFutureProvider =
    FutureProvider<List<City>>((ref) => getCountryCities('NG'));

final citiesFutureProvider = FutureProvider<List<String>>((ref) async {
  final lagosCitiesFuture = await rootBundle.loadString(AppData.lagosCity);
  return jsonDecode(lagosCitiesFuture).cast<String>();
  // final citiesFuture = await getStateCities(state.countryCode, state.isoCode);
  // return citiesFuture.map((city) => city.name).toList();
});

final addressesFutureProvider = FutureProvider<List<Address>?>((ref) {
  final user = ref.watch(userFutureProvider).value;
  if (user == null) return null;
  return apiService.addressesFuture(user.id);
});

final primaryAddressProvider = StateProvider<Address?>((ref) {
  final addresses = ref.watch(addressesFutureProvider).value;
  final primaryAddress = addresses?.where((address) => address.isPrimary);

  if (primaryAddress != null && primaryAddress.isNotEmpty) {
    return primaryAddress.first;
  }
  return null;
});

final shippingFeeProvider = FutureProvider<double?>((ref) async {
  final primaryAddress = ref.watch(primaryAddressProvider);

  if (primaryAddress != null) {
    late final Response response;

    if (primaryAddress.state == 'Lagos') {
      response = await apiService.lagosCityShippingFee(primaryAddress.city);
    } else {
      response = await apiService.stateShippingFee(primaryAddress.state);
    }

    if (response.status == ResponseStatus.success) {
      return response.data.first['cost'].toDouble();
    }
  }
  return null;
});

final ordersFutureProvider = FutureProvider<List<Order>?>((ref) {
  final user = ref.watch(userFutureProvider).value;
  if (user == null) return null;
  return apiService.ordersFuture(user.id);
});
