import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../controllers/cart_controller.dart';

import 'dart:ui'; // ← Added for ImageFilter

class ProductDetailScreenBrand extends StatefulWidget {
  final String id;
  const ProductDetailScreenBrand({super.key, required this.id});

  @override
  State<ProductDetailScreenBrand> createState() =>
      _ProductDetailScreenBrandState();
}

class _ProductDetailScreenBrandState extends State<ProductDetailScreenBrand> {
  late Future<_DetailBundle> _future;
  int _qty = 1;
  int _selectedVariant = 0;

  // Added state variables
  _DetailBundle? _bundle;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<CartController>())
      Get.put(CartController(), permanent: true);

    final args = Get.arguments;
    String productId = widget.id;
    if (args != null && args is Map && args['id'] != null)
      productId = args['id'].toString();
    _future = _load(productId);

    // Handle future completion
    _future.then((bundle) {
      if (mounted) {
        setState(() {
          _bundle = bundle;
          isLoading = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    });
  }

  Future<_DetailBundle> _load(String id) async {
    final raw = await ProductService.fetchProductDetail(id);
    final product = Product.fromJson(raw);

    final List images = raw['images'] is List ? (raw['images'] as List) : [];
    final String imageUrl =
        (images.isNotEmpty && (images[0]['src'] ?? '').toString().isNotEmpty)
        ? images[0]['src'].toString()
        : product.imageUrl;

    final List<Map<String, dynamic>> variants = (raw['variants'] as List? ?? [])
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final String descriptionHtml = raw['body_html'] ?? '';
    final String ingredientsHtml = _extractIngredients(raw);

    return _DetailBundle(
      product: product,
      raw: raw,
      imageUrl: imageUrl,
      variants: variants,
      descriptionHtml: descriptionHtml,
      ingredientsHtml: ingredientsHtml,
    );
  }

  String _extractIngredients(Map<String, dynamic> p) {
    final direct =
        p['ingredients'] ?? p['ingredients_html'] ?? p['Ingredients'];
    if (direct is String && direct.trim().isNotEmpty) return direct;
    if (p['metafields'] is List) {
      for (final m in (p['metafields'] as List)) {
        try {
          final key = (m['key'] ?? m['name'] ?? '').toString().toLowerCase();
          if (key.contains('ingredient')) {
            final val = (m['value'] ?? m['content'] ?? '').toString();
            if (val.trim().isNotEmpty) return val;
          }
        } catch (_) {}
      }
    }
    return '';
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Product Detail"),
        backgroundColor: Colors.white,
        // foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: hasError
          ? const Center(
              child: Text(
                "❌ Failed to load product",
                style: TextStyle(color: Colors.red),
              ),
            )
          : _bundle == null
              ? const Center(child: Text("No product found"))
              : Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      children: [
                        Center(
                          child: _bundle!.product.imageUrl.isNotEmpty
                              ? Image.network(
                                  _bundle!.product.imageUrl,
                                  height: 260,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.image_not_supported, size: 80),
                                )
                              : _bundle!.product.imageAsset.isNotEmpty
                                  ? Image.asset(_bundle!.product.imageAsset, height: 260)
                                  : const Icon(Icons.image_not_supported, size: 80),
                        ),
                        const SizedBox(height: 16),
                        if (_bundle!.product.subtitle.isNotEmpty)
                          Text(
                            _bundle!.product.subtitle.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          _bundle!.product.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _Stars(rating: _bundle!.product.rating, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '(${_bundle!.product.reviews} reviews)',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "R ${_bundle!.product.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_bundle!.variants.isNotEmpty) ...[
                          const Text(
                            "Size",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(_bundle!.variants.length, (i) {
                              final vv = _bundle!.variants[i];
                              final label = (vv['option1'] ?? vv['title'] ?? '')
                                  .toString();
                              final selected = i == _selectedVariant;
                              return ChoiceChip(
                                checkmarkColor: Colors.white,
                                label: Text(label.isEmpty ? 'Default' : label),
                                selected: selected,
                                onSelected: (_) => setState(() => _selectedVariant = i),
                                selectedColor: Colors.black,
                                backgroundColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: selected ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w700,
                                ),
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: selected
                                        ? Colors.black
                                        : const Color(0xFFE0E0E0),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                        ],

                        Row(
                          children: [
                            _QtyStepper(
                              qty: _qty,
                              onMinus: () =>
                                  setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
                              onPlus: () => setState(() => _qty++),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  minimumSize: const Size.fromHeight(44),
                                ),
                                onPressed: () async {
                                  try {
                                    final v = _bundle!.variants.isNotEmpty
                                        ? _bundle!.variants[_selectedVariant]
                                        : null;
                                    // Use admin_graphql_api_id (GID) for variantId
                                    final variantGid = v?['admin_graphql_api_id']?.toString() ?? v?['id']?.toString() ?? _bundle!.product.id;
                                    final variantTitle = (v?['option1'] ?? v?['title'] ?? '')
                                        .toString()
                                        .trim();
                                    await CartController.to.addToCart(variantGid, _qty, _bundle!.product, variantTitle: variantTitle);
                                    Get.snackbar(
                                      'Cart',
                                      'Added ${_bundle!.product.title} to cart',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  } catch (_) {
                                    Get.snackbar(
                                      'Cart',
                                      'Failed to add to cart',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  }
                                },
                                child: const Text(
                                  'ADD TO CART',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Description",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _stripHtml(_bundle!.descriptionHtml).isEmpty
                              ? "No description available."
                              : _stripHtml(_bundle!.descriptionHtml),
                          style: const TextStyle(fontSize: 13.5, height: 1.35),
                        ),
                        const SizedBox(height: 16),
                        if (_bundle!.ingredientsHtml.trim().isNotEmpty) ...[
                          const Text(
                            "Ingredients",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _stripHtml(_bundle!.ingredientsHtml),
                            style: const TextStyle(fontSize: 13.5, height: 1.35),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
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

class _DetailBundle {
  final Product product;
  final Map<String, dynamic> raw;
  final String imageUrl;
  final List<Map<String, dynamic>> variants;
  final String descriptionHtml;
  final String ingredientsHtml;

  _DetailBundle({
    required this.product,
    required this.raw,
    required this.imageUrl,
    required this.variants,
    required this.descriptionHtml,
    required this.ingredientsHtml,
  });
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const _QtyStepper({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove),
            splashRadius: 20,
          ),
          Text(
            '$qty',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final double rating;
  final double size;
  const _Stars({required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    return Row(
      children: List.generate(5, (i) {
        if (i < full)
          return Icon(Icons.star, size: size, color: Colors.amber[700]);
        if (i == full && half)
          return Icon(Icons.star_half, size: size, color: Colors.amber[700]);
        return Icon(Icons.star_border, size: size, color: Colors.amber[700]);
      }),
    );
  }
}