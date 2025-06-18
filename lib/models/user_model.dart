class UserModel {
  final String id;
  final String email;
  final bool emailVisibility;
  final bool verified;
  final String name;
  final String? avatar;
  final bool emailVerified;
  final DateTime created;
  final DateTime updated;

  UserModel({
    required this.id,
    required this.email,
    required this.emailVisibility,
    required this.verified,
    required this.name,
    this.avatar,
    required this.emailVerified,
    required this.created,
    required this.updated,
  });

  // Factory constructor dari JSON (untuk PocketBase API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      emailVisibility: json['emailVisibility'] ?? false,
      verified: json['verified'] ?? false,
      name: json['name'] ?? '',
      avatar: json['avatar'],
      emailVerified: json['email_verified'] ?? false,
      created: DateTime.parse(json['created'] ?? DateTime.now().toIso8601String()),
      updated: DateTime.parse(json['updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Factory constructor dari Map (untuk DatabaseHelper data)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      emailVisibility: true,
      verified: false,
      name: map['name'] ?? '',
      avatar: map['profile_image'],
      emailVerified: false,
      created: DateTime.now(),
      updated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'emailVisibility': emailVisibility,
      'verified': verified,
      'name': name,
      'avatar': avatar,
      'email_verified': emailVerified,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_image': avatar,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    bool? emailVisibility,
    bool? verified,
    String? name,
    String? avatar,
    bool? emailVerified,
    DateTime? created,
    DateTime? updated,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      emailVisibility: emailVisibility ?? this.emailVisibility,
      verified: verified ?? this.verified,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      emailVerified: emailVerified ?? this.emailVerified,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  // Getter untuk kompatibilitas dengan kode lama
  String? get profileImage => avatar;

  String getAvatarUrl(String baseUrl) {
    if (avatar == null || avatar!.isEmpty) {
      final encodedName = Uri.encodeComponent(name);
      return 'https://ui-avatars.com/api/?name=$encodedName&background=6366f1&color=fff&size=200&rounded=true';
    }
    
    if (avatar!.startsWith('http')) {
      return avatar!;
    }
    
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return '$cleanBaseUrl/api/files/users/$id/$avatar';
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, avatar: $avatar)';
  }
}
