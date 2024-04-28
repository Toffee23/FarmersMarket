import 'package:farmers_marketplace/core/api_handler/service.dart';
import 'package:farmers_marketplace/core/constants/assets.dart';
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
import '../widgets/error_widget.dart';
import '../widgets/snackbar.dart';
import 'add_address_page.dart';

final _isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class AddressesPage extends ConsumerWidget {
  const AddressesPage({Key? key}) : super(key: key);

  Future<void> _onSetAsPrimary(
      BuildContext context, WidgetRef ref, Address address) async {
    final user = ref.read(userFutureProvider).value;
    if (user == null) return;

    ref.read(_isLoadingProvider.notifier).update((state) => true);
    final response = await apiService.setPrimaryAddress(address.id, user.id);
    ref.read(_isLoadingProvider.notifier).update((state) => false);

    switch (response.status) {
      case ResponseStatus.pending:
        return;
      case ResponseStatus.success:
        return _onSuccessful(ref);
      case ResponseStatus.failed:
        return _onFailed(response.message!, ref);
      case ResponseStatus.connectionError:
        // ignore: use_build_context_synchronously
        return controller.onConnectionError(context);
      case ResponseStatus.unknownError:
        // ignore: use_build_context_synchronously
        return controller.onUnknownError(context);
    }
  }

  Future<void> _onDelete(
      BuildContext context, WidgetRef ref, Address address) async {
    final user = ref.read(userFutureProvider).value;
    if (user == null) return;

    // ref.read(_isLoadingProvider.notifier).update((state) => true);
    final response = await apiService.deleteAddress(address.id);
    // ref.read(_isLoadingProvider.notifier).update((state) => false);

    switch (response.status) {
      case ResponseStatus.pending:
        return;
      case ResponseStatus.success:
        return _onSuccessful(ref);
      case ResponseStatus.failed:
        return _onFailed(response.message!, ref);
      case ResponseStatus.connectionError:
        // ignore: use_build_context_synchronously
        return controller.onConnectionError(context);
      case ResponseStatus.unknownError:
        // ignore: use_build_context_synchronously
        return controller.onUnknownError(context);
    }
  }

  void _onSuccessful(WidgetRef ref) {
    ref.invalidate(addressesFutureProvider);
  }

  void _onFailed(String message, WidgetRef ref) {
    snackbar(
      context: ref.context,
      title: 'Oops!!!',
      message: '$message. Please try again',
      contentType: ContentType.failure,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesFuture = ref.watch(addressesFutureProvider);
    final isLoading = ref.watch(_isLoadingProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Addresses'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: addressesFuture.when(
          data: (addresses) {
            if (addresses == null) {
              return CustomErrorWidget(
                onRetry: () => ref.invalidate(addressesFutureProvider),
              );
            }
            if (addresses.isEmpty) {
              return Column(
                children: <Widget>[
                  const SizedBox(height: 40.0),
                  Image.asset(AppImages.address, width: 150.0),
                  const SizedBox(height: 10.0),
                  const Text('No addresses set'),
                  const SizedBox(height: 40.0),
                  CustomButton(
                    onPressed: () => pushTo(context, const AddAddressPage()),
                    text: 'Add Address',
                    margin: EdgeInsets.zero,
                  ),
                ],
              );
            }
            return Column(
              children: <Widget>[
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(addressesFutureProvider);
                      await Future.delayed(const Duration(seconds: 2));
                    },
                    child: ListView.separated(
                      itemCount: addresses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 15.0),
                      itemBuilder: (BuildContext context, int index) {
                        final address = addresses.elementAt(index);
                        return AddressCard(
                          address: address,
                          isLoading: isLoading,
                          onDelete: () => _onDelete(context, ref, address),
                          onEdit: () =>
                              pushTo(context, AddAddressPage(address: address)),
                          onSetAsPrimary: () =>
                              _onSetAsPrimary(context, ref, address),
                        );
                      },
                    ),
                  ),
                ),
                CustomButton(
                  onPressed: () => pushTo(context, const AddAddressPage()),
                  text: 'Add New Address',
                  margin: const EdgeInsets.only(top: 10.0),
                ),
              ],
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
