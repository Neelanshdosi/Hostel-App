import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StudentsProvider extends ChangeNotifier {
  static const String _key = 'students';
  final List<User> _students = [];

  List<User> get students => List.unmodifiable(_students);

  StudentsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str != null) {
      final list = (jsonDecode(str) as List).cast<Map<String, dynamic>>();
      _students
        ..clear()
        ..addAll(list.map(User.fromJson));
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_students.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addStudent(User user) async {
    _students.add(user);
    await _save();
    notifyListeners();
  }

  Future<void> removeStudent(int id) async {
    _students.removeWhere((u) => u.id == id);
    await _save();
    notifyListeners();
  }
}

