// ignore_for_file: avoid_print


// Script untuk menambahkan sample review data
// Jalankan dengan: dart run scripts/add_sample_reviews.dart

void main() async {
  print('=== ADDING SAMPLE REVIEWS TO POCKETBASE ===\n');
  
  const String pocketBaseUrl = 'http://127.0.0.1:8090';
  
  // Sample data - ganti dengan ID yang sesuai dari database Anda
  final sampleData = [
    {
      'recipe_title': 'Apple Turnovers',
      'recipe_id': 'RECIPE_ID_1', // Ganti dengan ID resep yang sebenarnya
      'user_id': 'USER_ID_1',     // Ganti dengan ID user yang sebenarnya
      'reviews': [
        {'rating': 4.5, 'comment': 'Sangat lezat! Pastry-nya renyah dan isian apelnya manis.'},
        {'rating': 5.0, 'comment': 'Resep terbaik yang pernah saya coba. Keluarga suka sekali!'},
        {'rating': 4.0, 'comment': 'Enak, tapi agak susah membuatnya untuk pemula.'},
        {'rating': 4.8, 'comment': 'Perfect untuk afternoon tea!'},
      ]
    },
    {
      'recipe_title': 'Baklava',
      'recipe_id': 'RECIPE_ID_2', // Ganti dengan ID resep yang sebenarnya
      'user_id': 'USER_ID_1',     // Ganti dengan ID user yang sebenarnya
      'reviews': [
        {'rating': 5.0, 'comment': 'Autentik dan sangat lezat! Seperti yang saya makan di Turki.'},
        {'rating': 4.5, 'comment': 'Manis dan renyah, tapi butuh waktu lama membuatnya.'},
        {'rating': 4.8, 'comment': 'Resep yang detail dan hasilnya memuaskan.'},
        {'rating': 4.2, 'comment': 'Anak-anak suka sekali dengan baklava ini.'},
        {'rating': 4.7, 'comment': 'Teksturnya sempurna, tidak terlalu manis.'},
      ]
    },
  ];
  
  print('MANUAL STEPS TO ADD REVIEWS:');
  print('1. Open PocketBase Admin Panel: $pocketBaseUrl/_/');
  print('2. Login to admin panel');
  print('3. Go to Collections > reviews');
  print('4. Click "New record" and add the following data:\n');
  
  for (final recipe in sampleData) {
    print('=== ${recipe['recipe_title']} ===');
    final reviews = recipe['reviews'] as List;
    
    for (int i = 0; i < reviews.length; i++) {
      final review = reviews[i];
      print('Review ${i + 1}:');
      print('  recipe_id: ${recipe['recipe_id']}');
      print('  user_id: ${recipe['user_id']}');
      print('  rating: ${review['rating']}');
      print('  comment: ${review['comment']}');
      print('  created: ${DateTime.now().toIso8601String()}');
      print('');
    }
  }
  
  print('\nNOTE: Make sure to replace RECIPE_ID_1, RECIPE_ID_2, and USER_ID_1 with actual IDs from your database!');
  print('\nAfter adding reviews, restart your Flutter app to see the ratings.');
}
