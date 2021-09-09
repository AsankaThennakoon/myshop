import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:myshop/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token = "0";
  DateTime _exporyDate = DateTime.now();
  late String _userId;

  bool get isAuth {
    return token != "0";
  }

  String get token {
    // ignore: unrelated_type_equality_checks
    if (_exporyDate != '' &&
        _exporyDate.isAfter(DateTime.now()) &&
        _token != "0") {
      return _token;
    }
    return "0";
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyA02BgE8S1BCS-ozjVhU72ikoFg75OnYYY';

    final Uri _uri = Uri.parse(url);

    try {
      final response = await http.post(
        _uri,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttPException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _exporyDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      notifyListeners();

      print(json.decode(response.body));
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}
