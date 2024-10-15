import 'package:flutter/foundation.dart';

class DataModel extends ChangeNotifier {
  String _username = '';

  String get username => _username;

  void setUsername(String newUsername) {
    _username = newUsername;
    notifyListeners();
  }
}
