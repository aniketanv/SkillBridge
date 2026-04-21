import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillbridge/router/app_router.dart';
import 'package:skillbridge/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // NOTE: The Firebase project needs to be configured using 'flutterfire configure'
  // and the generated firebase_options.dart should be imported here.
  // Example:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // For now, we will wrap in try-catch so the app doesn't crash immediately 
  // without google-services.json
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase Initialization Error: \$e');
    debugPrint('Please ensure you have configured Firebase using Flutterfire CLI.');
  }

  runApp(const ProviderScope(child: SkillBridgeApp()));
}

class SkillBridgeApp extends ConsumerWidget {
  const SkillBridgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'SkillBridge',
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
