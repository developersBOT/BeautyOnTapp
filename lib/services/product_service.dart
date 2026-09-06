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

  static List<Map<String, dynamic>> _extractProductMaps(Map<String, dynamic> root) {
    final data = root['data'];
    if (data is List) {
      _log('📦 using root["data"] as List (${data.length})');
      return data.whereType<Map<String, dynamic>>().toList();
    }

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
      for (final entry in data.entries) {
        final v = entry.value;
        if (v is List && v.isNotEmpty && v.first is Map) {
          final list = v.whereType<Map<String, dynamic>>().toList();
          if (list.isNotEmpty && _looksLikeProduct(list.first)) {
            _log('🔎 found list in data["${entry.key}"] (${list.length})');
            return list;
          }
        }
      }
      if (_looksLikeProduct(data)) return [data];
    }

    if (_looksLikeProduct(root)) return [root];
    _log('⚠️ could not locate products list in JSON');
    return const [];
  }

  static List<Product> _mapToProducts(Map<String, dynamic> jsonMap) {
    final maps = _extractProductMaps(jsonMap);
    _log('🧮 parsed items: ${maps.length}');
    return maps.map<Product>((e) => Product.fromJson(e)).toList();
  }

  /* -------------------- endpoints -------------------- */

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

  static Future<List<Product>> fetchNewArrivals({int limit = 20}) async {
    final uri = Uri.https('beautyontapp.net', '/api/products/New Arrivals', {'limit': '$limit'});
    _log('GET $uri');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) return _mapToProducts(_decode(res.body));
      throw Exception('HTTP ${res.statusCode}');
    } on TimeoutException {
      _log('⏳ timeout for $uri');
      rethrow;
    } catch (e) {
      _log('❌ fetchNewArrivals error: $e');
      rethrow;
    }
  }

  static Future<List<Product>> fetchSkincareProducts({int limit = 100}) async {
    final uri = Uri.https('beautyontapp.net', '/api/products/Skincare', {'limit': '$limit'});
    _log('GET $uri');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) return _mapToProducts(_decode(res.body));
      throw Exception('HTTP ${res.statusCode}');
    } on TimeoutException {
      _log('⏳ timeout for $uri');
      rethrow;
    } catch (e) {
      _log('❌ fetchSkincareProducts error: $e');
      rethrow;
    }
  }

  static Future<List<Product>> fetchProductsFromUrl(String apiUrl) async {
    final uri = Uri.parse(apiUrl);
    _log('GET $uri');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
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

  static Future<List<Product>> fetchBrandProducts(String brand, {int limit = 20}) async {
    final uri = Uri.https('beautyontapp.net', '/api/brands/$brand', {'limit': '$limit'});
    _log('GET $uri   (brand="$brand")');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) return _mapToProducts(_decode(res.body));
      throw Exception('HTTP ${res.statusCode}');
    } on TimeoutException {
      _log('⏳ timeout for $uri');
      rethrow;
    } catch (e) {
      _log('❌ fetchBrandProducts("$brand") error: $e');
      rethrow;
    }
  }

  /// -------------------- Add to Cart API --------------------
  /// Adds to existing cart (assumes cartId exists)
  static Future<Map<String, dynamic>?> addToCart({
    required String cartId,
    required String variantId, // GID format: "gid://shopify/ProductVariant/..."
    required int qty,
  }) async {
    try {
      final url = Uri.parse('https://beautyontapp.net/api/cart/add');
    
      // Build request body
      final Map<String, dynamic> requestBody = {
        'cart_id': cartId, // Removed split to keep full ID (including ?key if present)
        'variant_id': variantId, // GID
        'quantity': qty,
      };

      final body = json.encode(requestBody);
      
      _log('🛒 POST $url');
      _log('📦 Body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 20));

      _log('↩️ Status: ${response.statusCode}');
      _log('📥 Response: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final responseData = _decode(response.body);
        
        // Parse GraphQL response for add (assuming similar to create)
        final data = responseData['data'];
        if (data != null && data['cartLinesAdd'] != null) {
          final cartData = data['cartLinesAdd'];
          final cart = cartData['cart'];
          final userErrors = cartData['userErrors'] as List?;
          
          if (userErrors == null || userErrors.isEmpty) {
            final cartIdResp = cart?['id']?.toString(); // Removed split to keep full ID
            String? lineItemId;
            final lines = cart?['lines'];
            if (lines != null && lines['edges'] is List && (lines['edges'] as List).isNotEmpty) {
              final edges = lines['edges'] as List;
              lineItemId = edges.last['node']?['id']?.toString(); // Removed split to keep full ID
            }
            
            return {
              'success': true,
              'cart_id': cartIdResp,
              'line_item_id': lineItemId,
              'errors': null,
            };
          } else {
            _log('❌ User errors: $userErrors');
            return {'success': false, 'errors': userErrors};
          }
        } else {
          _log('⚠️ Unexpected response structure');
          return null;
        }
      } else {
        _log('❌ Failed with status ${response.statusCode}');
        return null;
      }
    } on TimeoutException {
      _log('⏳ Request timeout');
      return null;
    } catch (e) {
      _log('❌ Error adding to cart: $e');
      return null;
    }
  }

  /// -------------------- Create Cart API --------------------
  /// Creates a new cart with initial item and returns cart_id (GID) and line_item_id
  static Future<Map<String, dynamic>?> createCart({
    required String variantId, // GID format: "gid://shopify/ProductVariant/..."
    required int qty,
  }) async {
    try {
      final url = Uri.parse('https://beautyontapp.net/api/cart/create');
    
      // Build request body with required fields
      final Map<String, dynamic> requestBody = {
        'variant_id': variantId, // GID
        'quantity': qty,
      };

      final body = json.encode(requestBody);
      
      _log('🆕 POST $url - Creating new cart with initial item');
      _log('📦 Body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 20));

      _log('↩️ Status: ${response.statusCode}');
      _log('📥 Response: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final responseData = _decode(response.body);
        
        // Parse GraphQL response
        final data = responseData['data'];
        if (data != null && data['cartCreate'] != null) {
          final cartData = data['cartCreate'];
          final cart = cartData['cart'];
          final userErrors = cartData['userErrors'] as List?;
          
          if (userErrors == null || userErrors.isEmpty) {
            final cartIdResp = cart?['id']?.toString(); // Removed split to keep full ID
            String? lineItemId;
            final lines = cart?['lines'];
            if (lines != null && lines['edges'] is List && (lines['edges'] as List).isNotEmpty) {
              final edges = lines['edges'] as List;
              lineItemId = edges[0]['node']?['id']?.toString(); // Removed split to keep full ID
            }
            
            if (cartIdResp != null) {
              _log('✅ Cart created: $cartIdResp');
              return {
                'success': true,
                'cart_id': cartIdResp,
                'line_item_id': lineItemId,
                'errors': null,
              };
            }
          } else {
            _log('❌ User errors: $userErrors');
            return {'success': false, 'errors': userErrors};
          }
        } else {
          _log('⚠️ Unexpected response structure');
          return null;
        }
      } else {
        _log('❌ Failed with status ${response.statusCode}');
        return null;
      }
    } on TimeoutException {
      _log('⏳ Request timeout');
      return null;
    } catch (e) {
      _log('❌ Error creating cart: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchCart(String cartId) async {
    try {
      final url = Uri.parse('https://beautyontapp.net/api/cart/show');
    
      // Build request body
      final Map<String, dynamic> requestBody = {
        'cartId': cartId, // Removed split to keep full ID
      };

      final body = json.encode(requestBody);
      
      _log('📥 POST $url - Fetching cart');
      _log('📦 Body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 20));

      _log('↩️ Status: ${response.statusCode}');
      _log('📥 Response: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final responseData = _decode(response.body);
        
        // Parse GraphQL response
        final cart = responseData['data']?['cart'];
        if (cart != null) {
          List<Map<String, dynamic>> cartItems = [];
          final lines = cart['lines']?['edges'] as List? ?? [];
          for (final edge in lines) {
            final node = edge['node'] as Map<String, dynamic>?;
            if (node != null) {
              final merchandise = node['merchandise'] as Map<String, dynamic>?;
              final productJson = merchandise?['product'] as Map<String, dynamic>? ?? {};
              
              // Extract unit price from totalAmount / quantity (fixed parse logic)
              double price = 0.0;
              final cost = node['cost'] as Map<String, dynamic>?;
              final totalAmount = cost?['totalAmount'] as Map<String, dynamic>?;
              double total = double.tryParse(totalAmount?['amount']?.toString() ?? '0.0') ?? 0.0;
              int qty = node['quantity'] ?? 1;
              price = qty > 0 ? total / qty : 0.0;

              cartItems.add({
                'product': {
                  ...productJson,
                  'id': productJson['id']?.toString() ?? 'unknown',
                  'title': productJson['title'] ?? 'Unknown Product',
                  'price': price,
                  // Add imageUrl if available in response, e.g., productJson['featuredImage']?['url']
                  'imageUrl': productJson['featuredImage']?['url']?.toString() ?? '',
                  // Add other fields as needed
                },
                'variant': merchandise?['id']?.toString() ?? '',
                'variant_title': merchandise?['title']?.toString() ?? '',
                'qty': node['quantity'] ?? 1,
                'line_id': node['id']?.toString() ?? '',
              });
            }
          }

          final checkoutUrl = cart['checkoutUrl']?.toString() ?? '';

          return {
            'success': true,
            'data': {
              'cart_items': cartItems,
              'checkout_url': checkoutUrl,
            }
          };
        } else {
          _log('❌ No cart data in response');
          return null;
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on TimeoutException {
      _log('⏳ Request timeout');
      rethrow;
    } catch (e) {
      _log('❌ Error fetching cart: $e');
      rethrow;
    }
  }
}