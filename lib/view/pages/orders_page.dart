import 'package:farmers_marketplace/core/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/models.dart';
import '../../providers.dart';
import '../../router/route/app_routes.dart';
import '../widgets/app_bar.dart';
import '../widgets/error_widget.dart';
import '../widgets/place_holders.dart';
import 'order_tracking_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: CustomAppBar(
            toolbarHeight: 56 + 48,
            title: 'My Orders',
            bottom: TabBar(
              tabs: <Tab>[
                Tab(text: 'All'),
                Tab(text: 'Pending'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              OrderTab(
                orderType: 'all',
                noItemText: 'You have no orders',
              ),
              OrderTab(
                orderType: 'pending',
                noItemText: 'You have no pending orders',
              ),
              OrderTab(
                orderType: 'completed',
                noItemText: 'You have no completed orders',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoOrderWidget extends StatelessWidget {
  const NoOrderWidget({
    Key? key,
    required this.text,
  }) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 50.0),
        Image.asset(AppImages.orders, width: 200.0),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class OrderProductCard extends StatelessWidget {
  const OrderProductCard({
    Key? key,
    required this.order,
    required this.onTrackItem,
  }) : super(key: key);
  final Order order;
  final VoidCallback onTrackItem;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
        ),
        height: 120.0,
        child: Row(
          children: <Widget>[
            ImageLoader(
              imageUrl: order.imageUrl,
              width: 100.0,
              height: 100.0,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        order.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Order: #${order.orderId}',
                        // style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        DateFormat('MMM dd, yyyy').format(order.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(.4),
                        ),
                        child: Text(
                          order.orderStatus,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontSize: 12.0,
                                  color: Theme.of(context).primaryColor),
                        ),
                      ),
                      TextButton(
                        onPressed: onTrackItem,
                        style: TextButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4.0),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('Track Item'),
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

class OrderTab extends ConsumerWidget {
  const OrderTab({
    Key? key,
    required this.orderType,
    required this.noItemText,
  }) : super(key: key);
  final String orderType;
  final String noItemText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersFuture = ref.watch(ordersFutureProvider);

    return ordersFuture.when(
      data: (orders) {
        if (orders == null) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: CustomErrorWidget(
              onRetry: () => ref.invalidate(ordersFutureProvider),
            ),
          );
        }
        if (orderType != 'all') {
          orders = orders
              .where((element) => element.orderStatus == orderType)
              .toList();
        }
        if (orders.isEmpty) {
          return NoOrderWidget(text: noItemText);
        }
        return ListView.separated(
          itemCount: orders.length,
          padding: const EdgeInsets.all(20.0),
          separatorBuilder: (_, __) => const SizedBox(height: 15.0),
          itemBuilder: (BuildContext context, int index) {
            final order = orders!.elementAt(index);
            return OrderProductCard(
              order: order,
              onTrackItem: () =>
                  pushTo(context, OrderTrackingPage(order: order)),
            );
          },
        );
      },
      error: (_, __) {
        return CustomErrorWidget(
          onRetry: () => ref.invalidate(ordersFutureProvider),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(20.0),
        child: CustomLoadingWidget(),
      ),
    );
  }
}
