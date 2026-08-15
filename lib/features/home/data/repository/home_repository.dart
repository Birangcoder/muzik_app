import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_config.dart';
import '../../../../core/constants/api_exception.dart';
import '../../../auth/data/repository/secure_storage_service.dart';
import '../model/home_model.dart';

class HomeRepository {
  final SecureStorageService _storage;

  HomeRepository(this._storage);

  Future<HomeModel> getHome() async {
    final session = await _storage.readTokens();

    final response = await http.get(
      Uri.parse(ApiConfig.home),
      headers: {
        'Accept': 'application/json',
        if (session != null && session.accessToken.isNotEmpty)
          'Authorization': 'Bearer ${session.accessToken}',
      },
    );

    if (response.statusCode != 200) {
      debugPrint('Home error: ${response.body}');
      throw Exception('Failed to load home');
    }

    final data = unwrapData(response) as Map<String, dynamic>;

    final home = HomeModel.fromJson(data);

    return home;
  }
}
