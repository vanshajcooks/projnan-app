class UserModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String role; // 'student' or 'teacher'
  final String? avatar;
  final int xp;
  final int points;
  final String? rank;
  final String? bio;
  final String? githubUsername;
  final bool emailVerified;
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
    this.avatar,
    this.xp = 0,
    this.points = 0,
    this.rank,
    this.bio,
    this.githubUsername,
    this.emailVerified = false,
    this.createdAt,
  });

  bool get isTeacher => role.toLowerCase() == 'teacher';
  bool get isStudent => role.toLowerCase() == 'student';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
      avatar: json['avatar'] as String?,
      xp: json['xp'] is int ? json['xp'] as int : int.tryParse(json['xp']?.toString() ?? '0') ?? 0,
      points: json['points'] is int ? json['points'] as int : int.tryParse(json['points']?.toString() ?? '0') ?? 0,
      rank: json['rank'] as String?,
      bio: json['bio'] as String?,
      githubUsername: json['github_username'] as String?,
      emailVerified: json['email_verified'] == 1 || json['email_verified'] == true,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'avatar': avatar,
      'xp': xp,
      'points': points,
      'rank': rank,
      'bio': bio,
      'github_username': githubUsername,
      'email_verified': emailVerified ? 1 : 0,
      'created_at': createdAt,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    String? role,
    String? avatar,
    int? xp,
    int? points,
    String? rank,
    String? bio,
    String? githubUsername,
    bool? emailVerified,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      xp: xp ?? this.xp,
      points: points ?? this.points,
      rank: rank ?? this.rank,
      bio: bio ?? this.bio,
      githubUsername: githubUsername ?? this.githubUsername,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
