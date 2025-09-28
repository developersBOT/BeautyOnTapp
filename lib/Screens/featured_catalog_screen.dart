import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class FeaturedCatalogScreen extends StatefulWidget {
  final String title;
  final String apiUrl; // full API url you passed

  const FeaturedCatalogScreen({
    super.key,
    required this.title,
    required this.apiUrl,
  });

  @override
  State<FeaturedCatalogScreen> createState() => _FeaturedCatalogScreenState();
}

class _FeaturedCatalogScreenState extends State<FeaturedCatalogScreen> {
  late Future<List<Product>> _future;
  bool inStock = false;
  bool outOfStock = false;

  @override
  void initState() {
    super.initState();
    _future = ProductService.fetchProductsFromUrl(widget.apiUrl);
  }

  @override
  Widget build(BuildContext context) {
    final filterChips = [
      {"label": "New", "icon": Icons.auto_awesome},
      {"label": "Bestsellers", "icon": Icons.star_border},
      {"label": "Clean", "icon": Icons.check_circle_outline},
      {"label": "Vegan", "icon": Icons.eco},
      {"label": "Mini Size", "icon": Icons.inventory_2_outlined},
      {"label": "BeautyOnTApp Exclusives", "icon": Icons.card_giftcard},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Filter chips row (visual only for now)
          SizedBox(
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: filterChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final chip = filterChips[index];
                return FilterChip(
                  label: Text(chip["label"] as String),
                  avatar: Icon(chip["icon"] as IconData, size: 18),
                  onSelected: (_) {},
                );
              },
            ),
          ),

          // Filters + Best selling row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _openFilterSheet,
                  icon: const Icon(Icons.filter_list, color: Colors.black),
                  label: const Text("Filters", style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                Row(
                  children: const [
                    Icon(Icons.swap_vert, color: Colors.black),
                    SizedBox(width: 4),
                    Text("Best selling", style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),

          // Products grid (API)
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Text('Failed to load: ${snap.error}',
                        style: const TextStyle(color: Colors.red)),
                  );
                }
                final products = snap.data ?? const <Product>[];
                if (products.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView.builder(
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: (p.imageUrl.isNotEmpty)
                                    ? Image.network(
                                        p.imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.broken_image,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : (p.imageAsset.isNotEmpty
                                        ? Image.asset(
                                            p.imageAsset,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          )
                                        : const Icon(Icons.image_not_supported, size: 60)),
                              ),
                            ),

                            // Stars + Reviews (mock or from model)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ...List.generate(
                                  p.rating.round().clamp(0, 5),
                                  (i) => const Icon(Icons.star, color: Colors.black, size: 16),
                                ),
                                ...List.generate(
                                  (5 - p.rating.round()).clamp(0, 5),
                                  (i) => const Icon(Icons.star_border, color: Colors.black, size: 16),
                                ),
                                const SizedBox(width: 4),
                                Text("(${p.reviews})", style: const TextStyle(fontSize: 12)),
                              ],
                            ),

                            // Brand (subtitle)
                            if (p.subtitle.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  p.subtitle.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),

                            // Name
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Text(
                                p.title,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            // Price
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                'R ${p.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        bool _inStock = inStock;
        bool _outOfStock = outOfStock;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filters",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Availability
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Availability",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  CheckboxListTile(
                    value: _inStock,
                    onChanged: (val) => setState(() => _inStock = val ?? false),
                    title: const Text("In stock (312)"),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: _outOfStock,
                    onChanged: (val) => setState(() => _outOfStock = val ?? false),
                    title: const Text("Out of stock (132)"),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const Divider(),

                  // Price section placeholder
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Price",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Apply
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          inStock = _inStock;
                          outOfStock = _outOfStock;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "APPLY",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
