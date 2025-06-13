import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/platform_helper.dart';
import '../widgets/adaptive_widgets.dart' as adaptive;
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return adaptive.AdaptiveScaffold(
      appBar: const adaptive.AdaptiveAppBar(
        title: 'Pengaturan',
        automaticallyImplyLeading: true,
      ),
      body: Material(
        type: MaterialType.transparency,
        child: adaptive.AdaptiveScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tampilan
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Tampilan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto', // Terapkan font kustom
                    color: isDarkMode ? AppTheme.darkTextColor : AppTheme.textColor,
                  ),
                ),
              ),
              adaptive.AdaptiveListTile(
                leading: Icon(
                  isDarkMode
                      ? PlatformHelper.shouldUseMaterial
                          ? Icons.dark_mode
                          : CupertinoIcons.moon_fill
                      : PlatformHelper.shouldUseMaterial
                          ? Icons.light_mode
                          : CupertinoIcons.sun_max_fill,
                ),
                title: const Text(
                  'Mode Gelap',
                  style: TextStyle(fontFamily: 'Roboto'), // Terapkan font kustom
                ),
                subtitle: const Text(
                  'Mengubah tampilan aplikasi menjadi gelap',
                  style: TextStyle(fontFamily: 'Roboto'), // Terapkan font kustom
                ),
                trailing: adaptive.AdaptiveSwitch(
                  value: isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeColor: AppTheme.primaryColor,
                ),
              ),

              // Platform Switch (untuk testing)
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Pengujian Platform',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto', // Terapkan font kustom
                    color: isDarkMode ? AppTheme.darkTextColor : AppTheme.textColor,
                  ),
                ),
              ),
              adaptive.AdaptiveListTile(
                leading: const Icon(Icons.android),
                title: const Text(
                  'Mode Material (Android)',
                  style: TextStyle(fontFamily: 'Roboto'), // Terapkan font kustom
                ),
                trailing: adaptive.AdaptiveRadio<bool>(
                  value: true,
                  groupValue: PlatformHelper.shouldUseMaterial,
                  onChanged: (_) {
                    PlatformHelper.enableMaterialMode();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              adaptive.AdaptiveListTile(
                leading: const Icon(Icons.apple),
                title: const Text(
                  'Mode Cupertino (iOS)',
                  style: TextStyle(fontFamily: 'Roboto'), // Terapkan font kustom
                ),
                trailing: adaptive.AdaptiveRadio<bool>(
                  value: false,
                  groupValue: PlatformHelper.shouldUseMaterial,
                  onChanged: (_) {
                    PlatformHelper.enableCupertinoMode();
                    Navigator.of(context).pushReplacement(
                      CupertinoPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              adaptive.AdaptiveListTile(
                leading: const Icon(Icons.device_unknown),
                title: const Text(
                  'Mode Default (Berdasarkan Platform)',
                  style: TextStyle(fontFamily: 'Roboto'), // Terapkan font kustom
                ),
                trailing: adaptive.AdaptiveRadio<bool>(
                  value: PlatformHelper.isUsingDefaultMode,
                  groupValue: true,
                  onChanged: (_) {
                    PlatformHelper.resetPlatformMode();
                    Navigator.of(context).pushReplacement(
                      PlatformHelper.shouldUseMaterial
                          ? MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            )
                          : CupertinoPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                    );
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ),

              const Divider(),

              // Notifikasi
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Notifikasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto', // Terapkan font kustom
                    color: isDarkMode ? AppTheme.darkTextColor : AppTheme.textColor,
                  ),
                ),
              ),
              adaptive.AdaptiveListTile(
                leading: Icon(
                  PlatformHelper.shouldUseMaterial
                      ? Icons.notifications
                      : CupertinoIcons.bell_fill,
                ),
                title: const Text(
                  'Notifikasi Resep Baru',
                  style: TextStyle(fontFamily: 'Roboto'), // Terapkan font kustom
                ),
                subtitle: const Text(
                  'Dapatkan notifikasi saat ada resep baru',
                  style: TextStyle(fontFamily: 'Roboto'), // Terapkan font kustom
                ),
                trailing: adaptive.AdaptiveSwitch(
                  value: false, // Default value
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur notifikasi akan segera hadir!')),
                    );
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

