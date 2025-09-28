import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MiniSizeScreen extends StatefulWidget {
  const MiniSizeScreen({super.key});

  @override
  State<MiniSizeScreen> createState() => _MiniSizeScreenState();
}

class _MiniSizeScreenState extends State<MiniSizeScreen> {
  bool inStock = false;
  bool outOfStock = false;
   final List<Map<String, dynamic>> products = [
      {
        "brand": "B'AIR SKINCARE",
        "name": "2% Alpha Arbutin Serum",
        "price": "R169.00",
        "reviews": 35,
        "rating": 5,
        "image": "assets/images/new_arrival_1.png"
      },
      {
        "brand": "B'AIR SKINCARE",
        "name": "10% Niacinamide Serum",
        "price": "R149.00",
        "reviews": 8,
        "rating": 4,
        "image": "assets/images/new_arrival_2.png"
      },
      {
        "brand": "B'AIR SKINCARE",
        "name": "Hyaluronic Acid & Squalane Moisturiser",
        "price": "R185.00",
        "reviews": 19,
        "rating": 5,
        "image": "assets/images/new_arrival_1.png"
      },
      {
        "brand": "B'AIR SKINCARE",
        "name": "2% Alpha Arbutin Serum",
        "price": "R169.00",
        "reviews": 35,
        "rating": 5,
        "image": "assets/images/new_arrival_1.png"
      },
      {
        "brand": "B'AIR SKINCARE",
        "name": "10% Niacinamide Serum",
        "price": "R149.00",
        "reviews": 8,
        "rating": 4,
        "image": "assets/images/new_arrival_2.png"
      },
      {
        "brand": "B'AIR SKINCARE",
        "name": "Hyaluronic Acid & Squalane Moisturiser",
        "price": "R185.00",
        "reviews": 19,
        "rating": 5,
        "image": "assets/images/new_arrival_1.png"
      },
    ];

    final filterChips = [
      {"label": "New", "icon": Icons.auto_awesome},
      {"label": "Bestsellers", "icon": Icons.star_border},
      {"label": "Clean", "icon": Icons.check_circle_outline},
      {"label": "Vegan", "icon": Icons.eco},
      {"label": "Mini Size", "icon": Icons.inventory_2_outlined},
      {"label": "BeautyOnTApp Exclusives", "icon": Icons.card_giftcard},
    ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mini Size",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Filter chips row
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

          // Filters + Best Selling row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _openFilterSheet(context);
                  },
                  icon: const Icon(Icons.filter_list, color: Colors.black),
                  label: const Text(
                    "Filters",
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  children: const [
                    Icon(Icons.swap_vert, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      "Best selling",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Products grid
          Expanded(
            child: Padding(
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
                  final product = products[index];
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
                            child: Image.asset(
                              product["image"] as String,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),

                        // Stars + Reviews
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(
                              product["rating"] as int,
                              (i) => const Icon(Icons.star, color: Colors.black, size: 16),
                            ),
                            ...List.generate(
                              5 - (product["rating"] as int),
                              (i) => const Icon(Icons.star_border, color: Colors.black, size: 16),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "(${product["reviews"]})",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),

                        // Brand
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            product["brand"] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),

                        // Name / description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            product["name"] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // Price
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            product["price"] as String,
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
            ),
          ),
        ],
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                    value: inStock,
                    onChanged: (val) {
                      setState(() => inStock = val!);
                    },
                    title: const Text("In stock (312)"),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: outOfStock,
                    onChanged: (val) {
                      setState(() => outOfStock = val!);
                    },
                    title: const Text("Out of stock (132)"),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const Divider(),

                  // Price Section Placeholder
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Price",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Apply filter logic
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