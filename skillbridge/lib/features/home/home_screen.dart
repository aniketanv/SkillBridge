import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillbridge/features/auth/auth_repository.dart';
import 'package:skillbridge/features/skills/skills_repository.dart';
import 'package:skillbridge/widgets/skill_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedLevel = 'All';

  final List<String> _categories = [
    'All', 'Coding', 'Music', 'Fitness', 'Cooking', 'Art', 'Languages', 'Other'
  ];
  final List<String> _levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  @override
  Widget build(BuildContext context) {
    final skillsAsync = ref.watch(approvedSkillsProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SkillBridge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => context.push('/saved-skills'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search skills...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Categories
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Levels
          SizedBox(
            height: 35,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _levels.length,
              itemBuilder: (context, index) {
                final level = _levels[index];
                final isSelected = _selectedLevel == level;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(level, style: const TextStyle(fontSize: 12)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() { _selectedLevel = level; });
                    },
                    selectedColor: Colors.blueGrey.withOpacity(0.3),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Skills Feed
          Expanded(
            child: skillsAsync.when(
              data: (skills) {
                final filteredSkills = skills.where((skill) {
                  final matchesCategory = _selectedCategory == 'All' || skill.category == _selectedCategory;
                  final matchesLevel = _selectedLevel == 'All' || skill.level == _selectedLevel;
                  final matchesSearch = skill.title.toLowerCase().contains(_searchQuery) ||
                                        skill.description.toLowerCase().contains(_searchQuery);
                  return matchesCategory && matchesLevel && matchesSearch;
                }).toList();

                if (filteredSkills.isEmpty) {
                  return const Center(child: Text('No skills found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredSkills.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        SkillCard(
                          skill: filteredSkills[index],
                          onTap: () {
                            context.push('/skill-detail', extra: filteredSkills[index]);
                          },
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(
                              userAsync.value?.savedSkills.contains(filteredSkills[index].id) == true 
                                ? Icons.bookmark 
                                : Icons.bookmark_border,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () {
                              if (userAsync.value != null) {
                                ref.read(skillsRepositoryProvider).toggleBookmark(filteredSkills[index].id, userAsync.value!.id);
                              }
                            },
                          ),
                        )
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) {
                debugPrint('HomeScreen Skills Error: $err');
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Error loading skills: $err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
