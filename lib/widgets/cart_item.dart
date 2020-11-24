import 'package:flutter/material.dart';

class CartItem extends StatelessWidget {
  final String id;
  final double price;
  final int quantity;
  final String title;

  CartItem(this.id, this.title, this.price, this.quantity);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: CircleAvatar(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: FittedBox(
                child: Text('${price.toStringAsFixed(2)}'),
              ),
            ),
          ),
          title: Text(title),
          subtitle: Text(
            'Total: ${(price * quantity).toStringAsFixed(2)}',
          ),
          trailing: Text(
            'x $quantity',
          ),
        ),
      ),
    );
  }
}
