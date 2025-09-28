import 'dart:convert';
import 'package:http/http.dart' as http;

class LogoService {
  static const String baseUrl = "https://beautyontapp.net/api";

  static Future<List<dynamic>> fetchBrandProducts(String brand, {int limit = 20}) async {
    // Map of static brand URLs
    final Map<String, String> brandUrls = {
      "Pastry Skincare": "$baseUrl/brands/Pastry Skincare?limit=20",
      "Mzuri Skin": "$baseUrl/brands/Mzuri Skin?limit=20",
      "Standard.": "$baseUrl/brands/Standard.?limit=20",
      "Dermopal": "$baseUrl/brands/Dermopal?limit=20",
      "Skin functional": "$baseUrl/brands/Skin functional?limit=20",
      "Cerave": "$baseUrl/brands/Cerave?limit=20",
    };

    final urlStr = brandUrls[brand];
    if (urlStr == null) {
      print("❌ [LogoService] No static URL found for brand: $brand");
      return [];
    }

    final url = Uri.parse(urlStr);
    print("🔵 [LogoService] Fetching brand: $brand");
    print("🔵 [LogoService] URL: $url");

    try {
      final response = await http.get(url);
      print("🟡 [LogoService] Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print("🟢 [LogoService] Response body: $body");

        if (body is Map && body['data'] != null && body['data']['products'] is List) {
          final products = body['data']['products'];
          print("🟢 [LogoService] Products length: ${products.length}");
          return products;
        } else {
          print("⚠️ [LogoService] No products found in response");
          return [];
        }
      } else {
        print("🔴 [LogoService] Error response: ${response.body}");
        return [];
      }
    } catch (e) {
      print("🔥 [LogoService] Exception: $e");
      return [];
    }
  }
}
