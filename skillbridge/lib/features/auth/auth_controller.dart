import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:skillbridge/features/auth/auth_repository.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  bool build() {
    return false; // isLoading state
  }

  Future<void> loginWithEmail(String email, String password, BuildContext context) async {
    state = true;
    try {
      await ref.read(authRepositoryProvider).loginWithEmail(email, password);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      state = false;
    }
  }

  Future<void> signUpWithEmail(String email, String password, String name, String username, BuildContext context) async {
    state = true;
    try {
      final isUnique = await ref.read(authRepositoryProvider).isUsernameUnique(username);
      if (!isUnique) throw 'Username already taken';
      
      await ref.read(authRepositoryProvider).signUpWithEmail(email, password, name, username);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      state = false;
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    state = true;
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e) {
      if (context.mounted) {
        if (e.toString().contains('account-exists-with-different-credential')) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Account Exists'),
              content: const Text('An account already exists with this email using a password. Do you want to log in and link your Google account?'),
              actions: [
                TextButton(onPressed: () => ctx.pop(), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    ctx.pop();
                    ctx.go('/login');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log in with your password, then link Google from your Profile.')));
                  },
                  child: const Text('Yes, let\'s link'),
                ),
              ],
            )
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    } finally {
      state = false;
    }
  }

  Future<void> linkWithGoogle(BuildContext context) async {
    state = true;
    try {
      await ref.read(authRepositoryProvider).linkWithGoogle();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Linked Google OK')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      state = false;
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? username,
    String? bio,
    List<String>? hobbies,
    BuildContext? context,
  }) async {
    state = true;
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (username != null) {
        final isUnique = await ref.read(authRepositoryProvider).isUsernameUnique(username);
        if (!isUnique) throw 'Username already taken';
        data['username'] = username;
      }
      if (bio != null) data['bio'] = bio;
      if (hobbies != null) data['hobbies'] = hobbies;

      if (data.isNotEmpty) {
        await ref.read(authRepositoryProvider).updateProfile(uid, data);
        ref.invalidate(currentUserProvider);
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      rethrow;
    } finally {
      state = false;
    }
  }
}
