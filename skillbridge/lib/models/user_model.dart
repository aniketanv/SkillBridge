import 'package:cloud_firestore/cloud_firestore.dart';


class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String profilePhotoUrl;
  final String role;
  final DateTime createdAt;
  final String bio;
  final List<String> hobbies;
  final int credits;
  final double averageRating;
  final int totalRatings;
  final int skillsTaughtCount;
  final List<String> savedSkills;
  final List<String> blockedUsers;

  UserModel({
    required this.id,
    required this.name,
    this.username = '',
    required this.email,
    this.profilePhotoUrl = '',
    this.role = 'user',
    required this.createdAt,
    this.bio = '',
    this.hobbies = const [],
    this.credits = 20,
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.skillsTaughtCount = 0,
    this.savedSkills = const [],
    this.blockedUsers = const [],
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'username': username,
      'email': email,
      'profilePhotoUrl': profilePhotoUrl,
      'role': role,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'bio': bio,
      'hobbies': hobbies,
      'credits': credits,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'skillsTaughtCount': skillsTaughtCount,
      'savedSkills': savedSkills,
      'blockedUsers': blockedUsers,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    dynamic dateVal = map['createdAt'];
    DateTime parsedDate = DateTime.now();
    if (dateVal is Timestamp) {
      parsedDate = dateVal.toDate();
    } else if (dateVal is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(dateVal);
    }

    return UserModel(
      id: id,
      name: map['name'] as String? ?? '',
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      profilePhotoUrl: map['profilePhotoUrl'] as String? ?? '',
      role: map['role'] as String? ?? 'user',
      createdAt: parsedDate,
      bio: map['bio'] as String? ?? '',
      hobbies: List<String>.from(map['hobbies'] ?? []),
      credits: map['credits'] as int? ?? 20,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: map['totalRatings'] as int? ?? 0,
      skillsTaughtCount: map['skillsTaughtCount'] as int? ?? 0,
      savedSkills: List<String>.from(map['savedSkills'] ?? []),
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? profilePhotoUrl,
    String? role,
    DateTime? createdAt,
    String? bio,
    List<String>? hobbies,
    int? credits,
    double? averageRating,
    int? totalRatings,
    int? skillsTaughtCount,
    List<String>? savedSkills,
    List<String>? blockedUsers,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      bio: bio ?? this.bio,
      hobbies: hobbies ?? this.hobbies,
      credits: credits ?? this.credits,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      skillsTaughtCount: skillsTaughtCount ?? this.skillsTaughtCount,
      savedSkills: savedSkills ?? this.savedSkills,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }
}
