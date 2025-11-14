import 'package:flutter/material.dart';
import 'package:homify/core/router/app_router.dart';
import 'package:homify/core/theme/theme_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:homify/core/widgets/loading_screen.dart';
import 'package:homify/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:homify/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformDispatcher.locale;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          final authInit = ref.watch(authStateProvider);

          return authInit.when(
            data: (_) => const MyApp(),
            loading: () => const LoadingPage(),
            error: (_, __) => const MaterialApp(
              home: Scaffold(body: Center(child: Text('Auth Error'))),
            ),
          );
        },
      ),
    ),
  );
}

// MyApp can now be a StatelessWidget
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Homify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
