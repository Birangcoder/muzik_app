import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_config.dart';
import '../../../../core/constants/api_exception.dart';
import '../../../auth/data/repository/secure_storage_service.dart';
import '../model/home_model.dart';

class HomeRepository {
  final SecureStorageService _storage;

  HomeRepository(this._storage);

  Future<HomeModel> getHome() async {
    final total = Stopwatch()..start();

    debugPrint('HOME URL: ${ApiConfig.home}');

    final session = await _storage.readTokens();

    final response = await http.get(
      Uri.parse(ApiConfig.home),
      headers: {
        'Accept': 'application/json',
        if (session != null && session.accessToken.isNotEmpty)
          'Authorization': 'Bearer ${session.accessToken}',
      },
    );

    final requestTime = total.elapsedMilliseconds;

    debugPrint('Home status: ${response.statusCode}');

    if (response.statusCode != 200) {
      debugPrint('Home error: ${response.body}');
      throw Exception('Failed to load home');
    }

    final jsonTime = Stopwatch()..start();

    final data = unwrapData(response) as Map<String, dynamic>;

    final unwrapTime = jsonTime.elapsedMilliseconds;

    final modelTime = Stopwatch()..start();

    final home = HomeModel.fromJson(data);

    final parseTime = modelTime.elapsedMilliseconds;

    debugPrint(
      'Home HTTP: ${requestTime} ms | '
      'Unwrap: ${unwrapTime} ms | '
      'Model: ${parseTime} ms | '
      'Total: ${total.elapsedMilliseconds} ms',
    );

    return home;
  }
}
