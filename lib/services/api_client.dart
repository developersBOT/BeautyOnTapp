import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'https://beautyontapp.net';

  static Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    print('🌍 Baber Qureshi: POST Request => $uri');
    print('📦 Baber Qureshi: Body => $body');

    final resp = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            ...?headers,
          },
          body: jsonEncode(body),
        )
        .timeout(timeout);

    print('📡 Baber Qureshi: Response Code => ${resp.statusCode}');
    print('📡 Baber Qureshi: Response Body => ${resp.body}');

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return <String, dynamic>{};
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }

    try {
      final map = jsonDecode(resp.body);
      final msg = map is Map && map['message'] is String ? map['message'] : resp.body;
      throw Exception('HTTP ${resp.statusCode}: $msg');
    } catch (_) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
  }
}
