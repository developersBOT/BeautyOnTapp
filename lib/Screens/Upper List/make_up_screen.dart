// lib/Screens/make_up_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/static_data.dart';  // For makeUpEntries

class MakeUpScreen extends StatelessWidget {
  const MakeUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Make Up', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 16),
        itemCount: makeUpEntries.length,  // Use makeUpEntries list
        itemBuilder: (context, index) {
          final item = makeUpEntries[index]; // Directly use makeUpEntries
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.category, size: 24),
              title: Text(item),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // ✅ Navigate to ProductListScreenUpdated with the selected item
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
