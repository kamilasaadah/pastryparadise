import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/tip.dart';
import '../services/database_helper.dart';
import '../utils/platform_helper.dart';
import '../widgets/adaptive_widgets.dart';
import '../theme/app_theme.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({Key? key}) : super(key: key);

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  List<Tip> _tips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tips = await DatabaseHelper.instance.getTips();
      if (!mounted) return;

      setState(() {
        _tips = tips;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading tips: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'Tips & Trik',
        leading: IconButton(
          icon: Icon(
            PlatformHelper.shouldUseMaterial ? Icons.arrow_back : CupertinoIcons.back,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: AdaptiveProgressIndicator())
          : _tips.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PlatformHelper.shouldUseMaterial
                            ? Icons.lightbulb_outline
                            : CupertinoIcons.lightbulb,
                        size: 80,
                        color: Theme.of(context).primaryColor.withAlpha(77),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada tips & trik',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tips baru akan ditambahkan segera.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tips.length,
                  itemBuilder: (context, index) {
                    final tip = _tips[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              tip.imageUrl,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported, size: 50),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tip.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tip.description,
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? AppTheme.darkMutedTextColor
                                        : Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}