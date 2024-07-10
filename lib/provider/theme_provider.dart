import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider([this._themeMode = ThemeMode.system]); //constructor [...] optional parameters

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }
}
