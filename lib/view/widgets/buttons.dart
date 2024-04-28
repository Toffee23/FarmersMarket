import 'package:flutter/material.dart';

import 'place_holders.dart';

enum CustomButtonType {
  elevated,
  outlined,
  text,
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.text,
    this.icon,
    this.onPressed,
    this.margin = const EdgeInsets.only(bottom: 20),
    this.type = CustomButtonType.elevated,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 48.0,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);
  final String text;
  final Icon? icon;
  final EdgeInsets? margin;
  final VoidCallback? onPressed;
  final CustomButtonType type;
  final bool isLoading;
  final double width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;

  ButtonStyle _style(BuildContext context) {
    switch (type) {
      case CustomButtonType.elevated:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: 0,
          disabledBackgroundColor:
              Theme.of(context).primaryColor.withOpacity(.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          minimumSize: Size(width, height),
        );
      case CustomButtonType.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          side: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
          elevation: 0,
          minimumSize: Size(width, height),
        );
      case CustomButtonType.text:
        return TextButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          backgroundColor: backgroundColor ?? Colors.transparent,
          foregroundColor: Theme.of(context).primaryColor,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ElevatedButton(
        style: _style(context),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox.square(
                dimension: 20.0,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2.5,
                  backgroundColor: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(text),
                  if (icon != null) ...[
                    const SizedBox(width: 4.0),
                    icon!,
                  ],
                ],
              ),
      ),
    );
  }
}

class CardButton extends StatelessWidget {
  const CardButton({
    Key? key,
    this.onPressed,
    required this.icon,
    required this.text,
    this.margin = const EdgeInsets.only(bottom: 15.0),
  }) : super(key: key);
  final VoidCallback? onPressed;
  final Icon icon;
  final String text;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.2,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5.5,
              offset: const Offset(0.0, 1.0),
            ),
          ],
        ),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide.none,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 12.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Row(
            children: <Widget>[
              icon,
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(text),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryContainerButton extends StatelessWidget {
  const CategoryContainerButton({
    Key? key,
    required this.onPressed,
    required this.image,
    required this.text,
    this.textStyle,
  }) : super(key: key);
  final VoidCallback onPressed;
  final String image;
  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: 0,
      elevation: 0,
      onPressed: onPressed,
      padding: const EdgeInsets.all(6.0),
      color: Theme.of(context).primaryColor.withOpacity(.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ImageLoader(
              imageUrl: image,
              decoration: const BoxDecoration(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: textStyle ?? const TextStyle(fontSize: 11.0),
            ),
          ),
        ],
      ),
    );
  }
}
