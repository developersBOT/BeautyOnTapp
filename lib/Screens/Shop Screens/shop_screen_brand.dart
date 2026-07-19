// lib/Screens/shop_screen_brand.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/static_data.dart';
import '../../widgets/home_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/search_header.dart';
import '../catalog_screen.dart'; // Assuming CatalogScreen and CatalogArgs are defined here

class ShopScreenBrand extends StatefulWidget {
  const ShopScreenBrand({super.key});

  @override
  State<ShopScreenBrand> createState() => _ShopScreenBrandState();
}

class _ShopScreenBrandState extends State<ShopScreenBrand> {
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

    // Get sorted letters
    final letters = brandsByLetter.keys.toList()..sort();

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
                    'Brands ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _ShopColors.titleBlack,
                    ),
                  ),
                  const Text(
                    'A–Z',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _ShopColors.azBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // A-Z expandable list
          SliverList.builder(
            itemCount: letters.length,
            itemBuilder: (context, i) {
              final letter = letters[i];
              final brandList = brandsByLetter[letter] ?? [];
              if (brandList.isEmpty) return const SizedBox.shrink();

              return ExpansionTile(
                title: Text(
                  letter,
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
                children: brandList.map((brand) {
                  return ListTile(
                    title: Text(
                      brand,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _ShopColors.titleBlack,
                      ),
                    ),
                    onTap: () {
                      // Slugify brand for API URL
                      final slug = brand
                          .toLowerCase()
                          .replaceAll(' ', '-')
                          .replaceAll(RegExp(r'[^a-z0-9-]'), '');
                      Get.toNamed(
                        '/catalog',
                        arguments: CatalogArgs(
                          title: brand,
                          apiUrl: 'https://beautyontapp.net/api/products/$slug?limit=100',
                          brand: brand,
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
  static const Color azBlue = Color(0xFF2A72FF);
  // Add other colors if needed
}