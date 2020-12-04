import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

import '../providers/orders.dart' show Orders;

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false;

  @override
  void initState() {
    Future.delayed(
      Duration.zero,
    ).then((_) async {
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
      } catch (onError) {
        print(onError);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text(
          'Your Orders',
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemBuilder: (ctx, index) => OrderItem(
                orderData.orders[index],
              ),
              itemCount: orderData.orders.length,
            ),
    );
  }
}
