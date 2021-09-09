import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
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

  String get userId {
    return _userId;
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
      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _exporyDate.toIso8601String()
      });
      prefs.setString('userData', userData);

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

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extractedUserData = json.decode(prefs.getString('userData') as String)
        as Map<String, Object>;

    final expiryDate =
        DateTime.parse(extractedUserData['expiryDate'] as String);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData['tokem'] as String;
    _userId = extractedUserData['userId'] as String;
    _exporyDate = expiryDate;

    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = "0";
    _userId = "0";
    _exporyDate = DateTime.now();
    if (_authTimer.isActive) {
      _authTimer.cancel();
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear(); //this one remove all the shared pref data so use if you have
    //so use prefs.remove('userData) mthod it can be use to remove paticulara only
  }

  late Timer _authTimer;

  void _autoLogout() {
    if (_authTimer.isActive) {
      _authTimer.cancel();
    }
    final timeToExpiry = _exporyDate.difference(DateTime.now()).inSeconds;

    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
