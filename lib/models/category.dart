class Category {
  final String id;
  final String title;
  final String? image;
  final DateTime? created;
  final DateTime? updated;

  Category({
    required this.id,
    required this.title,
    this.image,
    this.created,
    this.updated,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString(),
      created: json['created'] != null ? DateTime.tryParse(json['created']) : null,
      updated: json['updated'] != null ? DateTime.tryParse(json['updated']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }
}
