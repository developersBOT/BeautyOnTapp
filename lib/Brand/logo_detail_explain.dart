import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';

class LogoDetailExplain extends StatefulWidget {
  const LogoDetailExplain({super.key});

  @override
  State<LogoDetailExplain> createState() => _LogoDetailExplainState();
}

class _LogoDetailExplainState extends State<LogoDetailExplain> {
  Map<String, dynamic>? product;
  bool isLoading = true;
  bool hasError = false;
  int quantity = 1;
  int? selectedVariantIndex;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    final productId = args?['id'];
    if (productId != null) {
      _loadProductDetail(productId);
    } else {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _loadProductDetail(dynamic id) async {
    final url = Uri.parse("https://beautyontapp.net/api/product/$id");
    print("🔵 Fetching product details: $url");

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        setState(() {
          product = body['data'];
          isLoading = false;
          if (product?['variants'] != null && product!['variants'].isNotEmpty) {
            selectedVariantIndex = 0;
          }
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print("🔥 Exception: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Image.asset(
            'assets/images/flow.gif',
            width: 100,
            height: 100,
          ),
        ),
      );
    }
    if (hasError || product == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load product details")),
      );
    }

    final images = product!['images'] as List<dynamic>;
    final variants = product!['variants'] as List<dynamic>;
    final selectedVariant =
        selectedVariantIndex != null ? variants[selectedVariantIndex!] : null;

    final description = product!['body_html'] ?? "";
    final hasDescription = description.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(product!['vendor'] ?? "",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            if (images.isNotEmpty)
              Center(
                child: Image.network(
                  images[0]['src'],
                  height: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    print("❌ Image load failed: $error");
                    return const Icon(Icons.broken_image,
                        size: 100, color: Colors.grey);
                  },
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: Image.asset(
                        'assets/images/flow.gif',
                        width: 100,
                        height: 100,
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Title
            Text(
              product!['title'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Price + Stock
            Text(
              "R ${selectedVariant?['price'] ?? 'N/A'}",
              style: const TextStyle(
                  fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
            ),
            Text(
              (selectedVariant?['inventory_quantity'] ?? 0) > 0
                  ? "In Stock"
                  : "Out of Stock",
              style: TextStyle(
                fontSize: 14,
                color: (selectedVariant?['inventory_quantity'] ?? 0) > 0
                    ? Colors.green
                    : Colors.red,
              ),
            ),

            const SizedBox(height: 16),

            // Variant Options
            if (variants.isNotEmpty)
              Wrap(
                spacing: 8,
                children: List.generate(variants.length, (i) {
                  final v = variants[i];
                  return ChoiceChip(
                    label: Text(v['title']),
                    selected: selectedVariantIndex == i,
                    onSelected: (_) {
                      setState(() {
                        selectedVariantIndex = i;
                      });
                    },
                  );
                }),
              ),

            const SizedBox(height: 16),

            // Quantity Selector
            Row(
              children: [
                const Text("Quantity: "),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: quantity > 1
                      ? () => setState(() => quantity--)
                      : null,
                ),
                Text(quantity.toString(),
                    style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => quantity++),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, foregroundColor: Colors.white),
                onPressed: () {},
                child: const Text("ADD TO CART"),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, foregroundColor: Colors.white),
                onPressed: () {},
                child: const Text("BUY IT NOW"),
              ),
            ),

            const SizedBox(height: 24),

            // Description
            const Text("Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            hasDescription
                ? Html(data: description)
                : const Text("No description available"),

            const SizedBox(height: 24),

            // Ingredients (simple extract if exists)
            const Text("Ingredients",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Html(
              data: description.contains("Ingredients")
                  ? description
                  : "<p>No ingredients listed</p>",
            ),
          ],
        ),
      ),
    );
  }
}