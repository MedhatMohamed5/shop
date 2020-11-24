import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';

import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;
  // final double price;

  // ProductItem(
  //   this.id,
  //   this.title,
  //   this.imageUrl,
  //   this.price,
  // );

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        header: Container(
          color: Colors.black54,
          padding: const EdgeInsets.all(8),
          child: Text(
            product.title,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        footer: GridTileBar(
          leading: IconButton(
            icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border),
            color: Theme.of(context).accentColor,
            onPressed: () => product.toggleFavoriteStatus(),
          ),
          backgroundColor: Colors.black87,
          title: Text(
            '${product.price}',
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
