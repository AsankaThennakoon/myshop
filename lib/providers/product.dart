import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url =
        "https://myshop-99ce6-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token";

    final Uri _uri = Uri.parse(url);

    try {
      final respose = await http.put(
        _uri,
        body: json.encode(
          isFavorite,
        ),
      );

      if (respose.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
      }
    } catch (erro) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
