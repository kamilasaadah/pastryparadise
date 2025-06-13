import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/database_helper.dart';

class ReviewCard extends StatefulWidget {
  final Review review;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onRefresh;

  const ReviewCard({
    Key? key,
    required this.review,
    required this.onDelete,
    required this.onEdit,
    required this.onRefresh,
  }) : super(key: key);

  @override
  ReviewCardState createState() => ReviewCardState();
}

class ReviewCardState extends State<ReviewCard> {
  late TextEditingController _ratingController;
  late TextEditingController _commentController;
  bool _isModalOpen = false;
  late String _userName;

  @override
  void initState() {
    super.initState();
    _ratingController = TextEditingController(text: widget.review.rating.toString());
    _commentController = TextEditingController(text: widget.review.comment);
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await DatabaseHelper.instance.getUserName(widget.review.userId);
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  @override
  void dispose() {
    _ratingController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _saveReview(String? reviewId) async {
    final rating = double.tryParse(_ratingController.text) ?? 0.0;
    final comment = _commentController.text.trim();
    if (rating > 0 && comment.isNotEmpty) {
      if (reviewId == null) {
        final success = await DatabaseHelper.instance.createReview(widget.review.recipeId, rating, comment);
        if (success) {
          _closeModal();
          widget.onRefresh();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to create review')),
            );
          }
        }
      } else {
        final success = await DatabaseHelper.instance.updateReview(reviewId, rating, comment);
        if (success) {
          _closeModal();
          widget.onRefresh();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update review')),
            );
          }
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid rating and comment')),
        );
      }
    }
  }

  void _closeModal() {
    setState(() {
      _isModalOpen = false;
      _ratingController.clear();
      _commentController.clear();
    });
  }

  String _formatDateTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _userName.isEmpty ? 'Loading...' : _userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _ratingController.text = widget.review.rating.toString();
                        _commentController.text = widget.review.comment;
                        setState(() {
                          _isModalOpen = true;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: widget.onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Rating: ${widget.review.rating}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(widget.review.comment),
            const SizedBox(height: 8),
            Text(
              _formatDateTime(widget.review.created),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (_isModalOpen)
              GestureDetector(
                onTap: _closeModal,
                child: Container(
                  color: Colors.black54,
                ),
              ),
            if (_isModalOpen)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _ratingController,
                        decoration: const InputDecoration(labelText: 'Rating (0.0-5.0)'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(labelText: 'Comment'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _closeModal,
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _saveReview(widget.review.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}