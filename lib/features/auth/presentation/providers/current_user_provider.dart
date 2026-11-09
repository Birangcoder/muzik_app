import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/auth_state.dart';
import '../../data/models/user_model.dart';
import 'auth_provider.dart';

final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  return switch (authState) {
    AuthAuthenticated(:final user) => user,
    _ => null,
  };
});
