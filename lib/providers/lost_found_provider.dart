import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class LostFoundProvider extends ChangeNotifier {
  static const String _key = 'lostFoundItems';
  List<LostFoundItem> _items = [];

  List<LostFoundItem> get items => List.unmodifiable(_items);

  LostFoundProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str != null) {
      final list = (jsonDecode(str) as List).cast<Map<String, dynamic>>();
      _items = list.map(LostFoundItem.fromJson).toList();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addItem(LostFoundItem item) async {
    _items.insert(0, item);
    await _save();
    notifyListeners();
  }
}

