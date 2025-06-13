// lib/widgets/platform_toggle.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/platform_helper.dart';

class PlatformToggle extends StatelessWidget {
  final VoidCallback onToggle;
  
  const PlatformToggle({Key? key, required this.onToggle}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Hanya tampilkan di mode debug
    if (!kDebugMode) return const SizedBox.shrink();
    
    return IconButton(
      icon: const Icon(Icons.phone_android),
      tooltip: 'Toggle Platform Design',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pilih Platform Design'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.android),
                  title: const Text('Material Design (Android)'),
                  onTap: () {
                    PlatformHelper.enableMaterialMode();
                    Navigator.pop(context);
                    onToggle();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.phone_iphone),
                  title: const Text('Cupertino Design (iOS)'),
                  onTap: () {
                    PlatformHelper.enableCupertinoMode();
                    Navigator.pop(context);
                    onToggle();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.devices),
                  title: const Text('Default (Auto-detect)'),
                  onTap: () {
                    PlatformHelper.resetPlatformMode();
                    Navigator.pop(context);
                    onToggle();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}