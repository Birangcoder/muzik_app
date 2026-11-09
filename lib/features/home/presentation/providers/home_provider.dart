import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/secure_storage_provider.dart';
import '../../data/models/home_model.dart';
import '../../data/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(secureStorageServiceProvider));
});

final homeProvider = FutureProvider<HomeModel>(
  (ref) async {
    final repository = ref.read(homeRepositoryProvider);
    return repository.getHome();
  },
  // Show errors immediately. Riverpod 3 would otherwise retry up to 10
  // times with backoff, so the user sees a spinner instead of the error.
  retry: (retryCount, error) => null,
);
