class Tip {
  final int id;
  final String title;
  final String description;
  final String imageUrl;

  Tip({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
    );
  }
}