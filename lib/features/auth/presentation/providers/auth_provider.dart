import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/error/error_message.dart';
import '../../data/models/auth_state.dart';
import '../../data/repositories/auth_repository.dart';
import 'secure_storage_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(secureStorageServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthInitial()) {
    _tryRestoreSession();
  }

  Future<void> _tryRestoreSession() async {
    state = const AuthLoading();
    try {
      final persisted = await _repo.loadPersistedSession();
      if (!mounted) return;

      if (persisted == null || persisted.tokens.isExpired) {
        state = const AuthUnauthenticated();
        return;
      }
      state = AuthAuthenticated(
        session: persisted.tokens,
        user: persisted.user,
      );
    } catch (e) {
      debugPrint('restore session failed: $e');
      if (mounted) state = const AuthUnauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final result = await _repo.login(email: email, password: password);
      if (!mounted) return;
      state = AuthAuthenticated(session: result.tokens, user: result.user);
    } catch (e) {
      if (mounted) state = AuthError(friendlyError(e));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AuthLoading();
    try {
      await _repo.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      final result = await _repo.login(email: email, password: password);
      if (!mounted) return;
      state = AuthAuthenticated(session: result.tokens, user: result.user);
    } catch (e) {
      if (mounted) state = AuthError(friendlyError(e));
    }
  }

  Future<void> logout() async {
    final current = state;
    try {
      if (current is AuthAuthenticated) {
        await _repo.logout(current.session.accessToken);
      }
    } catch (e) {
      debugPrint('logout failed: $e');
    }
    if (mounted) state = const AuthUnauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
