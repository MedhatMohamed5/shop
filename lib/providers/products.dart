import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String authToken;
  final String userId;

  Products(this.authToken, this._items, this.userId);

  //var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly)
    //   return _items.where((product) => product.isFavorite).toList();
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final url = filterByUser
        ? 'https://fluttershop-13ce0.firebaseio.com/products.json?auth=$authToken&orderBy="creatorId"&equalTo="$userId"'
        : 'https://fluttershop-13ce0.firebaseio.com/products.json?auth=$authToken';

    try {
      final response = await http.get(url);

      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      final favoriteUrl =
          'https://fluttershop-13ce0.firebaseio.com/userFavorites/$userId.json?auth=$authToken';

      final favoriteResponse = await http.get(favoriteUrl);
      final favoriteData = jsonDecode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      if (extractedData != null && extractedData['error'] == null) {
        extractedData.forEach((prodId, prodData) {
          loadedProducts.add(
            Product(
              id: prodId,
              title: prodData['title'],
              price: prodData['price'],
              description: prodData['description'],
              imageUrl: prodData['imageUrl'],
              isFavorite:
                  favoriteData == null ? false : favoriteData[prodId] ?? false,
            ),
          );
        });
      }
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    /// with async keyword all code is rapped as a future, so you don't need to use return keyword
    // return
    final url =
        'https://fluttershop-13ce0.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          },
        ),
      );
      final newProduct = Product(
        // id: DateTime.now().toString(),
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
    // .then((response) {

    // }).catchError((onError) {
    //   print(onError);
    //   throw onError;
    // });
  }

  Future<void> updateProduct(String id, Product product) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final updateUrl =
          'https://fluttershop-13ce0.firebaseio.com/products/$id.json?auth=$authToken';
      try {
        await http.patch(
          updateUrl,
          body: json.encode({
            'title': product.title,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'description': product.description,
          }),
        );
        _items[prodIndex] = product;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final deleteUrl =
        'https://fluttershop-13ce0.firebaseio.com/products/$id.json?auth=$authToken';

    final existingProdutIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProdut = _items[existingProdutIndex];
    _items.removeAt(existingProdutIndex);
    notifyListeners();
    final response = await http.delete(deleteUrl);
    if (response.statusCode >= 400) {
      _items.insert(existingProdutIndex, existingProdut);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProdut = null;
  }

  Future<void> toggleFavorite(String id, Product product) async {
    final addToFavoriteUrl =
        'https://fluttershop-13ce0.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';

    //final existingProdutIndex = _items.indexWhere((prod) => prod.id == id);
    //var existingProdut = _items[existingProdutIndex];

    product.toggleFavoriteStatus();
    notifyListeners();
    final response = await http.put(
      addToFavoriteUrl,
      body: json.encode(
        product.isFavorite,
      ),
    );
    if (response.statusCode >= 400) {
      product.toggleFavoriteStatus();
      notifyListeners();
      throw HttpException('Could not add to favourite right now');
    }
    //existingProdut = null;
  }
}
