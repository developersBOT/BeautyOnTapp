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

    List<String> letters = brandsByLetter.keys.toList()..sort();
    List<Widget> sections = [];

    for (var l in letters) {
      final letter = l.toUpperCase();
      final brands = brandsByLetter[l] ?? [];

      sections.add(
        Padding(
          padding: EdgeInsets.only(left: w * 0.04, top: 16, bottom: 8),
          child: Text(
            letter,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );

      sections.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.04),
          child: Wrap(
            spacing: w * 0.05,
            runSpacing: 8,
            children: brands.map((brand) {
              return GestureDetector(
                onTap: () {
                  Get.to(() => BrandProductsScreen(brandName: brand));
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    brand,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

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
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: sections,
      ),
    );
  }
}