import 'package:flutter/material.dart';

import '../../utils.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.labelText,
    this.hintText,
    this.required = true,
    this.margin = const EdgeInsets.only(bottom: 20.0),
    this.controller,
    this.validator,
    this.suffixIcon,
    this.isValidated = false,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
  }) : textCapitalization = obscureText
            ? TextCapitalization.none
            : TextCapitalization.sentences;

  final String labelText;
  final String? hintText;
  final bool required;
  final EdgeInsets? margin;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final bool isValidated;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  // bool isValid = false;

  bool validate() {
    // Your validation logic for the custom widget
    // isValid = /* Your validation logic here */;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '$labelText ${required ? '*' : '(Optional)'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          TextFormField(
            controller: controller,
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            cursorColor: Theme.of(context).primaryColor,
            onTapOutside: (_) => dismissKeyboard(),
            validator: validator,
            obscuringCharacter: '●',
            obscureText: obscureText,
            autovalidateMode: isValidated
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: Colors.grey.shade200,
              hintStyle: const TextStyle(fontSize: 14.0),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 12.0,
              ),
              isDense: true,
              suffixIcon: suffixIcon,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1.2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 1.2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomChevronButton extends StatelessWidget {
  const CustomChevronButton({
    super.key,
    required this.labelText,
    this.hintText,
    this.text,
    this.errorText,
    this.required = true,
    this.hasError = false,
    this.margin = const EdgeInsets.only(bottom: 20.0),
    this.onPressed,
  });

  final String labelText;
  final String? hintText;
  final String? text;
  final String? errorText;
  final bool hasError;
  final bool required;
  final EdgeInsets? margin;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '$labelText ${required ? '*' : '(Optional)'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          MaterialButton(
            onPressed: onPressed,
            elevation: 0,
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(14.0),
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: hasError
                    ? Theme.of(context).colorScheme.error
                    : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: text != null ? Text(text!) : Text(hintText ?? ''),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          if (hasError && errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 8.0),
              child: Text(
                errorText!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomSearchbar extends StatelessWidget {
  const CustomSearchbar({
    Key? key,
    this.hintText,
    this.labelText,
    this.margin = const EdgeInsets.only(bottom: 15.0),
    this.borderRadius,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.onTap,
    this.canRequestFocus = true,
    this.autofocus = false,
    this.onChanged,
  }) : super(key: key);
  final String? hintText;
  final String? labelText;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final bool canRequestFocus;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: TextField(
        onTap: onTap,
        autofocus: autofocus,
        controller: controller,
        onChanged: onChanged,
        cursorColor: Theme.of(context).primaryColor,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        canRequestFocus: canRequestFocus,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: Color(0xFFD6D6D6),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.2,
            ),
          ),
          hintText: hintText,
          labelText: labelText,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
