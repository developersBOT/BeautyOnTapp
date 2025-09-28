// lib/Screens/men_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/static_data.dart';  // For menCategories

class MenScreen extends StatelessWidget {
  const MenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Men',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 16),
        itemCount: menCategories.length,  // Use the length of menCategories
        itemBuilder: (context, index) {
          final item = menCategories[index]; // Directly use menCategories
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
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
            ),
          );
        },
      ),
    );
  }
}
