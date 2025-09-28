// lib/Screens/sale_and_offer_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/static_data.dart';  // For saleAndOfferCategories

class SaleAndOfferScreen extends StatelessWidget {
  const SaleAndOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Sale & Offer',
        style: TextStyle(
          fontWeight: FontWeight.bold
        ),),
        leading: IconButton(
          icon:  Icon(CupertinoIcons.back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 16),
        itemCount: saleAndOfferCategories.length,  // Changed to length of List
        itemBuilder: (context, index) {
          final item = saleAndOfferCategories[index];  // Direct access to list item
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.local_offer, size: 24),
              title: Text(item),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Placeholder: Baad mein yahan specific product list ya detail navigate karna
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected: $item – Coming soon!')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}