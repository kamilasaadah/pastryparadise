// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../services/profile_service.dart';
import '../models/user_model.dart';
import '../providers/theme_provider.dart';
import '../utils/platform_helper.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  UserModel? _currentUser;
  XFile? _selectedImage;
  Uint8List? _webImageBytes;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isChangingPassword = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await PocketBaseService.getCurrentUser();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _nameController.text = user.name;
          _emailController.text = user.email;
        });
        _animationController.forward();
      }
    } catch (e) {
      _showErrorSnackBar('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() => _selectedImage = image);
        
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() => _webImageBytes = bytes);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error memilih gambar: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _currentUser == null) return;

    // Validasi password jika sedang mengubah password
    if (_isChangingPassword) {
      if (_passwordController.text.trim().isEmpty) {
        _showErrorSnackBar('Password tidak boleh kosong');
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        _showErrorSnackBar('Password dan konfirmasi password tidak sama');
        return;
      }
      if (_passwordController.text.length < 6) {
        _showErrorSnackBar('Password minimal 6 karakter');
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      print('🔄 Calling updateUserProfile...');
      final result = await PocketBaseService.updateUserProfile(
        userId: _currentUser!.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _isChangingPassword ? _passwordController.text.trim() : null,
        avatarFile: _selectedImage,
      );

      print('📥 Update result: $result');

      if (result['success'] == true) {
        _showSuccessSnackBar(result['message'] ?? 'Profile berhasil diperbarui!');
        
        // Clear password fields after successful update
        if (_isChangingPassword) {
          _passwordController.clear();
          _confirmPasswordController.clear();
          setState(() => _isChangingPassword = false);
        }
        
        // Delay sebentar sebelum kembali
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showErrorSnackBar(result['message'] ?? 'Gagal memperbarui profile');
      }
    } catch (e) {
      print('❌ Exception in _saveProfile: $e');
      _showErrorSnackBar('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              PlatformHelper.shouldUseMaterial ? Icons.error_outline : CupertinoIcons.exclamationmark_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              PlatformHelper.shouldUseMaterial ? Icons.check_circle_outline : CupertinoIcons.checkmark_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      if (kIsWeb) {
        return _webImageBytes != null
            ? ClipOval(
                child: Image.memory(
                  _webImageBytes!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              )
            : const CircularProgressIndicator();
      } else {
        return ClipOval(
          child: Image.file(
            File(_selectedImage!.path),
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    
    if (_currentUser?.profileImage != null) {
      return ClipOval(
        child: Image.network(
          _currentUser!.getAvatarUrl(PocketBaseService.baseUrl),
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              PlatformHelper.shouldUseMaterial ? Icons.person : CupertinoIcons.person_fill,
              size: 60,
              color: Colors.grey.shade600,
            );
          },
        ),
      );
    }
    
    return Icon(
      PlatformHelper.shouldUseMaterial ? Icons.person : CupertinoIcons.person_fill,
      size: 60,
      color: Colors.grey.shade600,
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
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                PlatformHelper.shouldUseMaterial ? Icons.arrow_back : CupertinoIcons.back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          // Save button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: _isSaving
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: _saveProfile,
                    child: const Text(
                      'Simpan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
          // Title
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: const Text(
              'Edit Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(bool isDarkMode) {
    return Container(
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
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  child: _buildImagePreview(),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
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
                    child: Icon(
                      PlatformHelper.shouldUseMaterial ? Icons.camera_alt : CupertinoIcons.camera_fill,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tap untuk mengubah foto',
            style: TextStyle(
              color: isDarkMode ? AppTheme.darkMutedTextColor : AppTheme.mutedTextColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
    bool isDarkMode = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(
          color: isDarkMode ? AppTheme.darkTextColor : AppTheme.textColor,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDarkMode ? AppTheme.darkMutedTextColor : AppTheme.mutedTextColor,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          suffixIcon: onToggleVisibility != null
              ? IconButton(
                  onPressed: onToggleVisibility,
                  icon: Icon(
                    obscureText
                        ? (PlatformHelper.shouldUseMaterial ? Icons.visibility : CupertinoIcons.eye)
                        : (PlatformHelper.shouldUseMaterial ? Icons.visibility_off : CupertinoIcons.eye_slash),
                    color: isDarkMode ? AppTheme.darkMutedTextColor : AppTheme.mutedTextColor,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Gradient Header
                        _buildGradientHeader(isDarkMode),
                        
                        // Avatar Section with overlap
                        Transform.translate(
                          offset: const Offset(0, -60),
                          child: Column(
                            children: [
                              _buildAvatarSection(isDarkMode),
                              const SizedBox(height: 30),
                              
                              // Form Fields
                              _buildFormField(
                                label: 'Nama Lengkap',
                                controller: _nameController,
                                icon: PlatformHelper.shouldUseMaterial ? Icons.person_outline : CupertinoIcons.person,
                                isDarkMode: isDarkMode,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Silakan masukkan nama Anda';
                                  }
                                  return null;
                                },
                              ),
                              
                              _buildFormField(
                                label: 'Email',
                                controller: _emailController,
                                icon: PlatformHelper.shouldUseMaterial ? Icons.email_outlined : CupertinoIcons.mail,
                                keyboardType: TextInputType.emailAddress,
                                isDarkMode: isDarkMode,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Silakan masukkan email Anda';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return 'Silakan masukkan email yang valid';
                                  }
                                  return null;
                                },
                              ),
                              
                              // Password Change Toggle
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                                child: SwitchListTile(
                                  title: Text(
                                    'Ubah Password',
                                    style: TextStyle(
                                      color: isDarkMode ? AppTheme.darkTextColor : AppTheme.textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Aktifkan untuk mengubah password',
                                    style: TextStyle(
                                      color: isDarkMode ? AppTheme.darkMutedTextColor : AppTheme.mutedTextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  value: _isChangingPassword,
                                  onChanged: (value) {
                                    setState(() {
                                      _isChangingPassword = value;
                                      if (!value) {
                                        _passwordController.clear();
                                        _confirmPasswordController.clear();
                                      }
                                    });
                                  },
                                  activeColor: AppTheme.primaryColor,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                ),
                              ),
                              
                              // Password Fields (conditional)
                              if (_isChangingPassword) ...[
                                _buildFormField(
                                  label: 'Password Baru',
                                  controller: _passwordController,
                                  icon: PlatformHelper.shouldUseMaterial ? Icons.lock_outline : CupertinoIcons.lock,
                                  obscureText: _obscurePassword,
                                  isDarkMode: isDarkMode,
                                  onToggleVisibility: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                  validator: (value) {
                                    if (_isChangingPassword && (value == null || value.trim().isEmpty)) {
                                      return 'Silakan masukkan password baru';
                                    }
                                    if (_isChangingPassword && value!.length < 6) {
                                      return 'Password minimal 6 karakter';
                                    }
                                    return null;
                                  },
                                ),
                                
                                _buildFormField(
                                  label: 'Konfirmasi Password',
                                  controller: _confirmPasswordController,
                                  icon: PlatformHelper.shouldUseMaterial ? Icons.lock_outline : CupertinoIcons.lock,
                                  obscureText: _obscureConfirmPassword,
                                  isDarkMode: isDarkMode,
                                  onToggleVisibility: () {
                                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                  },
                                  validator: (value) {
                                    if (_isChangingPassword && (value == null || value.trim().isEmpty)) {
                                      return 'Silakan konfirmasi password';
                                    }
                                    if (_isChangingPassword && value != _passwordController.text) {
                                      return 'Password tidak sama';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              
                              const SizedBox(height: 30),
                              
                              // Save Button
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Simpan Perubahan',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
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
            ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
