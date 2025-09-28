import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/logo_service.dart';

class LogoExplainScreen extends StatefulWidget {
  const LogoExplainScreen({super.key});

  @override
  State<LogoExplainScreen> createState() => _LogoExplainScreenState();
}

class _LogoExplainScreenState extends State<LogoExplainScreen> {
  late String brandName;
  List<dynamic> products = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    brandName = args?['brand'] ?? "";
    print("🔵 [LogoExplainScreen] Brand received: '$brandName'");

    if (brandName.isNotEmpty) {
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

    final result = await LogoService.fetchBrandProducts(brandName);
    print("🔵 [LogoExplainScreen] Products fetched: ${result.length}");

    setState(() {
      products = result;
      isLoading = false;
      hasError = result.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(brandName),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text("No products found for $brandName"))
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
                        (p['image'] is Map) ? p['image']['src'] : null;
                    final title = p['title'] ?? 'No title';
                    final price = (p['variants'] is List &&
                            p['variants'].isNotEmpty &&
                            p['variants'][0]['price'] != null)
                        ? p['variants'][0]['price'].toString()
                        : 'N/A';

                    // ✅ Stock status
                    final inStock = (p['variants'] is List &&
                            p['variants'].isNotEmpty &&
                            (p['variants'][0]['available'] == true ||
                                (p['variants'][0]['inventory_quantity'] ?? 0) >
                                    0))
                        ? "In Stock"
                        : "Out of Stock";

                    return InkWell(
                      onTap: () {
                        if (p['id'] != null) {
                          Get.toNamed('/logo-detail-explain',
                              arguments: {"id": p['id']});
                        } else {
                          print("❌ Product ID missing for $title");
                        }
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
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(Icons.image_not_supported,
                                          size: 40),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
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
                                  horizontal: 8.0, vertical: 4),
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
    );
  }
}
