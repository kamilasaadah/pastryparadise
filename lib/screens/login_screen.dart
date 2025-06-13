import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';
import '../utils/platform_helper.dart';
import '../widgets/adaptive_widgets.dart';
import '../services/database_helper.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final String _pocketBaseUrl = 'http://127.0.0.1:8090';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('$_pocketBaseUrl/api/collections/users/auth-with-password'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'identity': _emailController.text.trim(),
            'password': _passwordController.text.trim(),
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final userData = responseData['record'];
          final authToken = responseData['token'];

          // Simpan data pengguna ke DatabaseHelper
          await DatabaseHelper.instance.saveUserData({
            'id': userData['id'],
            'name': userData['name'],
            'email': userData['email'],
            'token': authToken,
            'profile_image': userData['profile_image'] ?? 'https://randomuser.me/api/portraits/men/32.jpg',
          });

          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            adaptivePageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          final errorData = jsonDecode(response.body);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Login failed: ${errorData['message'] ?? 'Invalid email or password'}',
              ),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  Image.network(
                    'https://cdn-icons-png.flaticon.com/512/1046/1046857.png',
                    height: 120,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to your account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.darkMutedTextColor
                          : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  AdaptiveTextField(
                    placeholder: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefix: Icon(
                      PlatformHelper.shouldUseMaterial
                          ? Icons.email
                          : CupertinoIcons.mail,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AdaptiveTextField(
                    placeholder: 'Password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefix: Icon(
                      PlatformHelper.shouldUseMaterial
                          ? Icons.lock
                          : CupertinoIcons.lock,
                    ),
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? (PlatformHelper.shouldUseMaterial
                                ? Icons.visibility
                                : CupertinoIcons.eye)
                            : (PlatformHelper.shouldUseMaterial
                                ? Icons.visibility_off
                                : CupertinoIcons.eye_slash),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Forgot password functionality will be implemented soon'),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AdaptiveButton(
                    label: 'Login',
                    onPressed: _isLoading ? null : _login,
                    isPrimary: true,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkMutedTextColor
                            : Colors.grey[700],
                      ),
                      children: [
                        TextSpan(
                          text: 'Register',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).pushReplacement(
                                adaptivePageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                        ),
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
}