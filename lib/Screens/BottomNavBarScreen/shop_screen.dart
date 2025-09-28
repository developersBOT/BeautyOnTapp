// lib/Screens/shop_screen.dart
import 'package:beautyontapp/Screens/featured_catalog_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/home_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/search_header.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
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

  // 👇 Navigation same as HomeScreen chips
  void _navigateCategory(String category) {
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
    } else if (category == 'Korean Skincare') {
      Get.toNamed('/korean-skin-care');
    } else if (category == 'Beauty Under R200') {
      Get.toNamed('/beauty-under-200');
    } else if (category == 'Mini Size') {
      Get.toNamed('/mini-size');
    } else if (category == 'Suncare') {
      Get.toNamed('/suncare');
    } else if (category == 'Book Skin Analysis') {
      Get.toNamed('/book-skin-analysis');
    } else if (category == 'Sales & Offers') {
      Get.toNamed('/sale-offer');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coming soon: $category')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.04;

    final tiles = <_TileMeta>[
      _TileMeta('Brands',
          right: const Text('A–Z',
              style: TextStyle(
                  color: _ShopColors.azBlue, fontWeight: FontWeight.w700))),
      _TileMeta('Skin Care',
          right: const Icon(CupertinoIcons.sparkles,
              color: _ShopColors.sparkPink)),
      _TileMeta('Hair',
          right: const Icon(CupertinoIcons.wind, color: _ShopColors.sunAmber)),
      _TileMeta('Make Up',
          right: const Icon(CupertinoIcons.paintbrush,
              color: _ShopColors.sparkPink)),
      _TileMeta('Men',
          right:
              const Icon(CupertinoIcons.person, color: _ShopColors.mutedGrey)),
      _TileMeta('Bath & Body',
          right: const Icon(CupertinoIcons.cube_box,
              color: _ShopColors.sunAmber)),
      _TileMeta('Korean Skincare',
          right: const Icon(CupertinoIcons.person_crop_circle_badge_checkmark,
              color: _ShopColors.kBeautyPink)),
      _TileMeta('Beauty Under R200',
          right: const Icon(CupertinoIcons.bandage,
              color: _ShopColors.sparkPink)),
      _TileMeta('Mini Size',
          right: const Icon(CupertinoIcons.cube, color: _ShopColors.miniBlue)),
      _TileMeta('Suncare',
          right: const Icon(CupertinoIcons.sun_max,
              color: _ShopColors.sunYellow)),
      _TileMeta('Book Skin Analysis',
          right: const Icon(CupertinoIcons.person_crop_circle,
              color: _ShopColors.sandBrown)),
      _TileMeta('Sales & Offers',
          right:
              const Icon(CupertinoIcons.gift, color: _ShopColors.sparkPink)),
    ];

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
              child: const Text(
                'Shop',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _ShopColors.titleBlack,
                ),
              ),
            ),
          ),

          // grid 2 cards per row
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Column(
                children: [
                  for (int i = 0; i < tiles.length; i += 2)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ShopTile(
                              label: tiles[i].label,
                              right: tiles[i].right,
                              onTap: () => _navigateCategory(tiles[i].label),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (i + 1 < tiles.length)
                            Expanded(
                              child: _ShopTile(
                                label: tiles[i + 1].label,
                                right: tiles[i + 1].right,
                                onTap: () =>
                                    _navigateCategory(tiles[i + 1].label),
                              ),
                            )
                          else
                            const Spacer(),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Featured list
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, 12, pad, 6),
              child: const Text(
                'Featured',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SliverList.separated(
            itemCount: _featured.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: FeaturedCard(
                title: _featured[i],
                onTap: () {
                  final title = _featured[i];
                  final url = _featuredApi[title];
                  if (url != null) {
                    Get.to(() =>
                        FeaturedCatalogScreen(title: title, apiUrl: url));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('API not configured for $title')),
                    );
                  }
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

/* === Helper Classes === */

class _TileMeta {
  final String label;
  final Widget? right;
  const _TileMeta(this.label, {this.right});
}

class _ShopTile extends StatelessWidget {
  final String label;
  final Widget? right;
  final VoidCallback? onTap;

  const _ShopTile({required this.label, this.right, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: Material(
        color: _ShopColors.tileBg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: _ShopColors.tileBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _ShopColors.tileBorder, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: _ShopColors.tileShadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _ShopColors.titleBlack,
                    ),
                  ),
                ),
                if (right != null) right!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShopColors {
  static const Color titleBlack = Color(0xFF111111);
  static const Color tileBg = Colors.white;
  static const Color tileBorder = Color(0xFFEDEDED);
  static const Color tileShadow = Color(0x14000000);
  static const Color azBlue = Color(0xFF2A72FF);
  static const Color sparkPink = Color(0xFFFF6F61);
  static const Color sunAmber = Color(0xFFFFB54C);
  static const Color mutedGrey = Color(0xFF6C7A89);
  static const Color kBeautyPink = Color(0xFFFB6AA2);
  static const Color miniBlue = Color(0xFF7BC5FF);
  static const Color sunYellow = Color(0xFFFFC83D);
  static const Color sandBrown = Color(0xFFB28B56);
}

class FeaturedCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const FeaturedCard({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEDEDED), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
              const Icon(CupertinoIcons.chevron_right,
                  size: 18, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}

const _featured = [
  'Trending on Social',
  'Only at BeautyOnTApp',
  'Bestsellers',
  'Hyperpigmentation',
  'Local-Owned Brands',
  'Luxury Skin Care',
  'K-Beauty',
];

const Map<String, String> _featuredApi = {
  'Trending on Social':
      'https://beautyontapp.net/api/products/Skincare?limit=20',
  'Only at BeautyOnTApp':
      'https://beautyontapp.net/api/products/only-at-beautyontapp?limit=20',
  'Bestsellers':
      'https://beautyontapp.net/api/products/best-seller?limit=100',
  'Hyperpigmentation':
      'https://beautyontapp.net/api/products/hyperpigmentation?limit=100',
  'Local-Owned Brands':
      'https://beautyontapp.net/api/products/only-at-beautyontapp?limit=20',
  'Luxury Skin Care':
      'https://beautyontapp.net/api/products/dermalogica?limit=20',
  'K-Beauty':
      'https://beautyontapp.net/api/products/korean-skincare?limit=20',
};
