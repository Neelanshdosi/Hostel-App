import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  static const String _userKey = 'currentUser';

  User? get currentUser => _currentUser;

  UserProvider() {
    _loadUser();
  }

  // Load user from local storage
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
      notifyListeners();
    }
  }

  // Save user to local storage
  Future<void> _saveUser() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(_currentUser!.toJson());
      await prefs.setString(_userKey, userJson);
    }
  }

  // Set current user (on login)
  Future<void> setUser(User user) async {
    _currentUser = user;
    await _saveUser();
    notifyListeners();
  }

  // Update user profile
  Future<void> updateUser(User updatedUser) async {
    _currentUser = updatedUser;
    await _saveUser();
    notifyListeners();
  }

  // Logout user
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    notifyListeners();
  }

  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  // Check if user is warden
  bool get isWarden => _currentUser?.role == 'warden';
}