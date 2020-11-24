import 'package:flutter/material.dart';
import '../providers/products.dart';
// import '../providers/product.dart';
import 'package:provider/provider.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = showFavs ? productsData.favoriteItems : productsData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 9 / 10,
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),

      /// here i don't depened on context, so we can use value constractor instead of default
      /// and we use existing object not creating new one
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        //create: (_) => products[index],
        value: products[index],
        child: ProductItem(
            // products[index].id,
            // products[index].title,
            // products[index].imageUrl,
            // products[index].price,
            ),
      ),
      itemCount: products.length,
    );
  }
}
