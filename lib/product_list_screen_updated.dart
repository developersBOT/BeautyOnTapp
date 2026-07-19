import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:http/http.dart' as http;

import 'dart:ui'; // ← Added for ImageFilter

class ProductListScreenUpdated extends StatefulWidget {
  const ProductListScreenUpdated({super.key});

  @override
  State<ProductListScreenUpdated> createState() =>
      _ProductListScreenUpdatedState();
}

class _ProductListScreenUpdatedState extends State<ProductListScreenUpdated> {
  late String title;
  late String keyword;
  List<dynamic> products = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    title = args?['title'] ?? "Products";
    keyword = args?['keyword'] ?? "";
    print("🔵 [ProductListScreen] Title: $title, Keyword: $keyword");

    if (keyword.isNotEmpty) {
      _loadProducts();
    } else {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final url = Uri.parse(
      "https://beautyontapp.net/api/products/${Uri.encodeComponent(keyword)}?limit=100",
    );

    print("🔵 Fetching products from: $url");

    try {
      final response = await http.get(url);
      print("🟡 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        print("🟢 Response: $body");

        setState(() {
          products = body['data'] ?? []; // ✅ API me "data" key use ho rahi hai
          isLoading = false;
          hasError = products.isEmpty;
        });
      } else {
        print("🔴 Error response: ${response.body}");
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      print("🔥 Exception: $e");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          if (!isLoading)
            hasError
                ? Center(child: Text("No products found for $title"))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final p = products[index];
                      final imageUrl =
                          (p['images'] != null &&
                              p['images'] is List &&
                              p['images'].isNotEmpty)
                          ? p['images'][0]['src']
                          : null;

                      final productTitle = p['title'] ?? 'No title';
                      // ✅ Price fix (Shopify string price)
                      final price =
                          (p['variants'] != null &&
                              p['variants'] is List &&
                              p['variants'].isNotEmpty &&
                              p['variants'][0]['price'] != null)
                          ? double.tryParse(
                                  p['variants'][0]['price'].toString(),
                                )?.toStringAsFixed(2) ??
                                '0.00'
                          : '0.00';

                      // ✅ Stock fix (Shopify inventory_quantity)
                      final inStock =
                          (p['variants'] != null &&
                              p['variants'] is List &&
                              p['variants'].isNotEmpty &&
                              p['variants'][0]['inventory_quantity'] != null)
                          ? ((int.tryParse(
                                          p['variants'][0]['inventory_quantity']
                                              .toString(),
                                        ) ??
                                        0) >
                                    0
                              ? "In Stock"
                              : "Out of Stock")
                          : "Out of Stock";

                      return GestureDetector(
                        onTap: () {
                          // Navigate to detail screen later
                          Get.toNamed(
                            '/logo-detail-explain',
                            arguments: {'id': p['id'].toString()},
                          );
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: imageUrl != null
                                    ? ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (_, __, ___) => const Icon(
                                            Icons.broken_image,
                                            size: 40,
                                          ),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  productTitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  "R $price",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4,
                                ),
                                child: Text(
                                  inStock,
                                  style: TextStyle(
                                    color: inStock == "In Stock"
                                        ? Colors.blue
                                        : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          if (isLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.3), // Semi-transparent dim for better blur effect
                  child: Center(
                    child: Image.asset('assets/images/flow.gif'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}