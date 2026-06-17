import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MindBloomApp()));
}

class MindBloomApp extends ConsumerStatefulWidget {
  const MindBloomApp({super.key});

  @override
  ConsumerState<MindBloomApp> createState() => _MindBloomAppState();
}

class _MindBloomAppState extends ConsumerState<MindBloomApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authProvider.notifier).checkAuth());
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return MaterialApp(
      title: 'MindBloom',
      debugShowCheckedModeBanner: false,
      theme: MindBloomTheme.lightTheme,
      home: auth.isAuthenticated ? const MainShell() : const LoginScreen(),
    );
  }
}
