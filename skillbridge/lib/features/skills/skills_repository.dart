import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:skillbridge/models/skill_model.dart';
import 'package:skillbridge/models/user_model.dart';
import 'package:uuid/uuid.dart';

part 'skills_repository.g.dart';

class SkillsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<SkillModel>> getApprovedSkills() {
    return _firestore
        .collection('skills')
        .where('isApproved', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('Error in getApprovedSkills Stream: $error');
        })
        .asyncMap((snapshot) async {
      List<SkillModel> skills = [];
      for (var doc in snapshot.docs) {
        SkillModel skill = SkillModel.fromMap(doc.data(), doc.id);

        // Hydrate user
        final userDoc = await _firestore.collection('users').doc(skill.userId).get();
        if (userDoc.exists) {
          skill = skill.copyWith(user: UserModel.fromMap(userDoc.data()!, userDoc.id));
        }
        skills.add(skill);
      }
      return skills;
    });
  }

  Future<void> addSkill({
    required String title,
    required String description,
    required String category,
    required String level,
    required int creditCost,
    required String userId,
    String videoUrl = '',
    File? mediaFile,
  }) async {
    String mediaUrl = '';
    
    if (mediaFile != null) {
      final ref = _storage.ref().child('skills_media/${const Uuid().v4()}');
      final uploadTask = await ref.putFile(mediaFile);
      mediaUrl = await uploadTask.ref.getDownloadURL();
    }

    final newSkill = SkillModel(
      id: '',
      userId: userId,
      title: title,
      description: description,
      category: category,
      level: level,
      creditCost: creditCost,
      mediaUrl: mediaUrl,
      videoUrl: videoUrl,
      isApproved: false, // Must be approved by admin
      createdAt: DateTime.now(),
    );

    await _firestore.collection('skills').add(newSkill.toMap());
  }

  Future<void> toggleBookmark(String skillId, String userId) async {
    final docRef = _firestore.collection('users').doc(userId);
    final doc = await docRef.get();
    if (!doc.exists) return;
    
    List<String> saved = List<String>.from(doc.data()!['savedSkills'] ?? []);
    if (saved.contains(skillId)) {
      saved.remove(skillId);
    } else {
      saved.add(skillId);
    }
    
    await docRef.update({'savedSkills': saved});
  }
}

@riverpod
SkillsRepository skillsRepository(Ref ref) {
  return SkillsRepository();
}

@riverpod
Stream<List<SkillModel>> approvedSkills(Ref ref) {
  return ref.watch(skillsRepositoryProvider).getApprovedSkills();
}
