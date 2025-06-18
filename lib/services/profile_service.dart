// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class PocketBaseService {
  static const String baseUrl = String.fromEnvironment(
    'POCKETBASE_URL',
    defaultValue: 'http://127.0.0.1:8090',
  );

  static Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  static Future<String?> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id');
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  static Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userName = prefs.getString('user_name');
      final userEmail = prefs.getString('user_email');
      final profileImage = prefs.getString('profile_image');

      if (userId != null && userName != null && userEmail != null) {
        return UserModel.fromMap({
          'id': userId,
          'name': userName,
          'email': userEmail,
          'profile_image': profileImage,
        });
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Update user profile dengan debugging yang lebih detail untuk password
  static Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? password,
    XFile? avatarFile,
  }) async {
    try {
      print('🔄 Starting profile update...');
      print('  - User ID: $userId');
      print('  - Name: $name');
      print('  - Email: $email');
      print('  - Password change: ${password != null && password.isNotEmpty}');
      print('  - Has avatar: ${avatarFile != null}');

      final authToken = await _getAuthToken();
      if (authToken == null) {
        print('❌ No auth token available');
        return {
          'success': false,
          'message': 'Token autentikasi tidak ditemukan. Silakan login ulang.',
        };
      }

      // Test koneksi server dulu
      try {
        final testResponse = await http.get(
          Uri.parse('$baseUrl/api/health'),
        ).timeout(const Duration(seconds: 5));
        print('🏥 Server health: ${testResponse.statusCode}');
      } catch (e) {
        print('❌ Server connection failed: $e');
        return {
          'success': false,
          'message': 'Tidak dapat terhubung ke server. Periksa koneksi internet.',
        };
      }

      // Buat request
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/api/collections/users/records/$userId'),
      );

      // Headers
      request.headers['Authorization'] = 'Bearer $authToken';
      
      print('📤 Request headers: ${request.headers}');

      // Basic fields
      if (name != null && name.isNotEmpty) {
        request.fields['name'] = name;
        print('📝 Adding name: $name');
      }
      
      if (email != null && email.isNotEmpty) {
        request.fields['email'] = email;
        print('📧 Adding email: $email');
      }

      // Password handling - PocketBase memerlukan format khusus
      if (password != null && password.isNotEmpty) {
        print('🔐 Processing password change...');
        
        // Validasi password
        if (password.length < 6) {
          return {
            'success': false,
            'message': 'Password minimal 6 karakter',
          };
        }

        // PocketBase memerlukan password dan passwordConfirm
        request.fields['password'] = password;
        request.fields['passwordConfirm'] = password;
        print('🔐 Password fields added');
      }

      // Avatar file
      if (avatarFile != null) {
        print('📸 Processing avatar...');
        try {
          final bytes = await avatarFile.readAsBytes();
          print('  - File size: ${bytes.length} bytes');
          
          // Validasi ukuran (max 5MB)
          if (bytes.length > 5 * 1024 * 1024) {
            return {
              'success': false,
              'message': 'Ukuran file terlalu besar. Maksimal 5MB.',
            };
          }

          // Validasi format
          final fileName = avatarFile.name.toLowerCase();
          final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
          if (!validExtensions.any((ext) => fileName.endsWith(ext))) {
            return {
              'success': false,
              'message': 'Format file tidak didukung. Gunakan JPG, PNG, atau GIF.',
            };
          }

          request.files.add(
            http.MultipartFile.fromBytes(
              'avatar',
              bytes,
              filename: avatarFile.name,
            ),
          );
          print('✅ Avatar file added');
        } catch (e) {
          print('❌ Error processing avatar: $e');
          return {
            'success': false,
            'message': 'Error memproses gambar: $e',
          };
        }
      }

      print('📋 Final request fields: ${request.fields}');
      print('🚀 Sending request...');

      // Send request dengan timeout yang lebih panjang
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - server tidak merespons');
        },
      );

      print('📥 Response status: ${response.statusCode}');
      final responseBody = await response.stream.bytesToString();
      print('📄 Response body: $responseBody');

      if (response.statusCode == 200) {
        print('✅ Update successful');
        
        try {
          final updatedData = json.decode(responseBody);
          
          // Update local storage
          final prefs = await SharedPreferences.getInstance();
          
          if (name != null) {
            await prefs.setString('user_name', updatedData['name'] ?? name);
          }
          if (email != null) {
            await prefs.setString('user_email', updatedData['email'] ?? email);
          }
          
          // Update avatar URL
          if (updatedData['avatar'] != null && updatedData['avatar'].isNotEmpty) {
            final avatarUrl = '$baseUrl/api/files/users/$userId/${updatedData['avatar']}';
            await prefs.setString('profile_image', avatarUrl);
          }
          
          return {
            'success': true,
            'message': 'Profile berhasil diperbarui!',
          };
        } catch (e) {
          print('❌ Error parsing success response: $e');
          return {
            'success': false,
            'message': 'Update berhasil tapi ada error parsing data',
          };
        }
      } else {
        print('❌ Update failed: ${response.statusCode}');
        
        // Parse error response
        try {
          final errorData = json.decode(responseBody);
          print('🔍 Error data: $errorData');
          
          String errorMessage = 'Gagal memperbarui profile';
          
          // Handle specific PocketBase errors
          if (errorData['data'] != null) {
            final data = errorData['data'] as Map<String, dynamic>;
            
            if (data['password'] != null) {
              errorMessage = 'Error password: ${data['password']['message'] ?? 'Password tidak valid'}';
            } else if (data['email'] != null) {
              errorMessage = 'Error email: ${data['email']['message'] ?? 'Email tidak valid'}';
            } else if (data['name'] != null) {
              errorMessage = 'Error nama: ${data['name']['message'] ?? 'Nama tidak valid'}';
            } else {
              errorMessage = errorData['message'] ?? 'Error tidak diketahui';
            }
          } else if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
          
          return {
            'success': false,
            'message': errorMessage,
          };
        } catch (e) {
          print('🔍 Could not parse error response: $e');
          
          // Handle common HTTP status codes
          String errorMessage;
          switch (response.statusCode) {
            case 400:
              errorMessage = 'Data yang dikirim tidak valid';
              break;
            case 401:
              errorMessage = 'Sesi login telah berakhir. Silakan login ulang';
              break;
            case 403:
              errorMessage = 'Tidak memiliki izin untuk mengubah data';
              break;
            case 404:
              errorMessage = 'User tidak ditemukan';
              break;
            case 500:
              errorMessage = 'Error server. Coba lagi nanti';
              break;
            default:
              errorMessage = 'Error tidak diketahui (${response.statusCode})';
          }
          
          return {
            'success': false,
            'message': errorMessage,
          };
        }
      }
    } catch (e) {
      print('❌ Exception during update: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<bool> deleteUserAccount(String userId) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/api/collections/users/records/$userId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        return true;
      }
    } catch (e) {
      print('Error deleting account: $e');
    }
    return false;
  }

  static Future<Map<String, dynamic>?> refreshUserData() async {
    try {
      final authToken = await _getAuthToken();
      final userId = await _getCurrentUserId();
      
      if (authToken == null || userId == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/collections/users/records/$userId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', userData['name'] ?? '');
        await prefs.setString('user_email', userData['email'] ?? '');
        
        String profileImageUrl;
        if (userData['avatar'] != null && userData['avatar'].isNotEmpty) {
          profileImageUrl = '$baseUrl/api/files/users/$userId/${userData['avatar']}';
        } else {
          profileImageUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userData['name'] ?? 'User')}&background=6366f1&color=fff&size=200&rounded=true';
        }
        await prefs.setString('profile_image', profileImageUrl);
        
        return {
          'id': userData['id'],
          'name': userData['name'],
          'email': userData['email'],
          'profile_image': profileImageUrl,
        };
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
    return null;
  }
}
