import 'package:flutter/material.dart';
import 'package:chess_puzzle_game/Model/user.dart';

class LoginViewModel extends ChangeNotifier {
  final User _userRepository = User();

  Future<String?> logIn(String username, String password) async {
    bool userExists = await _userRepository.checkUserExists(username);
    if (!userExists) {
      return 'Username Not Found!';
    }

    bool isPasswordCorrect =
        await _userRepository.checkUserPassword(username, password);
    if (!isPasswordCorrect) {
      return 'Incorrect Password!';
    }
    return null;
  }
}
