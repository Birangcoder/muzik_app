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

  Future<void> _tryRestoreSession() async {
    state = const AuthLoading();
    final tokens = await _repo.loadPersistedTokens();

    if (tokens == null) {
      state = const AuthUnauthenticated();
      return;
    }

    try {
      final validTokens = tokens.isExpired
          ? await _repo.refreshToken(tokens.refreshToken)
          : tokens;
      final user = await _repo.fetchCurrentUser(validTokens.accessToken);
      state = AuthAuthenticated(tokens: validTokens, user: user);
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login() async {
    state = const AuthLoading();
    try {
      final tokens = await _repo.login();
      final user = await _repo.fetchCurrentUser(tokens.accessToken);
      state = AuthAuthenticated(tokens: tokens, user: user);
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
