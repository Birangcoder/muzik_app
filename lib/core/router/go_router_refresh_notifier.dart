import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, _) => notifyListeners());
  }
}

final goRouterRefreshProvider = Provider<GoRouterRefreshNotifier>((ref) {
  return GoRouterRefreshNotifier(ref);
});
