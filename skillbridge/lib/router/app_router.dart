import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:skillbridge/features/auth/auth_repository.dart';
import 'package:skillbridge/features/auth/login_screen.dart';
import 'package:skillbridge/features/auth/signup_screen.dart';
import 'package:skillbridge/features/navigation/main_scaffold.dart';
import 'package:skillbridge/features/home/home_screen.dart';
import 'package:skillbridge/features/chat/chat_list_screen.dart';
import 'package:skillbridge/features/chat/chat_screen.dart';
import 'package:skillbridge/features/skills/add_skill_screen.dart';
import 'package:skillbridge/features/skills/skill_detail_screen.dart';
import 'package:skillbridge/features/profile/profile_screen.dart';
import 'package:skillbridge/features/profile/edit_profile_screen.dart';
import 'package:skillbridge/features/admin/admin_dashboard.dart';
import 'package:skillbridge/features/bookings/my_sessions_screen.dart';
import 'package:skillbridge/features/skills/saved_skills_screen.dart';
import 'package:skillbridge/models/skill_model.dart';
import 'package:skillbridge/models/user_model.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateChangeProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.uri.path == '/login' || state.uri.path == '/signup';

      if (authState.isLoading) return null;

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/add-skill',
                builder: (context, state) => const AddSkillScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/skill-detail',
        builder: (context, state) {
          final skill = state.extra as SkillModel;
          return SkillDetailScreen(skill: skill);
        },
      ),
      GoRoute(
        path: '/chat-detail',
        builder: (context, state) {
          final user = state.extra as UserModel;
          return ChatScreen(contactUser: user);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/my-sessions',
        builder: (context, state) => const MySessionsScreen(),
      ),
      GoRoute(
        path: '/saved-skills',
        builder: (context, state) => const SavedSkillsScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
}
