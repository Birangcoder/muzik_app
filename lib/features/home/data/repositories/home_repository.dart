import '../../../../core/constants/api_config.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/repositories/secure_storage_service.dart';
import '../models/home_model.dart';

class HomeRepository {
  final SecureStorageService _storage;

  HomeRepository(this._storage);

  Future<HomeModel> getHome() async {
    String? token;
    try {
      token = (await _storage.readTokens())?.accessToken;
    } catch (_) {}

    final response = await ApiClient.get(
      Uri.parse(ApiConfig.home),
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    return HomeModel.fromJson(unwrapMap(response));
  }
}
