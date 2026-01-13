import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class MenuProvider extends ChangeNotifier {
  static const String _key = 'dailyMenuByDate';
  final Map<String, DailyMenu> _menuByDate = {};

  DailyMenu getTodayMenu() {
    final key = _todayKey();
    return _menuByDate[key] ?? DailyMenu(
      dateKey: key,
      breakfast: '',
      lunch: '',
      snacks: '',
      dinner: '',
      todaysUpdate: '',
    );
  }

  MenuProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str != null) {
      final map = jsonDecode(str) as Map<String, dynamic>;
      map.forEach((k, v) => _menuByDate[k] = DailyMenu.fromJson(v));
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_menuByDate.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }

  Future<void> updateToday(DailyMenu menu) async {
    _menuByDate[menu.dateKey] = menu;
    await _save();
    notifyListeners();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

