import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/model/auth_state.dart';
import '../../data/model/user_model.dart';
import 'authProvider.dart';

final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  return switch (authState) {
    AuthAuthenticated(:final user) => user,
    _ => null,
  };
});