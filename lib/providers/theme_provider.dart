import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeProvider extends ChangeNotifier {
  static const String _themePreferenceKey = 'theme_preference';
  
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  ThemeProvider() {
    _loadThemePreference();
  }
  
  // Memuat preferensi tema dari penyimpanan lokal
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themePreferenceKey) ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      // Fallback to light mode if there's an error
      _themeMode = ThemeMode.light;
      notifyListeners();
    }
  }
  
  // Mengganti tema antara mode terang dan gelap
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePreferenceKey, isDarkMode);
    } catch (e) {
      // Silently handle error
    }
    
    notifyListeners();
  }
  
  // Mengatur tema ke mode tertentu
  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePreferenceKey, mode == ThemeMode.dark);
    } catch (e) {
      // Silently handle error
    }
    
    notifyListeners();
  }
  
  // Mengatur tema berdasarkan tema sistem
  Future<void> setSystemTheme() async {
    _themeMode = ThemeMode.system;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePreferenceKey, false); // Reset to light as fallback
      await prefs.setString('theme_mode', 'system');
    } catch (e) {
      // Silently handle error
    }
    
    notifyListeners();
  }
}

