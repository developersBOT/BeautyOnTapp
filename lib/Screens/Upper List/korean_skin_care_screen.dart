// lib/Screens/korean_skin_care_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/static_data.dart';  // For koreanSkinCareEntries

class KoreanSkinCareScreen extends StatelessWidget {
  const KoreanSkinCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Korean SkinCare',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 16),
        itemCount: koreanSkinCareEntries.length,  // Corrected itemCount for list-based data
        itemBuilder: (context, index) {
          final item = koreanSkinCareEntries[index];  // Directly access item in the list
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.category, size: 24),
              title: Text(
                item,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // ✅ Navigate to ProductListScreenUpdated with keyword
                Get.toNamed(
                  '/products',
                  arguments: {
                    'title': item,  // Use the item as title
                    'keyword': item,  // Use the item as keyword for API call
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
