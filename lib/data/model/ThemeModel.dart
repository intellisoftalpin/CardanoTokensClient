import 'package:crypto_offline/data/repository/SharedPreferences/SharedPreferencesRepository.dart';
import 'package:flutter/material.dart';

class ThemeModel extends ChangeNotifier {
  late int _isDark;
  late SharedPreferencesRepository _preferences;
  int get isDark => _isDark;

  ThemeModel() {
    _isDark = 1;
    _preferences = SharedPreferencesRepository();
    getPreferences();
  }

  set isDark(int value) {
    _isDark = value;
    _preferences.setTheme(value);
    notifyListeners();
  }

  getPreferences() async {
    _isDark = await _preferences.getTheme();
    notifyListeners();
  }
}