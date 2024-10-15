import 'package:flutter/material.dart';
import 'package:chess_puzzle_game/Model/user.dart';

class SignUpViewModel extends ChangeNotifier {
  final User _userRepository = User();

  Future<String?> signUp(
      String username, String password, String confirmPassword) async {
    if (password != confirmPassword) {
      return 'Passwords Not Match!';
    }

    bool userExists = await _userRepository.checkUserExists(username);
    if (userExists) {
      return 'Username Already Exists!';
    }

    await _userRepository.saveUser(username, password, 0, "");
    return null;
  }
}
