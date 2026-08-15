import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/secure_storage_provider.dart';
import '../../data/model/home_model.dart';
import '../../data/repository/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(
    ref.watch(secureStorageServiceProvider),
  );
});

final homeProvider = FutureProvider<HomeModel>((ref) async {
  final repository = ref.read(homeRepositoryProvider);

  return repository.getHome();
});