import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/data/repository/secure_storage_service.dart';
import '../../data/model/home_model.dart';
import '../../data/repository/home_repository.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(
    ref.watch(secureStorageServiceProvider),
  );
});

final homeProvider = FutureProvider<HomeModel>((ref) async {
  final repository = ref.read(homeRepositoryProvider);

  return repository.getHome();
});