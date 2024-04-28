import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/models.dart';
import '../widgets/app_bar.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({Key? key, required this.order}) : super(key: key);
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 15.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Theme.of(context).primaryColor.withOpacity(.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Created on: ${DateFormat('MMM dd, yyyy').format(order.createdAt)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Order ID: #${order.orderId}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            OrderTrackingItem(
              title: 'Order Placed',
              subtitle: 'Order has been been sent to vendor',
              progress: order.trackOrder,
              index: 0,
            ),
            OrderTrackingItem(
              title: 'Order Confirmed',
              subtitle: 'Order has been been confirmed by vendor',
              progress: order.trackOrder,
              index: 1,
            ),
            OrderTrackingItem(
              title: 'Driver Assigned',
              subtitle:
                  'A dispatch driver has been assigned to pick up the order',
              progress: order.trackOrder,
              index: 2,
            ),
            OrderTrackingItem(
              title: 'In Transit',
              subtitle: 'Order picked up and is on route to your destination',
              progress: order.trackOrder,
              index: 3,
            ),
            OrderTrackingItem(
              title: 'Order Completed',
              subtitle: 'Order has been successfully delivered',
              progress: order.trackOrder,
              index: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class OrderTrackingItem extends StatelessWidget {
  const OrderTrackingItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.index,
  }) : super(key: key);
  final String title;
  final String subtitle;
  final int progress;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.check_circle,
          size: 28.0,
          color: index <= progress
              ? Theme.of(context).primaryColor
              : Colors.grey.shade400,
        ),
        Expanded(
          child: CustomPaint(
            painter: index != 4 ? VerticalLinePaint() : null,
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0, bottom: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0),
                      color: index <= progress
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade400,
                    ),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(subtitle),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class VerticalLinePaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2.3;
    const padding = 2.0;
    const iconSize = 28.0;

    const p1 = Offset(-iconSize / 2, iconSize + padding);
    final p2 = Offset(-iconSize / 2, size.height - padding);
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
