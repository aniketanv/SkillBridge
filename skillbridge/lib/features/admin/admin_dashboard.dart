import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillbridge/models/skill_model.dart';
import 'package:skillbridge/widgets/skill_card.dart';

final pendingSkillsProvider = StreamProvider.autoDispose<List<SkillModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('skills')
      .where('isApproved', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => SkillModel.fromMap(doc.data(), doc.id)).toList());
});

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  void _approveSkill(String skillId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('skills').doc(skillId).update({'isApproved': true});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Skill approved!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _rejectSkill(String skillId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('skills').doc(skillId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Skill rejected & deleted!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingSkillsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: pendingAsync.when(
        data: (skills) {
          if (skills.isEmpty) {
            return const Center(child: Text('No pending skills to approve.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              final skill = skills[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    SkillCard(
                      skill: skill,
                      onTap: () {},
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: () => _rejectSkill(skill.id, context),
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                        ),
                        TextButton.icon(
                          onPressed: () => _approveSkill(skill.id, context),
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                          style: TextButton.styleFrom(foregroundColor: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
