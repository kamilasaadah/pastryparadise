import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformHelper {
  // Tambahkan variabel statis untuk mode testing
  static bool _forceMaterial = false;
  static bool _forceCupertino = false;

  // Getter untuk menentukan platform yang digunakan
  static bool get shouldUseMaterial {
    // Jika mode testing diaktifkan, gunakan nilai yang dipaksa
    if (_forceMaterial) return true;
    if (_forceCupertino) return false;
    
    // Logika default
    return defaultTargetPlatform == TargetPlatform.android || 
           defaultTargetPlatform == TargetPlatform.fuchsia ||
           defaultTargetPlatform == TargetPlatform.linux ||
           defaultTargetPlatform == TargetPlatform.windows ||
           (kIsWeb && !_forceCupertino); // Web default ke Material
  }

  // Fungsi untuk testing Material Design
  static void enableMaterialMode() {
    _forceMaterial = true;
    _forceCupertino = false;
  }

  // Fungsi untuk testing Cupertino Design
  static void enableCupertinoMode() {
    _forceMaterial = false;
    _forceCupertino = true;
  }

  // Fungsi untuk kembali ke mode default
  static void resetPlatformMode() {
    _forceMaterial = false;
    _forceCupertino = false;
  }

  // Getter untuk mendapatkan nama platform saat ini (untuk UI)
  static String get currentPlatformName {
    if (_forceMaterial) return "Material (Android)";
    if (_forceCupertino) return "Cupertino (iOS)";
    return shouldUseMaterial ? "Material (Android)" : "Cupertino (iOS)";
  }

  // Mengecek apakah tema gelap yang digunakan
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Mendapatkan warna berdasarkan mode tema
  static Color getThemedColor(BuildContext context, Color lightColor, Color darkColor) {
    return isDarkMode(context) ? darkColor : lightColor;
  }

  // Untuk testing - cek status mode
  static bool get isForcedMaterial => _forceMaterial;
  static bool get isForcedCupertino => _forceCupertino;
  static bool get isUsingDefaultMode => !_forceMaterial && !_forceCupertino;
}

