import 'package:cached_network_image/cached_network_image.dart';
import 'package:farmers_marketplace/view/widgets/place_holders.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewerPage extends StatefulWidget {
  const ImageViewerPage({
    Key? key,
    required this.productName,
    required this.imagesUrl,
    required this.initialIndex,
    required this.heroTag,
  }) : super(key: key);
  final String productName;
  final List<String> imagesUrl;
  final int initialIndex;
  final String heroTag;

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late final PageController _pageController;
  late final ValueNotifier<int> _currentIndexValueNotifier;

  bool _changePageFromButtonClick = false;

  @override
  void initState() {
    _pageController = PageController();
    _currentIndexValueNotifier = ValueNotifier<int>(widget.initialIndex);

    WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => _pageController.jumpToPage(widget.initialIndex));
    super.initState();
  }

  void _onPageChange(int index) {
    if (_changePageFromButtonClick) return;
    _currentIndexValueNotifier.value = index;
  }

  void _animateToPage(int index) {
    _changePageFromButtonClick = true;
    const duration = Duration(milliseconds: 300);
    const curve = Curves.linear;
    _pageController
        .animateToPage(index, duration: duration, curve: curve)
        .whenComplete(() => _changePageFromButtonClick = false);
    _currentIndexValueNotifier.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
        title: Text(
          widget.productName,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          PageView.builder(
            itemCount: widget.imagesUrl.length,
            controller: _pageController,
            onPageChanged: _onPageChange,
            itemBuilder: (BuildContext context, int index) {
              final imageUrl = widget.imagesUrl.elementAt(index);
              return Hero(
                tag: widget.heroTag,
                child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(imageUrl),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0.0,
            child: Container(
              height: 80.0,
              padding: const EdgeInsets.all(10.0),
              child: ListView.separated(
                itemCount: widget.imagesUrl.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) => const SizedBox(width: 8.0),
                itemBuilder: (BuildContext context, int index) {
                  final imageUrl = widget.imagesUrl.elementAt(index);

                  return MaterialButton(
                    onPressed: () => _animateToPage(index),
                    minWidth: 0.0,
                    padding: EdgeInsets.zero,
                    child: ValueListenableBuilder<int>(
                      valueListenable: _currentIndexValueNotifier,
                      builder: (_, currentIndexValue, __) {
                        return Stack(
                          alignment: Alignment.topRight,
                          children: <Widget>[
                            ImageLoader(
                              imageUrl: imageUrl,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            if (index == currentIndexValue)
                              CustomPaint(
                                painter: CheckerPainter(
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 14.0,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CheckerPainter extends CustomPainter {
  CheckerPainter({
    super.repaint,
    required this.color,
  });
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    const wid = 25.0;
    const radius = 8.0;
    path.moveTo(size.width - wid, 0.0);
    path.lineTo(size.width - radius, 0.0);
    path.quadraticBezierTo(size.width, 0.0, size.width, radius);
    path.lineTo(size.width, wid);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
