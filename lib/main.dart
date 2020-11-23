import 'package:flutter/material.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Shop',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Lato',
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => ProductOverviewScreen(),
        ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
      },
    );
  }
}
