class Review {
  final String id;
  final String userId;
  final String recipeId;
  final double rating;
  final String comment;
  final String created;
  final String userName; // Diambil dari relasi users

  Review({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.rating,
    required this.comment,
    required this.created,
    required this.userName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final userData = json['expand']?['user_id'] ?? {}; // Ambil data dari ekspansi
    return Review(
      id: json['id'],
      userId: json['user_id'],
      recipeId: json['recipe_id'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      created: json['created'],
      userName: userData['name'] ?? 'Unknown User', // Ambil name dari users
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'recipe_id': recipeId,
      'rating': rating,
      'comment': comment,
      'created': created,
    };
  }
}