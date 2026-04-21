import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillbridge/models/skill_model.dart';
import 'package:skillbridge/models/user_model.dart';

class SampleDataSeeder {
  static Future<void> seedDatabase() async {
    final firestore = FirebaseFirestore.instance;

    // Create a mock user
    final String mockUserId = 'mock_user_123';
    final user = UserModel(
      id: mockUserId,
      name: 'Jane Doe',
      email: 'jane@example.com',
      bio: 'Senior Flutter Developer & Tech Enthusiast',
      role: 'user',
      createdAt: DateTime.now(),
    );

    await firestore.collection('users').doc(mockUserId).set(user.toMap());

    // Create mock skills
    final skills = [
      SkillModel(
        id: '',
        userId: mockUserId,
        title: 'Learn Flutter from Scratch',
        description: 'I will teach you how to build beautiful mobile apps using Flutter and Dart. From basics to advanced state management.',
        category: 'Coding',
        isApproved: true,
        createdAt: DateTime.now(),
      ),
      SkillModel(
        id: '',
        userId: mockUserId,
        title: 'Beginner Guitar Lessons',
        description: 'Learn the basic chords, strumming patterns, and your first song in just a few days!',
        category: 'Music',
        isApproved: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    for (var skill in skills) {
      await firestore.collection('skills').add(skill.toMap());
    }
  }
}
