import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  /* -------------------- logging helpers -------------------- */
  static void _log(String msg) => print('[ProductService] $msg');

  static Map<String, dynamic> _decode(String body) {
    try {
      return json.decode(body) as Map<String, dynamic>;
    } catch (e) {
      _log('❌ JSON decode error: $e\nBody(head): ${body.substring(0, body.length > 400 ? 400 : body.length)}');
      rethrow;
    }
  }

  static bool _looksLikeProduct(dynamic v) {
    if (v is! Map) return false;
    return v.containsKey('id') && (v.containsKey('title') || v.containsKey('vendor') || v.containsKey('handle'));
  }

  /// Try to find a List of product maps in common places.
  static List<Map<String, dynamic>> _extractProductMaps(Map<String, dynamic> root) {
    // 1) Direct list at 'data'
    final data = root['data'];
    if (data is List) {
      _log('📦 using root["data"] as List (${data.length})');
      return data.whereType<Map<String, dynamic>>().toList();
    }

    // 2) Look for known list keys at root and at data (if data is Map)
    List<Map<String, dynamic>> pickFrom(dynamic obj, String key) {
      if (obj is Map && obj[key] is List) {
        final list = (obj[key] as List).whereType<Map<String, dynamic>>().toList();
        _log('📦 using "$key" list (${list.length})');
        return list;
      }
      return const [];
    }

    const candidates = ['products', 'items', 'records', 'rows', 'list', 'result'];
    for (final key in candidates) {
      final fromRoot = pickFrom(root, key);
      if (fromRoot.isNotEmpty) return fromRoot;
    }

    if (data is Map<String, dynamic>) {
      _log('🧭 data is Map; keys: ${data.keys.toList()}');
      for (final key in candidates) {
        final fromData = pickFrom(data, key);
        if (fromData.isNotEmpty) return fromData;
      }

      // 3) One-level deep scan inside data map values
      for (final entry in data.entries) {
        final v = entry.value;
        if (v is List && v.isNotEmpty && v.first is Map) {
          final list = v.whereType<Map<String, dynamic>>().toList();
          // sanity check: first element looks like product?
          if (list.isNotEmpty && _looksLikeProduct(list.first)) {
            _log('🔎 found list in data["${entry.key}"] (${list.length})');
            return list;
          }
        }
      }

      // 4) Single product object?
      if (_looksLikeProduct(data)) {
        _log('📦 single product object at data (wrapping to list)');
        return [data];
      }
    }

    // 5) Fallback: maybe root itself is the product or has nested single product
    if (_looksLikeProduct(root)) {
      _log('📦 single product object at root (wrapping to list)');
      return [root];
    }

    _log('⚠️ could not locate products list in JSON');
    return const [];
  }

  static List<Product> _mapToProducts(Map<String, dynamic> jsonMap) {
    final maps = _extractProductMaps(jsonMap);
    _log('🧮 parsed items: ${maps.length}');
    return maps.map<Product>((e) => Product.fromJson(e)).toList();
  }

  /* -------------------- endpoints -------------------- */

  /// Single product detail
  static Future<Map<String, dynamic>> fetchProductDetail(String productId) async {
    final uri = Uri.https('beautyontapp.net', '/api/product/$productId');
    _log('GET $uri');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      _log('↩️ ${res.statusCode}  len=${res.body.length}');
      if (res.statusCode == 200) {
        final data = _decode(res.body);
        return data['data'] ?? {};
      }
      throw Exception('HTTP ${res.statusCode}');
    } on TimeoutException {
      _log('⏳ timeout for $uri');
      rethrow;
    } catch (e) {
      _log('❌ fetchProductDetail error: $e');
      rethrow;
    }
  }

  /// New Arrivals
  static Future<List<Product>> fetchNewArrivals({int limit = 20}) async {
    final uri = Uri.https('beautyontapp.net', '/api/products/New Arrivals', {'limit': '$limit'});
    _log('GET $uri');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      _log('↩️ ${res.statusCode}  len=${res.body.length}');
      if (res.statusCode == 200) {
        return _mapToProducts(_decode(res.body));
      }
      throw Exception('HTTP ${res.statusCode}');
    } on TimeoutException {
      _log('⏳ timeout for $uri');
      rethrow;
    } catch (e) {
      _log('❌ fetchNewArrivals error: $e');
      rethrow;
    }
  }

  /// Skincare (Chosen For You)
  static Future<List<Product>> fetchSkincareProducts({int limit = 100}) async {
    final uri = Uri.https('beautyontapp.net', '/api/products/Skincare', {'limit': '$limit'});
    _log('GET $uri');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      _log('↩️ ${res.statusCode}  len=${res.body.length}');
      if (res.statusCode == 200) {
        return _mapToProducts(_decode(res.body));
      }
      throw Exception('HTTP ${res.statusCode}');
    } on TimeoutException {
      _log('⏳ timeout for $uri');
      rethrow;
    } catch (e) {
      _log('❌ fetchSkincareProducts error: $e');
      rethrow;
    }
  }

  /// Any full URL
  static Future<List<Product>> fetchProductsFromUrl(String apiUrl) async {
    final uri = Uri.parse(apiUrl);
    _log('GET $uri');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      _log('↩️ ${res.statusCode}  len=${res.body.length}');
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      return _mapToProducts(_decode(res.body));
    } on TimeoutException {
      _log('⏳ timeout for $uri');
      rethrow;
    } catch (e) {
      _log('❌ fetchProductsFromUrl error: $e');
      rethrow;
    }
  }

  /// Brand products — now tolerant to `data: { products: [...] }` shapes
  static Future<List<Product>> fetchBrandProducts(String brand, {int limit = 20}) async {
    final uri = Uri.https('beautyontapp.net', '/api/brands/$brand', {'limit': '$limit'});
    _log('GET $uri   (brand="$brand")');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      _log('↩️ ${res.statusCode}  len=${res.body.length}');
      if (res.statusCode == 200) {
        return _mapToProducts(_decode(res.body));
      }
      throw Exception('HTTP ${res.statusCode}');
    } on TimeoutException {
      _log('⏳ timeout for $uri');
      rethrow;
    } catch (e) {
      _log('❌ fetchBrandProducts("$brand") error: $e');
      rethrow;
    }
  }
}
