import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../services/database_helper.dart';
import '../providers/theme_provider.dart';
import '../utils/platform_helper.dart';
import '../widgets/adaptive_widgets.dart' as adaptive;
import '../theme/app_theme.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await DatabaseHelper.instance.getCurrentUser();

      if (!mounted) return;

      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }

  void _showLogoutDialog() {
    adaptive.showAdaptiveAlertDialog(
      context: context,
      title: 'Logout',
      content: 'Apakah Anda yakin ingin keluar?',
      cancelText: 'Batal',
      confirmText: 'Logout',
      onCancel: () {},
      onConfirm: () async {
        await DatabaseHelper.instance.logoutUser();

        if (!mounted) return;

        Navigator.pushReplacementNamed(context, '/login');
      },
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      adaptive.adaptivePageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return adaptive.AdaptiveScaffold(
      appBar: const adaptive.AdaptiveAppBar(
        title: 'Profil Saya',
      ),
      body: _isLoading
          ? const Center(child: adaptive.AdaptiveProgressIndicator())
          : adaptive.AdaptiveScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      _userData?['profile_image'] ??
                          'https://randomuser.me/api/portraits/men/32.jpg',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userData?['name'] ?? 'Pengguna Pastry',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: isDarkMode
                          ? AppTheme.darkTextColor
                          : AppTheme.textColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Text(
                    _userData?['email'] ?? 'pengguna@email.com',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      color: isDarkMode
                          ? AppTheme.darkMutedTextColor
                          : AppTheme.mutedTextColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 32),
                  adaptive.AdaptiveListTile(
                    leading: Icon(
                      PlatformHelper.shouldUseMaterial
                          ? Icons.person
                          : CupertinoIcons.person_fill,
                    ),
                    title: Text(
                      'Edit Profil',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? AppTheme.darkTextColor
                            : AppTheme.textColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    trailing: Icon(
                      PlatformHelper.shouldUseMaterial
                          ? Icons.arrow_forward_ios
                          : CupertinoIcons.chevron_right,
                      size: 16,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur Edit Profil akan segera hadir!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  adaptive.AdaptiveListTile(
                    leading: Icon(
                      PlatformHelper.shouldUseMaterial
                          ? Icons.favorite
                          : CupertinoIcons.heart_fill,
                    ),
                    title: Text(
                      'Resep Favorit',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? AppTheme.darkTextColor
                            : AppTheme.textColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    trailing: Icon(
                      PlatformHelper.shouldUseMaterial
                          ? Icons.arrow_forward_ios
                          : CupertinoIcons.chevron_right,
                      size: 16,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur Resep Favorit akan segera hadir!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  adaptive.AdaptiveListTile(
                    leading: Icon(
                      PlatformHelper.shouldUseMaterial
                          ? Icons.history
                          : CupertinoIcons.clock_fill,
                    ),
                    title: Text(
                      'Riwayat',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? AppTheme.darkTextColor
                            : AppTheme.textColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    trailing: Icon(
                      PlatformHelper.shouldUseMaterial
                          ? Icons.arrow_forward_ios
                          : CupertinoIcons.chevron_right,
                      size: 16,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur Riwayat akan segera hadir!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  adaptive.AdaptiveListTile(
                    leading: Icon(
                      PlatformHelper.shouldUseMaterial
                          ? (isDarkMode ? Icons.dark_mode : Icons.light_mode)
                          : (isDarkMode
                              ? CupertinoIcons.moon_fill
                              : CupertinoIcons.sun_max_fill),
                    ),
                    title: Text(
                      'Tema Aplikasi',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? AppTheme.darkTextColor
                            : AppTheme.textColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    trailing: adaptive.AdaptiveSwitch(
                      value: isDarkMode,
                      onChanged: (_) {
                        themeProvider.toggleTheme();
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),
                  adaptive.AdaptiveListTile(
                    leading: Icon(
                      PlatformHelper.shouldUseMaterial
                          ? Icons.settings
                          : CupertinoIcons.settings_solid,
                    ),
                    title: Text(
                      'Pengaturan Lainnya',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? AppTheme.darkTextColor
                            : AppTheme.textColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    trailing: Icon(
                      PlatformHelper.shouldUseMaterial
                          ? Icons.arrow_forward_ios
                          : CupertinoIcons.chevron_right,
                      size: 16,
                    ),
                    onTap: _navigateToSettings,
                  ),
                  adaptive.AdaptiveListTile(
                    leading: Icon(
                      PlatformHelper.shouldUseMaterial
                          ? Icons.help
                          : CupertinoIcons.question_circle_fill,
                    ),
                    title: Text(
                      'Bantuan',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? AppTheme.darkTextColor
                            : AppTheme.textColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    trailing: Icon(
                      PlatformHelper.shouldUseMaterial
                          ? Icons.arrow_forward_ios
                          : CupertinoIcons.chevron_right,
                      size: 16,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur Bantuan akan segera hadir!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  adaptive.AdaptiveListTile(
                    leading: Icon(
                      PlatformHelper.shouldUseMaterial
                          ? Icons.exit_to_app
                          : CupertinoIcons.square_arrow_right,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ),
    );
  }
}