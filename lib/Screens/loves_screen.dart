import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/home_header.dart';
import '../widgets/category_chips.dart';
import '../widgets/black_footer.dart';
import '../widgets/app_drawer.dart';
import '../data/static_data.dart';
import '../models/wish_item.dart';

class LovesScreen extends StatelessWidget {
  const LovesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.06;
    final items = wishlistItems;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: SizedBox(width: w * 0.74, child: const AppSideDrawer()),
      body: Builder(
        builder: (ctx) => ListView(
          children: [
            HomeHeader(
              onMenu: () => Scaffold.of(ctx).openDrawer(),
              onSearch: () {}, // your search swap already in HomeHeader
              onCart: () => Get.toNamed('/cart'),
            ),

            CategoryChips(categories: topCategories, margin: const EdgeInsets.only(top: 10)),
            const SizedBox(height: 14),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: const Text('Wishlist',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 10),

            // list
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Column(
                children: items.map((e) => _WishRow(item: e)).toList(),
              ),
            ),

            const SizedBox(height: 20),
            const BlackFooter(),
          ],
        ),
      ),
    );
  }
}

class _WishRow extends StatelessWidget {
  final WishItem item;
  const _WishRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.imageAsset,
              width: 70,
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),

          // texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.brand.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(item.title,
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w600)),
                if (item.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(item.subtitle,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black87)),
                ],
                const SizedBox(height: 8),
                Text('R ${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
