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

import 'dart:ui'; // ← Added for ImageFilter

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchCtl = TextEditingController();
  bool _showSearch = false;

  late Future<List<List<Product>>> _combinedFutures;

  // Added state variables for products, loading, and error
  List<Product> chosenProducts = [];
  List<Product> newArrivalProducts = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    final newArrivalsFuture = ProductService.fetchNewArrivals(limit: 20);
    final chosenForYouFuture = ProductService.fetchSkincareProducts(limit: 100);
    _combinedFutures = Future.wait([chosenForYouFuture, newArrivalsFuture]);

    // Handle future completion
    _combinedFutures.then((data) {
      if (mounted) {
        setState(() {
          chosenProducts = data[0];
          newArrivalProducts = data[1];
          isLoading = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    });
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
      body: hasError
          ? const Center(child: Text("Failed to load products"))
          : (!isLoading &&
                  chosenProducts.isEmpty &&
                  newArrivalProducts.isEmpty)
              ? const Center(child: Text("No products found"))
              : Stack(
                  children: [
                    CustomScrollView(
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
                                  onMenu: () =>
                                      _scaffoldKey.currentState?.openDrawer(),
                                  onSearch: () =>
                                      setState(() => _showSearch = true),
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
                                  SnackBar(
                                      content: Text('Coming soon: $category')),
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
                          child:
                              SectionTitle(title: 'Chosen For You', onShowMore: null),
                        ),
                        SliverToBoxAdapter(
                          child: chosenProducts.isEmpty && !isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text("No products found"),
                                )
                              : ProductScroller(
                                  products: chosenProducts,
                                  // ⬇ open API-backed detail so HTML description/ingredients render
                                  onTap: (p) => Get.to(
                                      () => ProductDetailScreenBrand(id: p.id)),
                                ),
                        ),

                        // New Arrivals (API)
                        const SliverToBoxAdapter(
                          child:
                              SectionTitle(title: 'New Arrivals', onShowMore: null),
                        ),
                        SliverToBoxAdapter(
                          child: newArrivalProducts.isEmpty && !isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text("No products found"),
                                )
                              : ProductScroller(
                                  products: newArrivalProducts,
                                  // ⬇ open API-backed detail so HTML description/ingredients render
                                  onTap: (p) => Get.to(
                                      () => ProductDetailScreenBrand(id: p.id)),
                                ),
                        ),

                        // POPULAR NOW — brand logos
                        const SliverToBoxAdapter(child: SizedBox(height: 6)),
                        SliverToBoxAdapter(
                          child: BrandLogoGrid(
                            logos: brandLogos.take(6).toList(),
                            onLogoTap: (brand) {
                              Get.toNamed('/logo-explain',
                                  arguments: {'brand': brand});
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
                    if (isLoading)
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Container(
                            color: Colors.black.withOpacity(0.3), // Semi-transparent dim for better blur effect
                            child: Center(
                              child: Image.asset('assets/images/flow.gif'),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}