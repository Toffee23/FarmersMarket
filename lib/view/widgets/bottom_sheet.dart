import 'package:country_state_city/models/models.dart' as csc;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../router/route/app_routes.dart';
import 'text_fields.dart';

class CustomBottomSheet<T> extends StatelessWidget {
  CustomBottomSheet({
    Key? key,
    required this.title,
    this.items,
    this.selected,
    required this.onSelected,
    this.isLoading = true,
  }) : super(key: key);
  final String title;
  final List<T>? items;
  final T? selected;
  final ValueChanged<T> onSelected;
  final bool isLoading;

  final _isSelected = ValueNotifier<T?>(null);

  void _onSelected(T item) {
    onSelected(item);
    _isSelected.value = item;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              height: 6.0,
              width: 80.0,
              margin: const EdgeInsets.symmetric(vertical: 20.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontSize: 20.0),
          ),
          const SizedBox(height: 15.0),
          if (isLoading || items == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox.square(
                  dimension: 32.0,
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                shrinkWrap: true,
                itemCount: items!.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10.0),
                itemBuilder: (BuildContext context, int index) {
                  final item = items!.elementAt(index);
                  return ValueListenableBuilder<T?>(
                    valueListenable: _isSelected,
                    builder: (context, isSelected, _) {
                      return MaterialButton(
                        onPressed: () => _onSelected(item),
                        elevation: 0,
                        padding:
                            const EdgeInsets.only(left: 10, top: 2, bottom: 2),
                        color: (isSelected ?? selected) == item
                            ? Theme.of(context).primaryColor.withOpacity(.15)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              item.toString(),
                              style: TextStyle(
                                color: Colors.blueGrey.shade700,
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                            IgnorePointer(
                              child: Radio(
                                value: item,
                                groupValue: isSelected ?? selected,
                                onChanged: (_) {},
                                fillColor: MaterialStatePropertyAll(
                                  (isSelected ?? selected) == item
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade400,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

final _isSelectedStateProvider =
    StateProvider.autoDispose<csc.State?>((ref) => null);

final _isSelectedCityProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final _searchProvider = StateProvider.autoDispose<String>((ref) => '');

class StateBottomSheet extends ConsumerStatefulWidget {
  const StateBottomSheet({
    Key? key,
    this.selected,
    required this.onSelected,
  }) : super(key: key);
  final csc.State? selected;
  final ValueChanged<csc.State> onSelected;

  @override
  ConsumerState<StateBottomSheet> createState() => _StateBottomSheetState();
}

class _StateBottomSheetState extends ConsumerState<StateBottomSheet> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.addListener(() => ref
        .read(_searchProvider.notifier)
        .update((state) => _searchController.text));
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelected(BuildContext context, WidgetRef ref, csc.State state) {
    widget.onSelected(state);
    ref.read(_isSelectedStateProvider.notifier).update((_) => state);

    Future.delayed(const Duration(milliseconds: 500))
        .then((value) => pop(context));
  }

  @override
  Widget build(BuildContext context) {
    final statesFuture = ref.watch(allStatesFutureProvider);
    final isSelected = ref.watch(_isSelectedStateProvider);
    final search = ref.watch(_searchProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              height: 6.0,
              width: 80.0,
              margin: const EdgeInsets.symmetric(vertical: 20.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          Text(
            'Select State',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontSize: 20.0),
          ),
          CustomSearchbar(
            controller: _searchController,
            margin: const EdgeInsets.symmetric(vertical: 15.0),
            prefixIcon: const Icon(
              CupertinoIcons.search,
              color: Colors.grey,
            ),
            hintText: 'Search state',
            borderRadius: BorderRadius.circular(30.0),
          ),
          Expanded(
            child: statesFuture.when(
              data: (countries) {
                final sorted = countries.where((state) =>
                    state.name.toLowerCase().contains(search.toLowerCase()));
                if (sorted.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.0, bottom: 100.0),
                      child: Text('Nothing found'),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  shrinkWrap: true,
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10.0),
                  itemBuilder: (BuildContext context, int index) {
                    final state = sorted.elementAt(index);

                    return MaterialButton(
                      onPressed: () => _onSelected(context, ref, state),
                      elevation: 0,
                      padding: const EdgeInsets.only(
                          left: 15.0, top: 2.0, bottom: 2.0),
                      color: (isSelected ?? widget.selected) == state
                          ? Theme.of(context).primaryColor.withOpacity(.15)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              state.name,
                              style: TextStyle(
                                color: Colors.blueGrey.shade700,
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          IgnorePointer(
                            child: Radio(
                              value: state,
                              groupValue: isSelected ?? widget.selected,
                              onChanged: (_) {},
                              fillColor: MaterialStatePropertyAll(
                                (isSelected ?? widget.selected) == state
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade400,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
              error: (_, __) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('An error occurred. Please try again.'),
                      const SizedBox(height: 15.0),
                      Text(_.toString()),
                    ],
                  ),
                );
              },
              loading: () {
                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Center(
                    child: SizedBox.square(
                      dimension: 24.0,
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.grey.shade200,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CityBottomSheet extends ConsumerStatefulWidget {
  const CityBottomSheet({
    Key? key,
    this.selected,
    required this.onSelected,
    // required this.state,
  }) : super(key: key);
  final String? selected;
  final ValueChanged<String> onSelected;
  // final csc.State state;

  @override
  ConsumerState<CityBottomSheet> createState() => _CityBottomSheetState();
}

class _CityBottomSheetState extends ConsumerState<CityBottomSheet> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.addListener(() => ref
        .read(_searchProvider.notifier)
        .update((city) => _searchController.text));
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelected(BuildContext context, WidgetRef ref, String city) {
    widget.onSelected(city);
    ref.read(_isSelectedCityProvider.notifier).update((_) => city);

    Future.delayed(const Duration(milliseconds: 500))
        .then((value) => pop(context));
  }

  @override
  Widget build(BuildContext context) {
    final citiesFuture = ref.watch(citiesFutureProvider);
    final isSelected = ref.watch(_isSelectedCityProvider);
    final search = ref.watch(_searchProvider);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              height: 6.0,
              width: 80.0,
              margin: const EdgeInsets.symmetric(vertical: 20.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          Text(
            'Select City',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontSize: 20.0),
          ),
          CustomSearchbar(
            controller: _searchController,
            margin: const EdgeInsets.symmetric(vertical: 15.0),
            prefixIcon: const Icon(
              CupertinoIcons.search,
              color: Colors.grey,
            ),
            hintText: 'Search city',
            borderRadius: BorderRadius.circular(30.0),
          ),
          Expanded(
            child: citiesFuture.when(
              data: (cities) {
                final sorted = cities.where((city) =>
                    city.toLowerCase().contains(search.toLowerCase()));
                if (sorted.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.0, bottom: 100.0),
                      child: Text('Nothing found'),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  shrinkWrap: true,
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10.0),
                  itemBuilder: (BuildContext context, int index) {
                    final city = sorted.elementAt(index);

                    return MaterialButton(
                      onPressed: () => _onSelected(context, ref, city),
                      elevation: 0,
                      padding: const EdgeInsets.only(
                          left: 15.0, top: 2.0, bottom: 2.0),
                      color: (isSelected ?? widget.selected) == city
                          ? Theme.of(context).primaryColor.withOpacity(.15)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              city,
                              style: TextStyle(
                                color: Colors.blueGrey.shade700,
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          IgnorePointer(
                            child: Radio(
                              value: city,
                              groupValue: isSelected ?? widget.selected,
                              onChanged: (_) {},
                              fillColor: MaterialStatePropertyAll(
                                (isSelected ?? widget.selected) == city
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade400,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
              error: (_, __) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('An error occurred. Please try again.'),
                      const SizedBox(height: 15.0),
                      Text(_.toString()),
                    ],
                  ),
                );
              },
              loading: () {
                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Center(
                    child: SizedBox.square(
                      dimension: 24.0,
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.grey.shade200,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
