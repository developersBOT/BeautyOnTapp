import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';

class ProductDetailScreenBrand extends StatefulWidget {
  final String id;
  const ProductDetailScreenBrand({super.key, required this.id});

  @override
  State<ProductDetailScreenBrand> createState() => _ProductDetailScreenBrandState();
}

class _ProductDetailScreenBrandState extends State<ProductDetailScreenBrand> {
  late Future<Map<String, dynamic>> _futureDetail;

  @override
  void initState() {
    super.initState();

    // allow id via Get.arguments as well
    String productId = widget.id;
    final args = Get.arguments;
    if (args != null) {
      if (args is Map && args['id'] != null) {
        productId = args['id'].toString();
      } else if (args is dynamic && args.id != null) {
        productId = args.id.toString();
      }
    }

    _futureDetail = _fetchProductDetail(productId);
  }

  Future<Map<String, dynamic>> _fetchProductDetail(String productId) async {
    final url = Uri.parse("https://beautyontapp.net/api/product/$productId");
    // debug
    // print("[Detail] GET $url");
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}");
    }
    final map = json.decode(res.body) as Map<String, dynamic>;
    return (map['data'] ?? {}) as Map<String, dynamic>;
  }

  /// very lightweight split: everything before the first "ingredients"
  /// goes to description; from there to the end goes to ingredients
  Map<String, String> _splitDescIng(String html) {
    if (html.isEmpty) return {'desc': '', 'ing': ''};
    final lc = html.toLowerCase();
    final idx = lc.indexOf('ingredients');
    if (idx < 0) return {'desc': html, 'ing': ''};
    return {
      'desc': html.substring(0, idx).trim(),
      'ing' : html.substring(idx).trim(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Detail"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureDetail,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
            return Center(
              child: Text(
                "Failed to load product details",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final p = snap.data!;
          final title = (p['title'] ?? '').toString();
          final vendor = (p['vendor'] ?? '').toString();

          // price via first variant
          String price = "N/A";
          final variants = (p['variants'] ?? []) as List;
          if (variants.isNotEmpty) {
            final v0 = variants.first as Map<String, dynamic>;
            price = (v0['price'] ?? '').toString();
          }

          // primary image
          String imageUrl = '';
          final images = (p['images'] ?? []) as List;
          if (images.isNotEmpty) {
            final img0 = images.first as Map<String, dynamic>;
            imageUrl = (img0['src'] ?? '').toString();
          }

          // HTML body
          final bodyHtml = (p['body_html'] ?? '').toString();
          final split = _splitDescIng(bodyHtml);
          final descHtml = split['desc'] ?? '';
          final ingHtml  = split['ing']  ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // image
                if (imageUrl.isNotEmpty)
                  Center(
                    child: Image.network(
                      imageUrl,
                      height: 260,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 80),
                    ),
                  )
                else
                  const Center(child: Icon(Icons.image_not_supported, size: 80)),

                const SizedBox(height: 16),

                if (vendor.isNotEmpty)
                  Text(
                    vendor.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                const SizedBox(height: 4),

                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),

                Text(
                  price == "N/A" ? "R N/A" : "R $price",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Description (HTML)
                const Text(
                  "Description",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                descHtml.isNotEmpty
                    ? Html(data: descHtml)
                    : (bodyHtml.isNotEmpty
                        ? Html(data: bodyHtml) // fallback: show all if split failed
                        : const Text("No description available")),

                const SizedBox(height: 20),

                // Ingredients (HTML) — only if we found a section
                if (ingHtml.isNotEmpty) ...[
                  const Text(
                    "Ingredients",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Html(data: ingHtml),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
