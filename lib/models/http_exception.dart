import 'dart:html';

class HttPException implements Exception {
  final String messaga;

  HttPException(this.messaga);

  @override
  String toString() {
    return messaga;
  }
}
