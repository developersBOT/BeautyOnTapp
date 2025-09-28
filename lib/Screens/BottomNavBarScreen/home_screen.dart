import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:beautyontapp/Screens/catalog_screen.dart';

import 'package:beautyontapp/product_detail_screen_brand.dart'; // ← use API-backed detail

import '../../data/static_data.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';

import '../../widgets/home_header.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/section_title.dart';
import '../../widgets/promo_row.dart';
import '../../widgets/product_scroller.dart';
import '../../widgets/footer_section.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/search_header.dart';
import '../../widgets/brand_logo_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchCtl = TextEditingController();
  bool _showSearch = false;

  late Future<List<Product>> _newArrivalsFuture;
  late Future<List<Product>> _chosenForYouFuture;

  @override
  void initState() {
    super.initState();
    _newArrivalsFuture = ProductService.fetchNewArrivals(limit: 20);
    _chosenForYouFuture = ProductService.fetchSkincareProducts(limit: 100);
  }

  void _doSearch() {
    final q = _searchCtl.text.trim();
    if (q.isEmpty) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Searching for "$q"...')));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: SizedBox(width: w * 0.74, child: const AppSideDrawer()),
      body: CustomScrollView(
        slivers: [
          // header / search
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

          // chips
          SliverToBoxAdapter(
            child: CategoryChips(
              categories: topCategories,
              margin: const EdgeInsets.only(top: 10),
              onTap: (String category) {
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
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // promos (scrollable row; taps route to Catalog with apiUrl if present)
          SliverToBoxAdapter(
            child: PromoRow(
              items: promosTop,
              onTap: (i) {
                final promo = promosTop[i];
                if (promo.apiUrl != null) {
                  Get.toNamed(
                    '/catalog',
                    arguments: CatalogArgs(
                      title: promo.title,
                      apiUrl: promo.apiUrl!,
                      brand: promo.brand ?? '',
                      products: const [], // grid will fetch from apiUrl
                    ),
                  );
                }
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Chosen For You (API)
          const SliverToBoxAdapter(
            child: SectionTitle(title: 'Chosen For You', onShowMore: null),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Product>>(
              future: _chosenForYouFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("Failed to load chosen products"),
                  );
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No products found"),
                  );
                }
                return ProductScroller(
                  products: products,
                  // ⬇ open API-backed detail so HTML description/ingredients render
                  onTap: (p) => Get.to(() => ProductDetailScreenBrand(id: p.id)),
                );
              },
            ),
          ),

          // New Arrivals (API)
          const SliverToBoxAdapter(
            child: SectionTitle(title: 'New Arrivals', onShowMore: null),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Product>>(
              future: _newArrivalsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("Failed to load new arrivals"),
                  );
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No products found"),
                  );
                }
                return ProductScroller(
                  products: products,
                  // ⬇ open API-backed detail so HTML description/ingredients render
                  onTap: (p) => Get.to(() => ProductDetailScreenBrand(id: p.id)),
                );
              },
            ),
          ),

          // POPULAR NOW — brand logos
          const SliverToBoxAdapter(child: SizedBox(height: 6)),
          SliverToBoxAdapter(
            child: BrandLogoGrid(
              logos: brandLogos.take(6).toList(),
              onLogoTap: (brand) {
                Get.toNamed('/logo-explain', arguments: {'brand': brand});
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // footer
          SliverToBoxAdapter(
            child: FooterSection(
              stats: footerStats,
              links: footerCols,
              email: contactEmail,
              address: contactAddress,
            ),
          ),
        ],
      ),
    );
  }
}
