// lib/Screens/shop_screen_bath_and_body.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';

import '../../data/static_data.dart';
import '../../widgets/home_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/search_header.dart';
import '../catalog_screen.dart'; // Assuming CatalogScreen and CatalogArgs are defined here

class ShopScreenBathAndBody extends StatefulWidget {
  const ShopScreenBathAndBody({super.key});

  @override
  State<ShopScreenBathAndBody> createState() => _ShopScreenBathAndBodyState();
}

class _ShopScreenBathAndBodyState extends State<ShopScreenBathAndBody> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchCtl = TextEditingController();
  bool _showSearch = false;

  void _doSearch() {
    final q = _searchCtl.text.trim();
    if (q.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for "$q"...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.04;

    // Get sorted categories
    final categories = bathAndBodyCategories.keys.toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: SizedBox(width: w * 0.74, child: const AppSideDrawer()),
      body: CustomScrollView(
        slivers: [
          // header / search toggle
          SliverToBoxAdapter(
            child: _showSearch
                ? SearchHeader(
                    controller: _searchCtl,
                    onBack: () => setState(() {
                      _showSearch = false;
                      _searchCtl.clear();
                    }),
                    onSubmit: _doSearch,
                  )
                : HomeHeader(
                    onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                    onSearch: () => setState(() => _showSearch = true),
                    onCart: () => Get.toNamed('/cart'),
                  ),
          ),

          // page title
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, 14, pad, 8),
              child: Row(
                children: [
                  const Text(
                    'Bath & Body',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _ShopColors.titleBlack,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(CupertinoIcons.cube_box,
                      color: _ShopColors.sunAmber, size: 20),
                ],
              ),
            ),
          ),

          // Expandable list for categories
          SliverList.builder(
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final category = categories[i];
              final subItems = bathAndBodyCategories[category] ?? [];
              if (subItems.isEmpty) return const SizedBox.shrink();

              return ExpansionTile(
                title: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _ShopColors.titleBlack,
                  ),
                ),
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black54,
                ),
                childrenPadding: const EdgeInsets.only(left: 16),
                children: subItems.map((sub) {
                  return ListTile(
                    title: Text(
                      sub,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _ShopColors.titleBlack,
                      ),
                    ),
                    onTap: () {
                      // Slugify sub-item for API URL
                      final slug = sub
                          .toLowerCase()
                          .replaceAll(' ', '-')
                          .replaceAll(RegExp(r'[^a-z0-9-]'), '');
                      Get.toNamed(
                        '/catalog',
                        arguments: CatalogArgs(
                          title: sub,
                          apiUrl: 'https://beautyontapp.net/api/products/$slug?limit=100',
                          brand: '',
                          products: const [],
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

/* === Helper Classes === */

class _ShopColors {
  static const Color titleBlack = Color(0xFF111111);
  static const Color sunAmber = Color(0xFFFFB54C);
  // Add other colors if needed
}