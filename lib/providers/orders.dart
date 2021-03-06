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
  final String authToken;

  final String userId;

  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Orders(this.authToken, this.userId, this._orders);

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://fluttershop-13ce0.firebaseio.com/orders/$userId.json?auth=$authToken';

    try {
      final response = await http.get(url);
      print(response.body);
      final List<OrderItem> loadedOrders = [];
      if (response.statusCode >= 400) {
        throw HttpException('Can not fetch orders right now');
      } else {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>;
        if (extractedData != null) {
          extractedData.forEach((orderId, orderData) {
            loadedOrders.add(
              OrderItem(
                id: orderId,
                amount: orderData['amount'],
                dateTime: DateTime.parse(orderData['dateTime']),
                products: (orderData['products'] as List<dynamic>)
                    .map(
                      (item) => CartItem(
                        id: item['id'],
                        price: item['price'],
                        quantity: item['quantity'],
                        title: item['title'],
                      ),
                    )
                    .toList(),
              ),
            );
          });
        }
        _orders = loadedOrders.reversed.toList();
        notifyListeners();
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://fluttershop-13ce0.firebaseio.com/orders/$userId.json?auth=$authToken';
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
