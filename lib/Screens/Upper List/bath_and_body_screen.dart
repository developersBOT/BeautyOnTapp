// lib/Screens/bath_and_body_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/static_data.dart';  // For bathAndBodyCategories

class BathAndBodyScreen extends StatelessWidget {
  const BathAndBodyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Bath & Body',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 16),
        itemCount: bathAndBodyCategories.keys.length,  // Use the length of bathAndBodyCategories
        itemBuilder: (context, index) {
          final category = bathAndBodyCategories.keys.elementAt(index);
          final items = bathAndBodyCategories[category] ?? [];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              title: Text(
                category,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              children: items.map((item) {
                return ListTile(
                  leading: const Icon(Icons.category, size: 24),
                  title: Text(item),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // ✅ Navigate to ProductListScreenUpdated with the selected category
                    Get.toNamed(
                      '/products',
                      arguments: {
                        'title': item,
                        'keyword': item, // Pass category keyword for product search
                      },
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
