// lib/Screens/skin_care_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/static_data.dart';  // For skinCareCategories

class SkinCareScreen extends StatelessWidget {
  const SkinCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          'Skin Care',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 16),
        itemCount: skinCareCategories.keys.length,
        itemBuilder: (context, index) {
          final category = skinCareCategories.keys.elementAt(index);
          final items = skinCareCategories[category] ?? [];
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
                    // ✅ Navigate to ProductListScreenUpdated with keyword
                    Get.toNamed(
                      '/products',
                      arguments: {
                        'title': item,
                        'keyword': item, // API call ke liye
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
