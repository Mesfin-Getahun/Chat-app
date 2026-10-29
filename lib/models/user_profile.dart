class UserProfile {
  final String id;
  final String name;
  final String avatar;
  final String city;
  final int utcOffsetHours;
  final String statusMessage;
  final bool isOnline;

  const UserProfile({
    required this.id,
    required this.name,
    required this.avatar,
    required this.city,
    required this.utcOffsetHours,
    this.statusMessage = 'Missing my bestie!',
    this.isOnline = true,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatar,
    String? city,
    int? utcOffsetHours,
    String? statusMessage,
    bool? isOnline,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      city: city ?? this.city,
      utcOffsetHours: utcOffsetHours ?? this.utcOffsetHours,
      statusMessage: statusMessage ?? this.statusMessage,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'city': city,
      'utcOffsetHours': utcOffsetHours,
      'statusMessage': statusMessage,
      'isOnline': isOnline,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? 'user_1',
      name: json['name'] as String? ?? 'Bestie',
      avatar: json['avatar'] as String? ?? '🦊',
      city: json['city'] as String? ?? 'New York',
      utcOffsetHours: json['utcOffsetHours'] as int? ?? -5,
      statusMessage: json['statusMessage'] as String? ?? 'Thinking of you!',
      isOnline: json['isOnline'] as bool? ?? true,
    );
  }
}
