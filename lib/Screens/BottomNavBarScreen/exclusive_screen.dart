import 'package:beautyontapp/product_detail_screen_brand.dart'; // adjust path if needed
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/home_header.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/product_scroller.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/search_header.dart';
import '../../data/static_data.dart';
import '../../models/product.dart';
import '../catalog_screen.dart';
import '../../services/product_service.dart';

class ExclusiveScreen extends StatefulWidget {
  const ExclusiveScreen({super.key});

  @override
  State<ExclusiveScreen> createState() => _ExclusiveScreenState();
}

class _ExclusiveScreenState extends State<ExclusiveScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchCtl = TextEditingController();
  bool _showSearch = false;

  late Future<List<Product>> _pastryF;
  late Future<List<Product>> _mzuriF;
  late Future<List<Product>> _bairF;
  late Future<List<Product>> _homF;

  @override
  void initState() {
    super.initState();
    print('[Exclusive] initState() – fetching brand collections…');

    _pastryF = ProductService.fetchBrandProducts('Pastry Skincare', limit: 20);
    _mzuriF  = ProductService.fetchBrandProducts('Mzuri Skin', limit: 20);
    _bairF   = ProductService.fetchBrandProducts("B'Air Collection", limit: 20);
    _homF    = ProductService.fetchBrandProducts('HÓM', limit: 20);
  }

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
          // Header / Search swap
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

          // Chips
          SliverToBoxAdapter(
            child: CategoryChips(
              categories: topCategories,
              margin: const EdgeInsets.only(top: 10),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Pastry Collection
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Pastry Collection',
              actionText: 'View All',
              onActionFuture: _pastryF,
              onViewAll: (items) {
                print('[Exclusive] View All – Pastry (${items.length} items)');
                Get.toNamed(
                  '/catalog',
                  arguments: CatalogArgs(
                    title: 'Pastry Collection',
                    products: items,
                    brand: 'PASTRY',
                  ),
                );
              },
              horizontalPadding: pad,
            ),
          ),
          SliverToBoxAdapter(child: _ScrollerFuture(future: _pastryF)),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Mzuri Skin Collection
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Mzuri Skin Collection',
              actionText: 'View All',
              onActionFuture: _mzuriF,
              onViewAll: (items) {
                print('[Exclusive] View All – Mzuri (${items.length} items)');
                Get.toNamed(
                  '/catalog',
                  arguments: CatalogArgs(
                    title: 'Mzuri Skin Collection',
                    products: items,
                    brand: 'MZURI SKIN',
                  ),
                );
              },
              horizontalPadding: pad,
            ),
          ),
          SliverToBoxAdapter(child: _ScrollerFuture(future: _mzuriF)),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // B'Air Collection
          // SliverToBoxAdapter(
          //   child: _SectionHeader(
          //     title: "B'Air Collection",
          //     actionText: 'View All',
          //     onActionFuture: _bairF,
          //     onViewAll: (items) {
          //       print('[Exclusive] View All – B\'Air (${items.length} items)');
          //       Get.toNamed(
          //         '/catalog',
          //         arguments: CatalogArgs(
          //           title: "B'Air Collection",
          //           products: items,
          //           brand: "B’AiR SKINCARE",
          //         ),
          //       );
          //     },
          //     horizontalPadding: pad,
          //   ),
          // ),
          // SliverToBoxAdapter(child: _ScrollerFuture(future: _bairF)),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // HÓM Skincare Collection
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'HÓM Skincare Collection',
              actionText: 'View All',
              onActionFuture: _homF,
              onViewAll: (items) {
                print('[Exclusive] View All – HÓM (${items.length} items)');
                Get.toNamed(
                  '/catalog',
                  arguments: CatalogArgs(
                    title: 'HÓM Skincare Collection',
                    products: items,
                    brand: 'HÓM',
                  ),
                );
              },
              horizontalPadding: pad,
            ),
          ),
          SliverToBoxAdapter(child: _ScrollerFuture(future: _homF)),

          const SliverToBoxAdapter(child: SizedBox(height: 18)),
        ],
      ),
    );
  }
}

/// Renders a ProductScroller from a Future<List<Product>>
class _ScrollerFuture extends StatelessWidget {
  final Future<List<Product>> future;
  const _ScrollerFuture({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return  Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                height: 40,
                width: 40,
                child: Image.asset(
                  'assets/images/flow.gif',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        }
        if (snap.hasError) {
          print('[Exclusive] ❌ Future error: ${snap.error}');
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Failed to load products'),
          );
        }
        final items = snap.data ?? const <Product>[];
        print('[Exclusive] ✅ loaded ${items.length} items');
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No products found'),
          );
        }
        return ProductScroller(
          products: items,
          onTap: (p) {
            print('[Exclusive] tap ${p.id} – ${p.title}');
            Get.to(() => ProductDetailScreenBrand(id: p.id));
          },
        );
      },
    );
  }
}

/// Title + View All (that waits the same future so "View All" can pass loaded items)
class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final double horizontalPadding;
  final Future<List<Product>> onActionFuture;
  final void Function(List<Product>) onViewAll;

  const _SectionHeader({
    required this.title,
    required this.onActionFuture,
    required this.onViewAll,
    this.actionText = 'View All',
    this.horizontalPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          FutureBuilder<List<Product>>(
            future: onActionFuture,
            builder: (context, snap) {
              final enabled = snap.hasData && (snap.data?.isNotEmpty ?? false);
              return GestureDetector(
                onTap: enabled ? () => onViewAll(snap.data!) : null,
                child: Text(
                  actionText,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: enabled ? Colors.blueAccent : Colors.black26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}