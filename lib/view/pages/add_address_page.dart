import 'package:farmers_marketplace/providers.dart';
import 'package:farmers_marketplace/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_state_city/models/models.dart' as csc;

import '../../controller.dart';
import '../../core/api_handler/service.dart';
import '../../core/utils/validators.dart';
import '../../models/models.dart';
import '../../router/route.dart';
import '../../utils.dart';
import '../widgets/app_bar.dart';
import '../widgets/bottom_sheet.dart';
import '../widgets/buttons.dart';
import '../widgets/text_fields.dart';

final _isValidatedProvider = StateProvider.autoDispose<bool>((ref) => false);
final _isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final _stateProvider = StateProvider.autoDispose<csc.State?>((ref) => null);
final _cityProvider = StateProvider.autoDispose<String?>((ref) => null);
final _stateErrorProvider = StateProvider.autoDispose<bool>((ref) => false);
final _cityErrorProvider = StateProvider.autoDispose<bool>((ref) => false);
final _hasChangedProvider = StateProvider.autoDispose<bool>((ref) => false);

class AddAddressPage extends ConsumerStatefulWidget {
  const AddAddressPage({
    Key? key,
    this.address,
  }) : super(key: key);
  final Address? address;

  @override
  ConsumerState<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends ConsumerState<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _phoneNumberOptController = TextEditingController();

  @override
  void initState() {
    if (widget.address != null) {
      WidgetsBinding.instance.addPostFrameCallback(_loadFieldsValue);
      _fullNameController.addListener(_trackFieldChanges);
      _addressController.addListener(_trackFieldChanges);
      _phoneNumberController.addListener(_trackFieldChanges);
      _phoneNumberOptController.addListener(_trackFieldChanges);
    }
    super.initState();
  }

  Future<void> _loadFieldsValue(_) async {
    _fullNameController.text = widget.address!.fullName;
    _addressController.text = widget.address!.address;
    _phoneNumberController.text = widget.address!.phoneNumber;
    _phoneNumberOptController.text = widget.address!.additionalPhoneNumber;

    ref.read(allStatesFutureProvider.future).then((states) {
      final state = states.singleWhere((s) => s.name == widget.address!.state);
      ref.read(_stateProvider.notifier).state = state;
    });
    ref.read(allCitiesFutureProvider.future).then((cities) {
      ref.read(_cityProvider.notifier).state = widget.address!.city;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _phoneNumberOptController.dispose();
    super.dispose();
  }

  Future<void> _onSave(BuildContext context) async {
    ref.read(_isValidatedProvider.notifier).update((state) => true);

    // if (ref.read(_stateProvider) == null) {
    //   ref.read(_stateErrorProvider.notifier).update((_) => true);
    // }
    if (ref.read(_cityProvider) == null) {
      ref.read(_cityErrorProvider.notifier).update((_) => true);
    }
    if (!_formKey.currentState!.validate() ||
        ref.read(_stateErrorProvider) ||
        ref.read(_cityErrorProvider)) {
      return;
    }

    dismissKeyboard();

    ref.read(_stateErrorProvider.notifier).update((_) => false);
    ref.read(_cityErrorProvider.notifier).update((_) => false);

    final user = ref.read(userFutureProvider).value;

    if (user == null) {
      ref.invalidate(userFutureProvider);
      return;
    }

    // BLOCK USER INTERACTION
    ref.read(_isLoadingProvider.notifier).update((state) => true);

    final fullName = _fullNameController.text.trim();
    final address = _addressController.text.trim();
    // final state = ref.read(_stateProvider)!.name;
    const state = 'Lagos State';
    final city = ref.read(_cityProvider)!;
    final phone = _phoneNumberController.text.trim();
    final additionalPhone = _phoneNumberOptController.text.trim();
    final response = await apiService.addAddress(user.id, fullName, address,
        state, city, phone, additionalPhone, widget.address?.id);

    if (!mounted) return; // USER EXIT PAGE

    // UNBLOCK USER INTERACTION
    ref.read(_isLoadingProvider.notifier).update((state) => false);

    switch (response.status) {
      case ResponseStatus.pending:
        return;
      case ResponseStatus.success:
        return _onSuccessful();
      case ResponseStatus.failed:
        return _onFailed(response.message!);
      case ResponseStatus.connectionError:
        return controller.onConnectionError(context);
      case ResponseStatus.unknownError:
        return controller.onUnknownError(context);
    }
  }

  void _onSuccessful() {
    snackbar(
      context: context,
      title: 'Successful',
      message: widget.address == null
          ? 'Address added successfully'
          : 'Address updated successfully',
    );
    ref.invalidate(addressesFutureProvider);
    pop(context);
  }

  void _onFailed(String message) {
    snackbar(
      context: context,
      title: 'Oops!!!',
      message: '$message. Please try again',
      contentType: ContentType.failure,
    );
  }

  void _onStateSelected(csc.State state) {
    if (state != ref.read(_stateProvider)) {
      ref.read(_cityProvider.notifier).update((state) => null);
    }
    ref.watch(_stateProvider.notifier).state = state;
    _trackFieldChanges();
  }

  void _onCitySelected(String city) {
    ref.watch(_cityProvider.notifier).state = city;
    _trackFieldChanges();
  }

  void _trackFieldChanges() {
    ref.watch(_hasChangedProvider.notifier).update((state) {
      return _fullNameController.text.trim() != widget.address?.fullName ||
          _addressController.text.trim() != widget.address?.address ||
          _phoneNumberController.text.trim() != widget.address?.phoneNumber ||
          _phoneNumberOptController.text.trim() !=
              widget.address?.additionalPhoneNumber ||
          // ref.read(_stateProvider)?.name != widget.address?.state ||
          ref.read(_cityProvider) != widget.address?.city;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isValidated = ref.watch(_isValidatedProvider);
    final isLoading = ref.watch(_isLoadingProvider);
    final stateError = ref.watch(_stateErrorProvider);
    final cityError = ref.watch(_cityErrorProvider);
    // final state = ref.watch(_stateProvider);
    final city = ref.watch(_cityProvider);

    final hasChanged = ref.watch(_hasChangedProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Add Address',
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        CustomTextField(
                          labelText: 'Full Name',
                          controller: _fullNameController,
                          keyboardType: TextInputType.name,
                          validator: Validator.validateName,
                          isValidated: isValidated,
                        ),
                        CustomTextField(
                          labelText: 'Delivery Address',
                          controller: _addressController,
                          keyboardType: TextInputType.streetAddress,
                          validator: Validator.validateAddress,
                          isValidated: isValidated,
                        ),
                        CustomChevronButton(
                          labelText: 'State/Region',
                          hintText: 'Select state',
                          errorText: 'Please select a state',
                          hasError: stateError,
                          text: 'Lagos State',
                          onPressed: () {
                            controller.showToast('Only Lagos state is allowed');
                          },
                          // text: state?.name,
                          // onPressed: () {
                          //   ref
                          //       .read(_stateErrorProvider.notifier)
                          //       .update((_) => false);
                          //   showModalBottomSheet(
                          //     context: context,
                          //     clipBehavior: Clip.hardEdge,
                          //     isScrollControlled: true,
                          //     constraints: BoxConstraints(
                          //       maxHeight:
                          //           MediaQuery.sizeOf(context).height * .75,
                          //     ),
                          //     builder: (_) {
                          //       return StateBottomSheet(
                          //         selected: state,
                          //         onSelected: _onStateSelected,
                          //       );
                          //     },
                          //   );
                          // },
                        ),
                        CustomChevronButton(
                          labelText: 'City',
                          hintText: 'Select city',
                          errorText: 'Please select a city',
                          text: city,
                          hasError: cityError,
                          // onPressed: state == null
                          onPressed: false
                              ? () {
                                  snackbar(
                                    context: context,
                                    title: 'Error',
                                    message: 'Please select a state first.',
                                    contentType: ContentType.help,
                                  );
                                }
                              : () {
                                  ref
                                      .read(_cityErrorProvider.notifier)
                                      .update((_) => false);
                                  showModalBottomSheet(
                                    context: context,
                                    clipBehavior: Clip.hardEdge,
                                    isScrollControlled: true,
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.sizeOf(context).height *
                                              .75,
                                    ),
                                    builder: (_) {
                                      return CityBottomSheet(
                                        selected: city,
                                        onSelected: _onCitySelected,
                                        // state: state,
                                      );
                                    },
                                  );
                                },
                        ),
                        CustomTextField(
                          labelText: 'Phone Number',
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          validator: Validator.validatePhoneNumber,
                          isValidated: isValidated,
                        ),
                        CustomTextField(
                          labelText: 'Additional Phone Number',
                          required: false,
                          controller: _phoneNumberOptController,
                          keyboardType: TextInputType.phone,
                          isValidated: isValidated,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          CustomButton(
            onPressed: hasChanged ? () => _onSave(context) : null,
            isLoading: isLoading,
            text: 'Save',
            margin: const EdgeInsets.all(15),
          ),
        ],
      ),
    );
  }
}
