// features/auth/presentation/provider/authProvider.dart

import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import '../../data/model/auth_state.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/secure_storage_service.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(secureStorageServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthInitial()) {
    _tryRestoreSession();
  }

  /// Rehydrates from secure storage — no network call, since the user
  /// object is cached locally alongside the token (no refresh flow
  /// or "current user" endpoint to fall back on if the token expired).
  Future<void> _tryRestoreSession() async {
    state = const AuthLoading();
    final persisted = await _repo.loadPersistedSession();

    if (persisted == null || persisted.tokens.isExpired) {
      state = const AuthUnauthenticated();
      return;
    }

    state = AuthAuthenticated(session: persisted.tokens, user: persisted.user);
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final result = await _repo.login(email: email, password: password);
      state = AuthAuthenticated(session: result.tokens, user: result.user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Registers the account, then immediately logs in — register.php
  /// doesn't return a token, so a separate login call is required to
  /// end up authenticated.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      await _repo.register(name: name, email: email, password: password);
      final result = await _repo.login(email: email, password: password);
      state = AuthAuthenticated(session: result.tokens, user: result.user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthUnauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
