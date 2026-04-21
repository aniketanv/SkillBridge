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

  Future<void> signUpWithEmail(String email, String password, String name, BuildContext context) async {
    state = true;
    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(email, password, name);
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
}
