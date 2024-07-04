import 'package:flutter/material.dart';
import 'package:vlookup_v2/models/user_model.dart';  // Ensure this import points to where your User model is defined

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  // Method to update the user data and notify listeners
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  // Method to clear the user data and notify listeners
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}