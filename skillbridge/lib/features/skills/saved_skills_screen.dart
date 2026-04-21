 import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillbridge/features/auth/auth_repository.dart';
import 'package:skillbridge/features/skills/skills_repository.dart';
import 'package:skillbridge/widgets/skill_card.dart';

class SavedSkillsScreen extends ConsumerWidget {
  const SavedSkillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final skillsAsync = ref.watch(approvedSkillsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Skills')),
      body: userAsync.when(
        data: (user) {
          if (user == null || user.savedSkills.isEmpty) {
            return const Center(child: Text('No saved skills.'));
          }

          return skillsAsync.when(
            data: (skills) {
              final savedSkills = skills.where((s) => user.savedSkills.contains(s.id)).toList();
              if (savedSkills.isEmpty) return const Center(child: Text('No saved skills found.'));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: savedSkills.length,
                itemBuilder: (context, index) {
                  return SkillCard(
                    skill: savedSkills[index],
                    onTap: () => context.push('/skill-detail', extra: savedSkills[index]),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
