import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'product.dart';
import 'package:http/http.dart' as http;

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
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal yoou want.',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
  ];

  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
  final String authToke;
  final String userId;

  Products(this.authToke, this.userId, this._items);
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';

    final url =
        'https://myshop-99ce6-default-rtdb.firebaseio.com/products.json?auth=$authToke&$filterString';

    final Uri _uri = Uri.parse(url);

    final respose = await http.get(_uri);

    final extractData = json.decode(respose.body) as Map<String, dynamic>;

    final url1 =
        "https://myshop-99ce6-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToke";

    final Uri _uri1 = Uri.parse(url1);

    final favoriteResponse = await http.get(_uri1);
    final favoriteData = json.decode(favoriteResponse.body);
    final List<Product> loadedProducts = [];
    print(extractData);
    extractData.forEach(
      (productId, productData) {
        loadedProducts.add(
          Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            isFavorite:
                favoriteData == null ? false : favoriteData[productId] ?? false,
            imageUrl: productData['imageUrl'],
          ),
        );
      },
    );
    _items = loadedProducts;
    notifyListeners();

    try {
      final response = await http.get(_uri);
      print(json.decode(response.body));
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final url =
          "https://myshop-99ce6-default-rtdb.firebaseio.com/products.json?auth=$authToke";

      final Uri _uri = Uri.parse(url);
      final response = await http.post(_uri,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          }));
      print(json.decode(response.body));

      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct);//at the start of the list
      notifyListeners();
    } catch (onError) {
      print(onError);
      throw onError;
    }

    // _items.add(value);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      final url =
          "https://myshop-99ce6-default-rtdb.firebaseio.com/products/$id.json?auth=$authToke";

      final Uri _uri = Uri.parse(url);

      await http.patch(_uri,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));

      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        "https://myshop-99ce6-default-rtdb.firebaseio.com/products/$id.json?auth=$authToke";

    final Uri _uri = Uri.parse(url);

    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(_uri);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();

      throw HttpException('Could not delete product');
    }
    existingProduct.dispose();

    // _items.removeWhere((element) => element.id == id);
  }
}
