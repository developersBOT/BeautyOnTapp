import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUpService {
  static Future<Map<String, dynamic>> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      // Ensure the URL is correctly configured
      final response = await http.post(
        Uri.parse('https://beautyontapp.net/api/auth/signup'), // Make sure this URL is correct
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      // Debugging: Log response status and body for verification
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        // If signup is successful
        return json.decode(response.body); // Success response
      } else if (response.statusCode == 422) {
        // Handle specific validation errors (like email already taken or phone already in use)
        final errorResponse = json.decode(response.body);
        final errorMessage = errorResponse['message'] ?? 'Signup failed';
        throw Exception(errorMessage); // Throw error message to be handled in UI
      } else if (response.statusCode == 400) {
        // Handle other errors like rate-limiting or validation issues
        final errorResponse = json.decode(response.body);
        final errorMessages = errorResponse['errors']?.map((error) => error['message']).join(", ") ?? 'Error occurred';
        throw Exception(errorMessages); // Throw error message to be handled in UI
      } else {
        // Handle unexpected status codes
        throw Exception('Signup failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }
}
