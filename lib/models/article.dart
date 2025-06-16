class Article {
  final String id;
  final String title;
  final String description;
  final String image;
  final String readTime;
  final String category;
  final String content;
  final DateTime created;
  final DateTime updated;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.readTime,
    required this.category,
    required this.content,
    required this.created,
    required this.updated,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      readTime: json['readTime'] ?? '',
      category: json['category'] ?? '',
      content: json['content'] ?? '',
      created: DateTime.parse(json['created'] ?? DateTime.now().toIso8601String()),
      updated: DateTime.parse(json['updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'readTime': readTime,
      'category': category,
      'content': content,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  // Helper method untuk mendapatkan URL gambar lengkap dari PocketBase
  String getImageUrl(String baseUrl) {
    if (image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    return '$baseUrl/api/files/articles/$id/$image';
  }
}
