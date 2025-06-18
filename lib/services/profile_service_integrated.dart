import '../models/user_model.dart';
import 'database_helper.dart';
import 'profile_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  // Get current user (menggunakan DatabaseHelper yang sudah ada)
  static Future<UserModel?> getCurrentUser() async {
    try {
      final userData = await DatabaseHelper.instance.getCurrentUser();
      
      if (userData != null) {
        final user = UserModel.fromMap(userData);
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile (menggunakan PocketBaseService untuk file upload)
  static Future<bool> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    XFile? avatarFile,
  }) async {
    try {
      // Gunakan PocketBaseService untuk update
      final success = await PocketBaseService.updateUserProfile(
        userId: userId,
        name: name,
        email: email,
        avatarFile: avatarFile,
      );

      // ignore: unrelated_type_equality_checks
      if (success == true) {
        // Refresh data dari server untuk memastikan sinkronisasi
        await PocketBaseService.refreshUserData();
      }

      // ignore: unrelated_type_equality_checks
      return success == true;
    } catch (e) {
      return false;
    }
  }

  // Delete user account (menggunakan PocketBaseService)
  static Future<bool> deleteUserAccount(String userId) async {
    try {
      return await PocketBaseService.deleteUserAccount(userId);
    } catch (e) {
      return false;
    }
  }

  // Logout (menggunakan DatabaseHelper)
  static Future<void> logout() async {
    try {
      await DatabaseHelper.instance.logoutUser();
    // ignore: empty_catches
    } catch (e) {
    }
  }

  // Refresh user data from server
  static Future<UserModel?> refreshUserData() async {
    try {
      final userData = await PocketBaseService.refreshUserData();
      if (userData != null) {
        return UserModel.fromMap(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}