import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillbridge/models/user_model.dart';

class SkillModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String level;
  final int creditCost;
  final String mediaUrl;
  final String videoUrl;
  final bool isApproved;
  final DateTime createdAt;
  final UserModel? user; // Optional hydration

  SkillModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    this.level = 'Beginner',
    this.creditCost = 5,
    this.mediaUrl = '',
    this.videoUrl = '',
    this.isApproved = false,
    required this.createdAt,
    this.user,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'level': level,
      'creditCost': creditCost,
      'mediaUrl': mediaUrl,
      'videoUrl': videoUrl,
      'isApproved': isApproved,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory SkillModel.fromMap(Map<String, dynamic> map, String id) {
    dynamic dateVal = map['createdAt'];
    DateTime parsedDate = DateTime.now();
    if (dateVal is Timestamp) {
      parsedDate = dateVal.toDate();
    } else if (dateVal is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(dateVal);
    }

    return SkillModel(
      id: id,
      userId: map['userId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      level: map['level'] as String? ?? 'Beginner',
      creditCost: map['creditCost'] as int? ?? 5,
      mediaUrl: map['mediaUrl'] as String? ?? '',
      videoUrl: map['videoUrl'] as String? ?? '',
      isApproved: map['isApproved'] as bool? ?? false,
      createdAt: parsedDate,
    );
  }

  SkillModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    String? level,
    int? creditCost,
    String? mediaUrl,
    String? videoUrl,
    bool? isApproved,
    DateTime? createdAt,
    UserModel? user,
  }) {
    return SkillModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      level: level ?? this.level,
      creditCost: creditCost ?? this.creditCost,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
    );
  }
}
