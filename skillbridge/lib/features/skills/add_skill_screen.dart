import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skillbridge/features/auth/auth_repository.dart';
import 'package:skillbridge/features/skills/skills_repository.dart';
import 'package:skillbridge/widgets/custom_text_field.dart';

class AddSkillScreen extends ConsumerStatefulWidget {
  const AddSkillScreen({super.key});

  @override
  ConsumerState<AddSkillScreen> createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends ConsumerState<AddSkillScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _videoLinkController = TextEditingController();
  final _costController = TextEditingController(text: '5');
  final _formKey = GlobalKey<FormState>();
  
  String _selectedCategory = 'Coding';
  final List<String> _categories = ['Coding', 'Music', 'Fitness', 'Cooking', 'Art', 'Languages', 'Other'];
  
  String _selectedLevel = 'Beginner';
  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  
  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _videoLinkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submitSkill() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      try {
        final user = await ref.read(currentUserProvider.future);
        if (user == null) {
          throw Exception("You must be logged in to add a skill");
        }

        await ref.read(skillsRepositoryProvider).addSkill(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          category: _selectedCategory,
          level: _selectedLevel,
          creditCost: int.tryParse(_costController.text.trim()) ?? 5,
          userId: user.id,
          videoUrl: _videoLinkController.text.trim(),
          mediaFile: _imageFile,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Skill submitted for approval!'))
          );
          // Return to home
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      } finally {
        if (mounted) setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share a Skill')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('What can you teach?', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  
                  CustomTextField(
                    hintText: 'Skill Title (e.g. Flutter Development)',
                    controller: _titleController,
                    validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    hintText: 'Description',
                    controller: _descController,
                    maxLines: 5,
                    validator: (val) => val == null || val.isEmpty ? 'Please provide a description' : null,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    hintText: 'Video Link (e.g. Google Drive/YouTube) - Optional',
                    controller: _videoLinkController,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() { _selectedCategory = val; });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedLevel,
                          decoration: const InputDecoration(labelText: 'Level'),
                          items: _levels.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() { _selectedLevel = val; });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    hintText: 'Credit Cost (1-10)',
                    controller: _costController,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter a cost';
                      int? cost = int.tryParse(val);
                      if (cost == null || cost < 1 || cost > 10) return 'Must be 1-10';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Image Picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 40),
                                SizedBox(height: 8),
                                Text('Add a cover image (Optional)'),
                              ],
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitSkill,
                    child: const Text('Submit Skill'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your skill will be visible publicly after admin approval.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
    );
  }
}
