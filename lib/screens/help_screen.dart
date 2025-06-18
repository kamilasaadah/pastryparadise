// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/platform_helper.dart';
import '../widgets/adaptive_widgets.dart' as adaptive;
import '../theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildSocialMediaSection(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PlatformHelper.shouldUseMaterial 
                    ? Icons.connect_without_contact 
                    : CupertinoIcons.person_2_fill,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Connect With Us',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildSocialMediaItem(
            icon: PlatformHelper.shouldUseMaterial ? Icons.facebook : CupertinoIcons.globe,
            title: 'Facebook',
            subtitle: '@PastryParadise',
            color: const Color(0xFF1877F2),
            onTap: () => _launchUrl('https://facebook.com/pastryparadise'),
          ),
          
          _buildSocialMediaItem(
            icon: PlatformHelper.shouldUseMaterial ? Icons.camera_alt : CupertinoIcons.camera_fill,
            title: 'Instagram',
            subtitle: '@pastry_paradise',
            color: const Color(0xFFE4405F),
            onTap: () => _launchUrl('https://instagram.com/pastry_paradise'),
          ),
          
          _buildSocialMediaItem(
            icon: PlatformHelper.shouldUseMaterial ? Icons.alternate_email : CupertinoIcons.at,
            title: 'Twitter',
            subtitle: '@PastryParadise',
            color: const Color(0xFF1DA1F2),
            onTap: () => _launchUrl('https://twitter.com/pastryparadise'),
          ),
          
          _buildSocialMediaItem(
            icon: PlatformHelper.shouldUseMaterial ? Icons.play_circle_filled : CupertinoIcons.play_circle_fill,
            title: 'YouTube',
            subtitle: 'Pastry Paradise Channel',
            color: const Color(0xFFFF0000),
            onTap: () => _launchUrl('https://youtube.com/@pastryparadise'),
          ),
          
          _buildSocialMediaItem(
            icon: PlatformHelper.shouldUseMaterial ? Icons.email : CupertinoIcons.mail_solid,
            title: 'Email Support',
            subtitle: 'support@pastryparadise.com',
            color: AppTheme.primaryColor,
            onTap: () => _launchUrl('mailto:support@pastryparadise.com'),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: adaptive.AdaptiveGestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                PlatformHelper.shouldUseMaterial 
                    ? Icons.arrow_forward_ios 
                    : CupertinoIcons.chevron_right,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PlatformHelper.shouldUseMaterial 
                    ? Icons.help_outline 
                    : CupertinoIcons.question_circle,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildFAQItem(
            question: 'Bagaimana cara membuat resep baru?',
            answer: 'Tekan tombol "+" di layar utama dan isi detail resep termasuk bahan-bahan, instruksi, dan foto.',
            isDarkMode: isDarkMode,
          ),
          
          _buildFAQItem(
            question: 'Bisakah saya berbagi resep dengan orang lain?',
            answer: 'Ya! Anda dapat berbagi resep melalui media sosial, email, atau membuat tautan yang dapat dibagikan dari halaman detail resep.',
            isDarkMode: isDarkMode,
          ),
          
          _buildFAQItem(
            question: 'Bagaimana cara backup resep saya?',
            answer: 'Resep Anda secara otomatis disinkronkan ke cloud saat Anda login. Anda juga dapat mengekspor dari menu pengaturan.',
            isDarkMode: isDarkMode,
          ),
          
          _buildFAQItem(
            question: 'Apakah aplikasi ini gratis?',
            answer: 'Ya, Pastry Paradise sepenuhnya gratis digunakan dengan semua fitur tersedia tanpa biaya.',
            isDarkMode: isDarkMode,
          ),
          
          _buildFAQItem(
            question: 'Bagaimana cara menghapus akun saya?',
            answer: 'Anda dapat menghapus akun dari layar Profil. Harap dicatat bahwa tindakan ini tidak dapat dibatalkan.',
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = PlatformHelper.isDarkMode(context);

    return adaptive.AdaptiveScaffold(
      appBar: const adaptive.AdaptiveAppBar(
        title: 'Bantuan & Dukungan',
        leading: adaptive.AdaptiveBackButton(),
      ),
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
      body: adaptive.AdaptiveScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Icon(
                    PlatformHelper.shouldUseMaterial 
                        ? Icons.support_agent 
                        : CupertinoIcons.person_badge_plus,
                    size: 80,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kami Siap Membantu!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hubungi kami melalui media sosial atau lihat bagian FAQ di bawah ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Social Media Section
            _buildSocialMediaSection(isDarkMode),
            
            // FAQ Section
            _buildFAQSection(isDarkMode),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}