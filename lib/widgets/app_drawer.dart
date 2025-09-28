import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/static_data.dart';

class AppSideDrawer extends StatelessWidget {
  const AppSideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final items = topCategories; // ✅ same list jo HomeScreen me use ho rahi hai
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(CupertinoIcons.xmark, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFEDEDED)),
                itemBuilder: (_, i) {
                  final category = items[i];
                  return InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      Navigator.of(context).pop();

                      // ✅ same navigation as CategoryChips
                      if (category == 'Brands') {
                        Get.toNamed('/brands');
                      } else if (category == 'Skin Care') {
                        Get.toNamed('/skin-care');
                      } else if (category == 'Hair') {
                        Get.toNamed('/hair');
                      } else if (category == 'Make Up') {
                        Get.toNamed('/make-up');
                      } else if (category == 'Men') {
                        Get.toNamed('/men');
                      } else if (category == 'Bath & Body') {
                        Get.toNamed('/bath-body');
                      } else if (category == 'Korean SkinCare') {
                        Get.toNamed('/korean-skin-care');
                      } else if (category == 'Suncare') {
                        Get.toNamed('/suncare');
                      } else if (category == 'Sale & Offer') {
                        Get.toNamed('/sale-offer');
                      } else if (category == 'Beauty Under R200') {
                        Get.toNamed('/beauty-under-200');
                      } else if (category == 'Mini Size') {
                        Get.toNamed('/mini-size');
                      } else if (category == 'Book Skin Analysis') {
                        Get.toNamed('/book-skin-analysis');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Coming soon: $category')),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
