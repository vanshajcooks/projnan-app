import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/controllers/auth_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: ProbonApp(),
    ),
  );
}

class ProbonApp extends ConsumerStatefulWidget {
  const ProbonApp({super.key});

  @override
  ConsumerState<ProbonApp> createState() => _ProbonAppState();
}

class _ProbonAppState extends ConsumerState<ProbonApp> {
  @override
  void initState() {
    super.initState();
    // Check saved session in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Probon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
