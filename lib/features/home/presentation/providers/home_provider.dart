import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/secure_storage_provider.dart';
import '../../data/models/home_model.dart';
import '../../data/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(
    ref.watch(secureStorageServiceProvider),
  );
});

final homeProvider = FutureProvider<HomeModel>((ref) async {
  final repository = ref.read(homeRepositoryProvider);

  return repository.getHome();
});