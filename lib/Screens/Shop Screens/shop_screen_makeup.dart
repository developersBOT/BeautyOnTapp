// lib/Screens/shop_screen_makeup.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';

import '../../data/static_data.dart';
import '../../widgets/home_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/search_header.dart';
import '../catalog_screen.dart'; // Assuming CatalogScreen and CatalogArgs are defined here

class ShopScreenMakeup extends StatefulWidget {
  const ShopScreenMakeup({super.key});

  @override
  State<ShopScreenMakeup> createState() => _ShopScreenMakeupState();
}

class _ShopScreenMakeupState extends State<ShopScreenMakeup> {
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
                    'Make Up',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _ShopColors.titleBlack,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(CupertinoIcons.paintbrush,
                      color: _ShopColors.sparkPink, size: 20),
                ],
              ),
            ),
          ),

          // Flat list of subcategories with dividers
          SliverList.separated(
            itemCount: makeUpEntries.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: Colors.grey,
            ),
            itemBuilder: (context, i) {
              final sub = makeUpEntries[i];
              return ListTile(
                title: Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _ShopColors.titleBlack,
                  ),
                ),
                onTap: () {
                  // Slugify sub-item for API URL, prefixed with 'make-up-'
                  final slug = sub
                      .toLowerCase()
                      .replaceAll(' ', '-')
                      .replaceAll(RegExp(r'[^a-z0-9-]'), '');
                  Get.toNamed(
                    '/catalog',
                    arguments: CatalogArgs(
                      title: sub,
                      apiUrl: 'https://beautyontapp.net/api/products/make-up-$slug?limit=100',
                      brand: '',
                      products: const [],
                    ),
                  );
                },
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
  static const Color sparkPink = Color(0xFFFF6F61);
  // Add other colors if needed
}