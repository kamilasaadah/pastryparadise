import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/notification_model.dart';
import '../utils/platform_helper.dart';
import '../widgets/adaptive_widgets.dart';
import '../theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Dummy data untuk notifikasi (bisa diganti dengan data dari database)
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 1,
      title: 'Resep Baru Tersedia!',
      message: 'Coba resep Croissant Cokelat terbaru kami.',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationModel(
      id: 2,
      title: 'Tips Mingguan',
      message: 'Pelajari cara membuat adonan puff pastry yang sempurna.',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    NotificationModel(
      id: 3,
      title: 'Pembaruan Aplikasi',
      message: 'Versi baru aplikasi Pastry Paradise telah dirilis.',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'Notifikasi',
        leading: IconButton(
          icon: Icon(
            PlatformHelper.shouldUseMaterial ? Icons.arrow_back : CupertinoIcons.back,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PlatformHelper.shouldUseMaterial
                        ? Icons.notifications_none
                        : CupertinoIcons.bell,
                    size: 80,
                    color: Theme.of(context).primaryColor.withAlpha(77),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada notifikasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Notifikasi akan muncul di sini saat tersedia.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      notification.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(notification.date),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withAlpha(51),
                      child: Icon(
                        PlatformHelper.shouldUseMaterial
                            ? Icons.notifications
                            : CupertinoIcons.bell,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(
                // ignore: deprecated_member_use
                color: AppTheme.mutedTextColor.withOpacity(0.3),
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays < 1) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else {
      return '${difference.inDays} hari lalu';
    }
  }
}