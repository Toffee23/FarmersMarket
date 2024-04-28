import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'card.dart';

class ImageLoader extends StatelessWidget {
  const ImageLoader({
    Key? key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit,
    this.decoration,
  }) : super(key: key);
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: decoration ??
          BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          enabled: true,
          child: SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.white,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}

class DataLoader extends StatelessWidget {
  const DataLoader({
    Key? key,
    this.radius = 12.0,
    this.height,
    this.width,
    this.margin,
    this.baseColor,
    this.highlightColor,
    this.child,
  }) : super(key: key);
  final double radius;
  final double? height;
  final double? width;
  final EdgeInsets? margin;
  final Color? baseColor;
  final Color? highlightColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: height,
          width: width,
          margin: margin,
          child: Shimmer.fromColors(
            baseColor: baseColor ?? Colors.grey.shade200,
            highlightColor: highlightColor ?? Colors.grey.shade100,
            enabled: true,
            child: SizedBox(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        if (child != null) child!
      ],
    );
  }
}

class ProductGridLoading extends StatelessWidget {
  const ProductGridLoading({
    Key? key,
    required this.count,
    this.padding = const EdgeInsets.symmetric(horizontal: 15.0),
  }) : super(key: key);
  final int count;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        mainAxisExtent: 250.0,
      ),
      children: List.generate(
        count,
        (index) {
          return const ProductCardLoader();
        },
      ),
    );
  }
}

class CategoryLoadingWidget extends StatelessWidget {
  const CategoryLoadingWidget({
    Key? key,
    required this.padding,
  }) : super(key: key);
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10.0,
      ),
      children: List.generate(
        4,
        (index) {
          return const DataLoader();
        },
      ),
    );
  }
}

class CustomLoadingWidget extends StatelessWidget {
  const CustomLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.separated(
            itemCount: 6,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 15.0),
            itemBuilder: (_, __) {
              return DataLoader(
                height: 100.0,
                baseColor: Colors.grey.shade100,
                highlightColor: Colors.grey.shade200,
                child: const Row(
                  children: <Widget>[
                    DataLoader(
                      width: 50.0,
                      height: 50.0,
                      radius: 25.0,
                      margin: EdgeInsets.all(15.0),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          DataLoader(
                            width: double.infinity,
                            height: 20.0,
                            radius: 10.0,
                            margin: EdgeInsets.only(right: 40.0, top: 15.0),
                          ),
                          DataLoader(
                            width: double.infinity,
                            height: 15.0,
                            radius: 10.0,
                            margin: EdgeInsets.only(right: 140.0, top: 15.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const DataLoader(
          width: double.infinity,
          height: 50.0,
          margin: EdgeInsets.symmetric(vertical: 15.0),
        )
      ],
    );
  }
}
