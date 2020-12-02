import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shop/models/http_exception.dart';
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.products,
    @required this.amount,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url = 'https://fluttershop-13ce0.firebaseio.com/orders.json';
    final timeStamp = DateTime.now();

    final response = await http.post(
      url,
      body: json.encode(
        {
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map(
                (cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                },
              )
              .toList(),
        },
      ),
    );

    if (response.statusCode >= 400) {
      throw HttpException('Can not make order right now');
    }

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        products: cartProducts,
        dateTime: DateTime.now(),
        amount: total,
      ),
    );
    notifyListeners();
  }
}
