import 'package:beautyontapp/product_detail_screen_brand.dart';
import 'package:flutter/material.dart';
import '../models/brand_product_model.dart';
import '../services/brand_service.dart';

class BrandProductsScreen extends StatefulWidget {
  final String brandName;

  const BrandProductsScreen({super.key, required this.brandName});

  @override
  State<BrandProductsScreen> createState() => _BrandProductsScreenState();
}

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  late Future<List<BrandProduct>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = BrandService.fetchBrandProducts(widget.brandName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Text(
          
          widget.brandName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<List<BrandProduct>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Image.asset(
                'assets/images/flow.gif',
                width: 100,
                height: 100,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "❌ Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print("⚠️ No products in UI: ${snapshot.data}");
            return const Center(child: Text("No products found."));
          }

          final products = snapshot.data!;
          print("✅ Showing ${products.length} products in UI");

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              final imageUrl = product.image.isNotEmpty
                  ? product.image
                  : "https://via.placeholder.com/150";
              final priceText = product.price > 0
                  ? "R ${product.price.toStringAsFixed(2)}"
                  : "Price: N/A";

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreenBrand(id: product.id)
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: Image.asset(
                                'assets/images/flow.gif',
                                width: 50,
                                height: 50,
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported, size: 50),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          product.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          priceText,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          product.inStock ? "In Stock" : "Sold Out",
                          style: TextStyle(
                            color: product.inStock ? Colors.black : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}