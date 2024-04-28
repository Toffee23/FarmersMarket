import 'package:farmers_marketplace/core/extensions/double.dart';
import 'package:farmers_marketplace/view/widgets/place_holders.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key? key,
    required this.onPressed,
    required this.onIncrement,
    required this.onDecrement,
    required this.onShare,
    required this.heroTag,
    required this.image,
    required this.name,
    required this.price,
    required this.rating,
    required this.count,
    required this.weight,
    required this.unit,
    this.width,
  }) : super(key: key);
  final VoidCallback onPressed;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onShare;
  final String heroTag;
  final String image;
  final String name;
  final double price;
  final int rating;
  final int count;
  final double? width;
  final double weight;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: MaterialButton(
        onPressed: onPressed,
        padding: const EdgeInsets.all(4.0),
        clipBehavior: Clip.hardEdge,
        color: Colors.white,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: heroTag,
              child: ImageLoader(
                imageUrl: image,
                width: 150,
                height: 120,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.0),
                  ),
                ),
                fit: BoxFit.fitWidth,
              ),
            ),
            const SizedBox(height: 6.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: '$name ',
                      style: Theme.of(context).textTheme.titleSmall,
                      children: <InlineSpan>[
                        TextSpan(
                          text: weight > 0 ? '($weight$unit)' : '',
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.blueGrey.shade600,
                                  ),
                        )
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onShare,
                  iconSize: 16.0,
                  color: Theme.of(context).primaryColor,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.all(8.0),
                    minimumSize: Size.zero,
                  ),
                  tooltip: 'Share product',
                  icon: const Icon(CupertinoIcons.share_up),
                ),
              ],
            ),
            Text(price.toPrice()),
            Row(
              children: List.generate(
                5,
                (index) {
                  return Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Icon(
                      rating > index
                          ? CupertinoIcons.star_fill
                          : CupertinoIcons.star,
                      size: 12.0,
                      color: Colors.amber.shade700,
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            if (count > 0)
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      onPressed: onDecrement,
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(4.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(
                        CupertinoIcons.minus_circle,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                    ),
                    Text(count.toString()),
                    IconButton(
                      onPressed: onIncrement,
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(4.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(
                        CupertinoIcons.plus_circle_fill,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              )
            else
              ElevatedButton(
                onPressed: onIncrement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  disabledBackgroundColor:
                      Theme.of(context).primaryColor.withOpacity(.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  minimumSize: const Size(double.infinity, 34.0),
                ),
                child: const Text('Add to cart'),
              ),
          ],
        ),
      ),
    );
  }
}

class CartProductCard extends StatelessWidget {
  const CartProductCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.heroTag,
    required this.weight,
    required this.unit,
    required this.price,
    required this.qty,
    required this.onPressed,
    required this.onDelete,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);
  final String imageUrl;
  final String name;
  final String heroTag;
  final double weight;
  final String unit;
  final double price;
  final int qty;
  final VoidCallback onPressed;
  final VoidCallback onDelete;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      padding: const EdgeInsets.all(4.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Row(
        children: <Widget>[
          Hero(
            tag: heroTag,
            child: ImageLoader(
              imageUrl: imageUrl,
              width: 100.0,
              height: 100.0,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            'Weight: $weight $unit',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        CupertinoIcons.delete,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        price.toPrice(),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    IconButton(
                      onPressed: onDecrement,
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(4.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(
                        CupertinoIcons.minus_circle,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Text(qty.toString()),
                    const SizedBox(width: 4.0),
                    IconButton(
                      onPressed: onIncrement,
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(4.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(
                        CupertinoIcons.plus_circle_fill,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LikedProductCard extends StatelessWidget {
  const LikedProductCard({
    Key? key,
    required this.product,
    required this.heroTag,
    required this.onPressed,
    required this.onDislike,
  }) : super(key: key);
  final Product product;
  final String heroTag;
  final VoidCallback onPressed;
  final VoidCallback onDislike;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      padding: const EdgeInsets.all(4.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Row(
        children: <Widget>[
          Hero(
            tag: heroTag,
            child: ImageLoader(
              imageUrl: product.image,
              width: 100.0,
              height: 100.0,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            product.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            'Weight: ${product.weight} ${product.unit}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  product.price.toPrice(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
          LikeButton(
            isLiked: true,
            // onToggle: () => _toggleLike(context, ref),
            onToggle: onDislike,
          ),
          const SizedBox(width: 8.0),
        ],
      ),
    );
  }
}

class SearchProductCard extends StatelessWidget {
  const SearchProductCard({
    Key? key,
    required this.onPressed,
    required this.onShare,
    required this.imageUrl,
    required this.name,
    required this.heroTag,
    required this.search,
    required this.rating,
    required this.price,
    required this.weight,
    required this.unit,
  }) : super(key: key);
  final VoidCallback onPressed;
  final VoidCallback onShare;
  final String imageUrl;
  final String name;
  final String heroTag;
  final String search;
  final int rating;
  final double price;
  final double weight;
  final String unit;

  @override
  Widget build(BuildContext context) {
    List<TextSpan> textSpans = [];
    name.splitMapJoin(
      RegExp(search, caseSensitive: false),
      onMatch: (match) {
        textSpans.add(
          TextSpan(
            text: match.group(0),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
        );
        return '';
      },
      onNonMatch: (nonMatch) {
        textSpans.add(
          TextSpan(
            text: nonMatch,
          ),
        );
        return '';
      },
    );

    return SizedBox(
      height: 136.0,
      child: MaterialButton(
        onPressed: onPressed,
        color: Colors.white,
        padding: const EdgeInsets.all(8.0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: heroTag,
              child: ImageLoader(
                imageUrl: imageUrl,
                width: 120.0,
                height: 120.0,
              ),
            ),
            const SizedBox(width: 6.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.titleMedium,
                      children: <InlineSpan>[
                        ...textSpans,
                        TextSpan(
                          text: weight > 0 ? ' ($weight$unit)' : '',
                          style: TextStyle(
                            color: Colors.blueGrey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    price.toPrice(),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).primaryColor, fontSize: 14.0),
                  ),
                  const Spacer(),
                  Row(
                    children: <Widget>[
                      ...List.generate(
                        5,
                        (index) {
                          return Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Icon(
                              rating > index
                                  ? CupertinoIcons.star_fill
                                  : CupertinoIcons.star,
                              size: 12.0,
                              color: Colors.amber.shade700,
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: onShare,
                        style: FilledButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: Theme.of(context).primaryColor,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(.25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4.0,
                          ),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              CupertinoIcons.share_up,
                              size: 15.0,
                            ),
                            SizedBox(width: 5.0),
                            Text(
                              'Share',
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCardLoader extends StatelessWidget {
  const ProductCardLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 150,
      child: Column(
        children: <Widget>[
          Expanded(
            child: DataLoader(),
          ),
          DataLoader(
            height: 15.0,
            margin: EdgeInsets.only(right: 10.0, top: 8.0),
          ),
          DataLoader(
            height: 10.0,
            margin: EdgeInsets.only(right: 60.0, top: 8.0),
          ),
          DataLoader(
            height: 10.0,
            margin: EdgeInsets.only(right: 100.0, top: 8.0),
          ),
          DataLoader(
            height: 34.0,
            radius: 17.0,
            margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
          ),
        ],
      ),
    );
  }
}

class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    required this.isLiked,
    required this.onToggle,
    this.iconSize,
  });
  final bool isLiked;
  final VoidCallback onToggle;
  final double? iconSize;

  @override
  LikeButtonDemoState createState() => LikeButtonDemoState();
}

class LikeButtonDemoState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _liked = false;

  @override
  void initState() {
    _liked = widget.isLiked;
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        // _animationController.reset();
        // _animationController.stop();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    _liked = !_liked;
    _animationController.forward();
    widget.onToggle.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            decoration: ShapeDecoration(
              shape: const CircleBorder(),
              color: Colors.white,
              shadows: <BoxShadow>[
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(.5),
                  spreadRadius: -4.0,
                  blurRadius: 6.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => _toggleLike(),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.all(8.0),
                minimumSize: Size.zero,
              ),
              icon: Icon(
                Icons.favorite,
                color: ColorTween(
                  begin: widget.isLiked ? Colors.red : Colors.grey,
                  end: widget.isLiked ? Colors.grey : Colors.red,
                ).animate(_animationController).value!,
                size: widget.iconSize,
              ),
            ),
          ),
        );
      },
    );
  }
}
