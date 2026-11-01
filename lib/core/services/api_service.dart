import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;
  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  static Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool forceRefreshToken = false,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const ApiException(401, 'Please sign in to continue.');
    }
    final token = await user.getIdToken(forceRefreshToken);
    if (token == null || token.isEmpty) {
      throw const ApiException(
        401,
        'Could not get your Firebase sign-in token.',
      );
    }
    final headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    if (body != null) headers['Content-Type'] = 'application/json';
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$path');
    final encodedBody = body == null ? null : jsonEncode(body);
    late final http.Response response;
    if (method == 'GET') {
      response = await http.get(uri, headers: headers);
    } else if (method == 'POST') {
      response = await http.post(uri, headers: headers, body: encodedBody);
    } else if (method == 'PUT') {
      response = await http.put(uri, headers: headers, body: encodedBody);
    } else if (method == 'DELETE') {
      response = await http.delete(uri, headers: headers);
    } else {
      throw ArgumentError.value(method, 'method');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      var message = 'Backend request failed (${response.statusCode}).';
      if (response.body.isNotEmpty) {
        try {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            message = (data['message'] ?? data['error'] ?? message).toString();
          } else {
            message = response.body;
          }
        } on FormatException {
          message = response.body;
        }
      }
      throw ApiException(response.statusCode, message);
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const FormatException('Unexpected backend response.');
  }

  static List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) throw const FormatException('Unexpected backend list.');
    return value.map(_map).toList();
  }

  static Future<Map<String, dynamic>> syncProfile({String? name}) async {
    final body = <String, dynamic>{};
    if (name != null && name.trim().isNotEmpty) body['name'] = name.trim();
    return _map(
      await _request('POST', '/api/users', body: body, forceRefreshToken: true),
    );
  }

  static Future<List<Map<String, dynamic>>> getMySnippets() async =>
      _mapList(await _request('GET', '/api/snippets'));

  static Future<List<Map<String, dynamic>>> getFavorites() async =>
      _mapList(await _request('GET', '/api/favorites'));

  static Future<Set<String>> getFavoriteIds() async {
    final values = await getFavorites();
    return values
        .map((item) => item['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  static Future<Map<String, dynamic>> getDashboardStats() async =>
      _map(await _request('GET', '/api/dashboard'));

  static Future<Map<String, dynamic>> createSnippet({
    required String title,
    required String code,
    required String language,
    required String description,
    required List<String> tags,
  }) async => _map(
    await _request(
      'POST',
      '/api/snippets',
      body: {
        'title': title,
        'code': code,
        'language': language,
        'description': description,
        'tags': tags,
        'visibility': 'PRIVATE',
      },
    ),
  );

  static Future<void> setFavorite(String id, bool isFavorite) async {
    await _request(
      isFavorite ? 'PUT' : 'DELETE',
      '/api/favorites/${Uri.encodeComponent(id)}',
    );
  }
}
