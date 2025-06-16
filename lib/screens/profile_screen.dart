// ignore_for_file: deprecated_member_use

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

class ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserData();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    ));
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

      // Start animations after data is loaded
      _animationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _cardAnimationController.forward();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showErrorSnackBar('Error loading user data: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
        try {
          await DatabaseHelper.instance.logoutUser();
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/login');
        } catch (e) {
          _showErrorSnackBar('Error during logout: $e');
        }
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

  Widget _buildGradientHeader(bool isDarkMode) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  AppTheme.primaryColor.withOpacity(0.8),
                  AppTheme.primaryColor.withOpacity(0.6),
                  Colors.deepPurple.withOpacity(0.4),
                ]
              : [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                  Colors.blue.withOpacity(0.6),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: NetworkImage(
                          _userData?['profile_image'] ??
                              'https://randomuser.me/api/portraits/men/32.jpg',
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _userData?['name'] ?? 'Pengguna Pastry',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    color: isDarkMode ? AppTheme.darkTextColor : AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userData?['email'] ?? 'pengguna@email.com',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    color: isDarkMode ? AppTheme.darkMutedTextColor : AppTheme.mutedTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Resep', '24', Icons.restaurant_menu, isDarkMode),
                    _buildStatCard('Favorit', '12', Icons.favorite, isDarkMode),
                    _buildStatCard('Dibuat', '8', Icons.timeline, isDarkMode),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.darkTextColor : AppTheme.textColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? AppTheme.darkMutedTextColor : AppTheme.mutedTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
    int delay = 0,
  }) {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            50 * (1 - _cardAnimationController.value) * (delay + 1),
          ),
          child: Opacity(
            opacity: _cardAnimationController.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? (isDarkMode ? AppTheme.darkTextColor : AppTheme.textColor),
                  ),
                ),
                trailing: trailing ??
                    Icon(
                      PlatformHelper.shouldUseMaterial
                          ? Icons.arrow_forward_ios
                          : CupertinoIcons.chevron_right,
                      size: 16,
                      color: isDarkMode ? AppTheme.darkMutedTextColor : AppTheme.mutedTextColor,
                    ),
                onTap: onTap,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return adaptive.AdaptiveScaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
      body: _isLoading
          ? const Center(child: adaptive.AdaptiveProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Gradient Header
                      _buildGradientHeader(isDarkMode),
                      
                      // Profile Card with overlap
                      Transform.translate(
                        offset: const Offset(0, -60),
                        child: Column(
                          children: [
                            _buildProfileCard(isDarkMode),
                            const SizedBox(height: 30),
                            
                            // Menu Items
                            _buildEnhancedMenuItem(
                              icon: PlatformHelper.shouldUseMaterial ? Icons.person : CupertinoIcons.person_fill,
                              title: 'Edit Profil',
                              isDarkMode: isDarkMode,
                              delay: 0,
                              onTap: () => _showSuccessSnackBar('Fitur Edit Profil akan segera hadir!'),
                            ),
                            
                            _buildEnhancedMenuItem(
                              icon: PlatformHelper.shouldUseMaterial ? Icons.favorite : CupertinoIcons.heart_fill,
                              title: 'Resep Favorit',
                              isDarkMode: isDarkMode,
                              delay: 1,
                              onTap: () => _showSuccessSnackBar('Fitur Resep Favorit akan segera hadir!'),
                            ),
                            
                            _buildEnhancedMenuItem(
                              icon: PlatformHelper.shouldUseMaterial ? Icons.history : CupertinoIcons.clock_fill,
                              title: 'Riwayat',
                              isDarkMode: isDarkMode,
                              delay: 2,
                              onTap: () => _showSuccessSnackBar('Fitur Riwayat akan segera hadir!'),
                            ),
                            
                            _buildEnhancedMenuItem(
                              icon: isDarkMode 
                                  ? (PlatformHelper.shouldUseMaterial ? Icons.dark_mode : CupertinoIcons.moon_fill)
                                  : (PlatformHelper.shouldUseMaterial ? Icons.light_mode : CupertinoIcons.sun_max_fill),
                              title: 'Tema Aplikasi',
                              isDarkMode: isDarkMode,
                              delay: 3,
                              trailing: adaptive.AdaptiveSwitch(
                                value: isDarkMode,
                                onChanged: (_) => themeProvider.toggleTheme(),
                                activeColor: AppTheme.primaryColor,
                              ),
                              onTap: () => themeProvider.toggleTheme(),
                            ),
                            
                            _buildEnhancedMenuItem(
                              icon: PlatformHelper.shouldUseMaterial ? Icons.settings : CupertinoIcons.settings_solid,
                              title: 'Pengaturan Lainnya',
                              isDarkMode: isDarkMode,
                              delay: 4,
                              onTap: _navigateToSettings,
                            ),
                            
                            _buildEnhancedMenuItem(
                              icon: PlatformHelper.shouldUseMaterial ? Icons.help : CupertinoIcons.question_circle_fill,
                              title: 'Bantuan',
                              isDarkMode: isDarkMode,
                              delay: 5,
                              onTap: () => _showSuccessSnackBar('Fitur Bantuan akan segera hadir!'),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Logout with special styling
                            _buildEnhancedMenuItem(
                              icon: PlatformHelper.shouldUseMaterial ? Icons.exit_to_app : CupertinoIcons.square_arrow_right,
                              title: 'Logout',
                              isDarkMode: isDarkMode,
                              delay: 6,
                              iconColor: Colors.red,
                              textColor: Colors.red,
                              trailing: null,
                              onTap: _showLogoutDialog,
                            ),
                            
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }
}