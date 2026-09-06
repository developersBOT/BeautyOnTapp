import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../widgets/home_header.dart';
import '../widgets/category_chips.dart';
import '../widgets/black_footer.dart';
import '../widgets/app_drawer.dart';
import '../data/static_data.dart';
import '../models/product.dart';

/// Navigation Args
class CatalogArgs {
  final String title;
  final List<Product>? products; // optional, fallback if no apiUrl
  final String? brand;           // optional label above titles
  final String? apiUrl;          // 👈 new: fetch from API if present
  CatalogArgs({required this.title, this.products, this.brand, this.apiUrl});
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  RangeValues _priceRange = const RangeValues(0, 1000);
  bool _inStock = false;
  bool _outOfStock = false;

  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as CatalogArgs?;
    if (args?.apiUrl != null) {
      _futureProducts = _fetchFromApi(args!.apiUrl!);
    } else {
      _futureProducts = Future.value(args?.products ?? productsNewArrivals);
    }
  }

  Future<List<Product>> _fetchFromApi(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final list = body['data'] as List? ?? [];
        return list.map((e) => Product.fromJson(e)).toList();
      } else {
        throw Exception("Failed with ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ API error: $e");
      return [];
    }
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        RangeValues price = _priceRange;
        bool inStock = _inStock;
        bool outOfStock = _outOfStock;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final w = MediaQuery.sizeOf(context).width;
            final pad = w * 0.06;

            return SafeArea(
              top: false,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(pad, 16, pad, 8),
                      child: Row(
                        children: [
                          const Text('Filters',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800)),
                          const Spacer(),
                          IconButton(
                            icon:
                                const Icon(Icons.close, color: Colors.black87),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEDEDED)),

                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: pad),
                        children: [
                          const SizedBox(height: 16),
                          const Text('Availability',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          _CheckRow(
                            label: 'In stock',
                            trailing: const Text('(284)',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54)),
                            value: inStock,
                            onChanged: (v) =>
                                setSheetState(() => inStock = v ?? false),
                          ),
                          const SizedBox(height: 10),
                          _CheckRow(
                            label: 'Out of stock',
                            trailing: const Text('(60)',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54)),
                            value: outOfStock,
                            onChanged: (v) =>
                                setSheetState(() => outOfStock = v ?? false),
                          ),
                          const SizedBox(height: 18),
                          const Divider(height: 24, color: Color(0xFFEDEDED)),
                          const Text('Price',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                          RangeSlider(
                            values: price,
                            min: 0,
                            max: 1000,
                            divisions: 20,
                            labels: RangeLabels(
                              'R ${price.start.round()}',
                              'R ${price.end.round()}',
                            ),
                            onChanged: (vals) =>
                                setSheetState(() => price = vals),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(pad, 8, pad, 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _priceRange = price;
                              _inStock = inStock;
                              _outOfStock = outOfStock;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('APPLY',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as CatalogArgs?;
    final title = args?.title ?? 'Catalog';
    final brandLabel = args?.brand;

    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.06;
    const gap = 14.0;

    final tileW = (w - pad * 2 - gap) / 2;
    final imgH = tileW * 0.9;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: SizedBox(width: w * 0.74, child: const AppSideDrawer()),
      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Image.asset(
                'assets/images/flow.gif',
                width: 100,
                height: 100,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("❌ Error: ${snapshot.error}"),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text("No products found"));
          }

          return ListView(
            children: [
              HomeHeader(
                onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                onSearch: () {},
                onCart: () => Get.toNamed('/cart'),
              ),
              CategoryChips(
                  categories: topCategories,
                  margin: const EdgeInsets.only(top: 10)),
              const SizedBox(height: 10),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Center(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Row(
                  children: [
                    _ChipButton(
                      icon: Icons.tune_rounded,
                      label: 'Filters',
                      onTap: _openFilters,
                    ),
                    const Spacer(),
                    const Icon(Icons.bar_chart_rounded,
                        size: 18, color: Colors.black87),
                    const SizedBox(width: 6),
                    const Text('Best selling',
                        style: TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Wrap(
                  spacing: gap,
                  runSpacing: gap + 4,
                  children: items.map((p) {
                    return SizedBox(
                      width: tileW,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              color: const Color(0xFFF7F7F7),
                              child: p.imageUrl.isNotEmpty
                                  ? Image.network(
                                      p.imageUrl,
                                      width: tileW,
                                      height: imgH,
                                      fit: BoxFit.contain,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return SizedBox(
                                          width: tileW,
                                          height: imgH,
                                          child: Center(
                                            child: Image.asset(
                                              'assets/images/flow.gif',
                                              width: 50,
                                              height: 50,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return SizedBox(
                                          width: tileW,
                                          height: imgH,
                                          child: const Center(
                                            child: Icon(Icons.broken_image,
                                                size: 50, color: Colors.grey),
                                          ),
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      p.imageAsset,
                                      width: tileW,
                                      height: imgH,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (brandLabel != null)
                            Text(brandLabel,
                                style: const TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(p.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700)),
                          if (p.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(p.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11.5, color: Colors.black87)),
                          ],
                          const SizedBox(height: 8),
                          Text('R ${p.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              const BlackFooter(),
            ],
          );
        },
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ChipButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEDEDED)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.black87),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Widget? trailing;

  const _CheckRow({
    required this.label,
    required this.value,
    this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: const BorderSide(color: Color(0xFFDDDDDD)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}