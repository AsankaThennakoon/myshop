import 'package:flutter/material.dart';
import 'package:myshop/providers/orders.dart' show Orders;
import 'package:myshop/widgets/app_deawer.dart';
import '../widgets/order_item.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  static const routName = '/orders';

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
        itemCount: orderData.orders.length,
      ),
    );
  }
}
