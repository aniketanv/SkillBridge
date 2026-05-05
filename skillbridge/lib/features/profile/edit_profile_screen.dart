import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillbridge/features/auth/auth_controller.dart';
import 'package:skillbridge/features/auth/auth_repository.dart';
import 'package:skillbridge/widgets/custom_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _hobbyController;
  List<String> _hobbies = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    _hobbyController = TextEditingController();
    
    // Initialize with current data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider).value;
      if (user != null) {
        _nameController.text = user.name;
        _usernameController.text = user.username;
        _bioController.text = user.bio;
        setState(() {
          _hobbies = List.from(user.hobbies);
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _hobbyController.dispose();
    super.dispose();
  }

  void _addHobby() {
    final hobby = _hobbyController.text.trim();
    if (hobby.isNotEmpty && !_hobbies.contains(hobby)) {
      if (_hobbies.length >= 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Max 10 hobbies allowed')),
        );
        return;
      }
      setState(() {
        _hobbies.add(hobby);
        _hobbyController.clear();
      });
    }
  }

  void _removeHobby(String hobby) {
    setState(() {
      _hobbies.remove(hobby);
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    try {
      final username = _usernameController.text.trim();
      final name = _nameController.text.trim();
      final bio = _bioController.text.trim();

      await ref.read(authControllerProvider.notifier).updateProfile(
            uid: user.id,
            name: name != user.name ? name : null,
            username: username != user.username ? username : null,
            bio: bio != user.bio ? bio : null,
            hobbies: _hobbies,
            context: context,
          );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!')),
        );
      }
    } catch (e) {
      // Error handled by controller
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _saveProfile,
              icon: const Icon(Icons.check),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Full Name'),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: 'Enter your name',
                controller: _nameController,
                validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),
              const Text('Username'),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: 'Choose a unique username',
                controller: _usernameController,
                prefixIcon: Icons.alternate_email,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Username is required';
                  if (val.length < 3) return 'Username too short';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Bio'),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: 'Tell us about yourself',
                controller: _bioController,
                maxLines: 3,
                validator: (val) {
                  if (val != null && val.length > 200) return 'Bio max 200 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Hobbies (Max 10)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      hintText: 'Add a hobby',
                      controller: _hobbyController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addHobby,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _hobbies
                    .map((hobby) => Chip(
                          label: Text(hobby),
                          onDeleted: () => _removeHobby(hobby),
                          deleteIcon: const Icon(Icons.close, size: 16),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
