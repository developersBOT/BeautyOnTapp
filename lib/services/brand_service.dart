import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/brand_product_model.dart';

class BrandService {
  static Future<List<BrandProduct>> fetchBrandProducts(String brandName) async {
    try {
      final encodedName = Uri.encodeComponent(brandName); // ✅ FIXED
      final url = "https://beautyontapp.net/api/brands/$encodedName?limit=20";
      print("➡️ URL: $url");

      final response = await http.get(Uri.parse(url));

      print("📡 Response Status: ${response.statusCode}");
      print("✅ Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          final data = jsonData['data'];

          if (data is List) {
            return data.map((p) => BrandProduct.fromJson(p)).toList();
          }
        }
      }
      return [];
    } catch (e) {
      print("❌ Error fetching brand products: $e");
      return [];
    }
  }
}

