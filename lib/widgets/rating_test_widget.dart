import 'package:flutter/material.dart';
import 'star_rating.dart';

class RatingTestPage extends StatelessWidget {
  const RatingTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rating Test'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Star Rating Tests:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            _buildRatingTest('Rating 0.0 (No reviews)', 0.0, 0),
            _buildRatingTest('Rating 1.5 (3 reviews)', 1.5, 3),
            _buildRatingTest('Rating 2.7 (12 reviews)', 2.7, 12),
            _buildRatingTest('Rating 3.0 (8 reviews)', 3.0, 8),
            _buildRatingTest('Rating 4.2 (25 reviews)', 4.2, 25),
            _buildRatingTest('Rating 4.8 (47 reviews)', 4.8, 47),
            _buildRatingTest('Rating 5.0 (15 reviews)', 5.0, 15),
            
            const SizedBox(height: 30),
            const Text(
              'Different Sizes:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            _buildSizeTest('Size 12', 4.5, 12),
            _buildSizeTest('Size 16', 4.5, 16),
            _buildSizeTest('Size 20', 4.5, 20),
            _buildSizeTest('Size 24', 4.5, 24),
            
            const SizedBox(height: 30),
            const Text(
              'Different Colors:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            _buildColorTest('Default (Amber)', 4.5, null),
            _buildColorTest('Red', 4.5, Colors.red),
            _buildColorTest('Blue', 4.5, Colors.blue),
            _buildColorTest('Green', 4.5, Colors.green),
            _buildColorTest('Purple', 4.5, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingTest(String label, double rating, int reviewCount) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          StarRating(
            rating: rating,
            size: 16,
            showRatingText: true,
            reviewCount: reviewCount,
          ),
        ],
      ),
    );
  }

  Widget _buildSizeTest(String label, double rating, double size) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          StarRating(
            rating: rating,
            size: size,
            showRatingText: true,
            reviewCount: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildColorTest(String label, double rating, Color? color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          StarRating(
            rating: rating,
            size: 16,
            activeColor: color,
            showRatingText: true,
            reviewCount: 10,
          ),
        ],
      ),
    );
  }
}
