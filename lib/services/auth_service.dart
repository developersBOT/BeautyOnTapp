import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('https://beautyontapp.net/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    // Debugging: Log request and response details
    print('🌍 Baber Qureshi: POST Request to https://beautyontapp.net/api/auth/login');
    print('📦 Baber Qureshi: Request Body => {email: $email, password: $password}');
    print('📡 Baber Qureshi: Response Status Code => ${response.statusCode}');
    print('📡 Baber Qureshi: Response Body => ${response.body}');

    // Check if the status code is 200 (successful login)
    if (response.statusCode == 200) {
      // Parse the response body to extract data
      final responseBody = jsonDecode(response.body);

      // Check if the response contains the expected 'access_token'
      if (responseBody.containsKey('access_token')) {
        final accessToken = responseBody['access_token'];

        // Store the token in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);

        // Return the response body (this can be used later if needed)
        return responseBody;
      } else {
        throw Exception('Access token not found in the response');
      }
    } else {
      // If the response is not successful (not 200)
      throw Exception('Failed to login');
    }
  }
}
