// lib/providers/platform_provider.dart
import 'package:flutter/foundation.dart';
import '../utils/platform_helper.dart';

class PlatformProvider extends ChangeNotifier {
  bool get isMaterial => PlatformHelper.shouldUseMaterial;
  String get platformName => PlatformHelper.currentPlatformName;

  void setMaterialMode() {
    PlatformHelper.enableMaterialMode();
    notifyListeners();
  }

  void setCupertinoMode() {
    PlatformHelper.enableCupertinoMode();
    notifyListeners();
  }

  void resetPlatformMode() {
    PlatformHelper.resetPlatformMode();
    notifyListeners();
  }
}