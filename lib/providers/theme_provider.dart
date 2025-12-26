// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _useMaterial3 = true;

  ThemeMode get themeMode => _themeMode;
  bool get useMaterial3 => _useMaterial3;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleMaterial3() {
    _useMaterial3 = !_useMaterial3;
    notifyListeners();
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeData getCurrentTheme(BuildContext context) {
    if (isDarkMode) {
      return ThemeData.dark(useMaterial3: _useMaterial3);
    }
    return ThemeData.light(useMaterial3: _useMaterial3);
  }
}
