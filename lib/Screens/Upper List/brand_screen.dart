import 'package:beautyontapp/Screens/brand_products_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/static_data.dart'; 

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Brands',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 16),
        itemCount: brandsByLetter.keys.length,
        itemBuilder: (context, index) {
          final letter = brandsByLetter.keys.elementAt(index).toUpperCase();
          final brands = brandsByLetter[letter] ?? [];

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              title: Text(
                letter,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              children: brands
                  .map((brand) => ListTile(
                        leading:
                            const Icon(Icons.branding_watermark, size: 24),
                        title: Text(brand),
                        trailing:
                            const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // 🔥 Navigate to API-driven BrandProductsScreen
                          Get.to(() => BrandProductsScreen(brandName: brand));
                        },
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
