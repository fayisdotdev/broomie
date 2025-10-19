// lib/core/providers/auth_provider.dart
import 'package:broomie/features/auth/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
      return AuthController(ref);
    });

class AuthController extends StateNotifier<AsyncValue<User?>> {
  final Ref _ref;
  AuthController(this._ref) : super(const AsyncValue.data(null));

  Future<void> signInWithGoogle() async {
    try {
      state = const AsyncValue.loading();
      final userCred = await _ref
          .read(authRepositoryProvider)
          .signInWithGoogle();
      state = AsyncValue.data(userCred?.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }

    final user = FirebaseAuth.instance.currentUser;
    print('Signed in: ${user?.uid} ${user?.email}');
  }

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
  }
}
