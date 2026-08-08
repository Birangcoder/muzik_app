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

  /// Rehydrates from secure storage — no network call, since there's no
  /// silent-refresh flow. If the cached token has already expired, the
  /// user has to log in again.
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
  /// end up authenticated. Now also requires a confirmation password,
  /// since the API validates password_confirmation server-side.
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
      state = AuthAuthenticated(session: result.tokens, user: result.user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> logout() async {
    final current = state;
    if (current is AuthAuthenticated) {
      await _repo.logout(current.session.accessToken);
    }
    state = const AuthUnauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
