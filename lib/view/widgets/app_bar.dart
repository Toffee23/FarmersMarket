import 'package:farmers_marketplace/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../pages/cart_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
    this.title,
    this.titleWidget,
    this.actions,
    this.centerTitle = true,
    this.bottom,
    this.toolbarHeight,
    this.leading,
    this.leadingWidth,
    this.leadingActionButton,
  }) : super(key: key);
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool? centerTitle;
  final PreferredSizeWidget? bottom;
  final double? toolbarHeight;
  final Widget? leading;
  final double? leadingWidth;
  final VoidCallback? leadingActionButton;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: leadingWidth ?? 56 + 10,
      title: titleWidget ?? (title == null ? null : Text(title!)),
      centerTitle: centerTitle,
      bottom: bottom,
      toolbarHeight: toolbarHeight,
      leading: leading ??
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: Theme.of(context).primaryColor.withOpacity(.12),
              ),
              child: IconButton(
                onPressed: leadingActionButton ?? () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                color: Theme.of(context).primaryColor,
                icon: const Icon(Icons.chevron_left),
              ),
            ),
          ),
      actions: actions ??
          const <Widget>[
            CartButton(),
            SizedBox(width: 8.0),
          ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size(0, toolbarHeight ?? 56);
}

class CartButton extends ConsumerWidget {
  const CartButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartStateProvider);

    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: () => pushTo(context, const CartPage()),
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            icon: const Icon(
              CupertinoIcons.cart,
              color: Colors.white,
            ),
          ),
        ),
        if (cart != null)
          Positioned(
            top: 3.0,
            right: 6.0,
            child: Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8.0),
              ),
              constraints: const BoxConstraints(
                minWidth: 16.0,
                minHeight: 16.0,
              ),
              child: Center(
                child: Text(
                  cart.length.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
