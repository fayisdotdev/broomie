// lib/features/auth/widgets/auth_wrapper.dart
import 'package:broomie/core/providers/auth_provider.dart';
import 'package:broomie/features/auth/presentation/login_screen.dart';
import 'package:broomie/features/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomeScreen(); // logged in
        } else {
          return const LoginScreen(); // not logged in
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}
