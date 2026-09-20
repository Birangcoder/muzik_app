import 'login_response.dart';
import 'user_model.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  // renamed from `tokens` — there's only ever one token now, not a pair
  final LoginResponse session;
  final UserModel user;

  const AuthAuthenticated({required this.session, required this.user});
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}
