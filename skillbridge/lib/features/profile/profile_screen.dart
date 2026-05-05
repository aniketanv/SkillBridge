import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillbridge/features/auth/auth_repository.dart';
import 'package:skillbridge/features/auth/auth_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  backgroundImage: user.profilePhotoUrl.isNotEmpty 
                      ? CachedNetworkImageProvider(user.profilePhotoUrl) 
                      : null,
                  child: user.profilePhotoUrl.isEmpty 
                      ? Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.primary) 
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                if (user.username.isNotEmpty)
                  Text(
                    '@${user.username}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (user.bio.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    user.bio,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                if (user.hobbies.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: user.hobbies
                        .map((hobby) => Chip(
                              label: Text(hobby),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 16),
                
                // Statistics Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCol(context, '${user.credits}', 'Credits'),
                    _buildStatCol(context, user.averageRating.toStringAsFixed(1), 'Rating'),
                    _buildStatCol(context, '${user.skillsTaughtCount}', 'Skills Taught'),
                  ],
                ),
                const SizedBox(height: 24),

                if (user.role == 'admin') ...[
                  const SizedBox(height: 16),
                  Chip(
                    label: const Text('Admin'),
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
                const SizedBox(height: 32),
                const Divider(),
                
                // Settings Options
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('My Sessions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/my-sessions');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/edit-profile');
                  },
                ),
                if (user.role == 'admin')
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text('Admin Dashboard'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.push('/admin');
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Link Google'),
                  onTap: () {
                    ref.read(authControllerProvider.notifier).linkWithGoogle(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    ref.read(authRepositoryProvider).signOut();
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatCol(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

