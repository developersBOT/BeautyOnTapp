// lib/Screens/shop_screen.dart
import 'package:beautyontapp/Screens/featured_catalog_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../data/static_data.dart';
import '../../widgets/home_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/search_header.dart';
import '../catalog_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchCtl = TextEditingController();
  bool _showSearch = false;

  // State for dropdown
  String? _selectedCategory;
  Offset? _dropdownPosition;
  List<dynamic>? _dropdownData;
  bool _isSecondLevel = false; // Track if showing second level
  String? _selectedParentItem; // Track which parent item was clicked

  // Create GlobalKeys once for each tile
  final List<GlobalKey> _tileKeys = List.generate(12, (_) => GlobalKey());

  void _doSearch() {
    final q = _searchCtl.text.trim();
    if (q.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for "$q"...')),
    );
  }

  void _showDropdown(String category, Offset position) async {
    print('Showing dropdown for: $category at $position');
    List<dynamic> data = await _fetchDropdownData(category);
    if (mounted) {
      setState(() {
        _selectedCategory = category;
        _dropdownPosition = position;
        _dropdownData = data;
        _isSecondLevel = false;
        _selectedParentItem = null;
      });
    }
  }

  void _showSecondLevelDropdown(String parentItem) async {
    print('Showing second level for: $parentItem');
    List<dynamic> data = await _fetchSecondLevelData(_selectedCategory!, parentItem);
    if (mounted) {
      setState(() {
        _dropdownData = data;
        _isSecondLevel = true;
        _selectedParentItem = parentItem;
      });
    }
  }

  void _hideDropdown() {
    if (mounted) {
      setState(() {
        _selectedCategory = null;
        _dropdownPosition = null;
        _dropdownData = null;
        _isSecondLevel = false;
        _selectedParentItem = null;
      });
    }
  }

  Future<List<dynamic>> _fetchDropdownData(String category) async {
    switch (category) {
      case 'Brands':
        // Return A-Z letters
        return brandsByLetter.keys.map((letter) => {'name': letter, 'isLetter': true}).toList();
      
      case 'Skin Care':
        // Return category names (Skin Type, Skin Concern, etc.)
        return skinCareCategories.keys.map((categoryName) => {'name': categoryName, 'isCategory': true}).toList();
      
      case 'Hair':
        // Return category names
        return hairCategories.keys.map((categoryName) => {'name': categoryName, 'isCategory': true}).toList();
      
      case 'Bath & Body':
        // Return category names
        return bathAndBodyCategories.keys.map((categoryName) => {'name': categoryName, 'isCategory': true}).toList();
      
      case 'Suncare':
        // Return category names
        return sunCareCategories.keys.map((categoryName) => {'name': categoryName, 'isCategory': true}).toList();
      
      case 'Make Up':
        return makeUpEntries.map((item) => {'name': item}).toList();
      
      case 'Men':
        return menCategories.map((item) => {'name': item}).toList();
      
      case 'Korean Skincare':
        return koreanSkinCareEntries.map((item) => {'name': item}).toList();
      
      case 'Book Skin Analysis':
        return bookSkinAnalysisItems.map((item) => {'name': item['title']!}).toList();
      
      case 'Sales & Offers':
        return saleAndOfferCategories.map((item) => {'name': item}).toList();
      
      case 'Beauty Under R200':
      case 'Mini Size':
        // These don't need two levels - try API directly
        try {
          final String url = 'https://beautyontapp.net/api/products/${category.toLowerCase().replaceAll(' ', '-')}?limit=100';
          final response = await http.get(Uri.parse(url));
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data is Map && data.containsKey('products')) {
              return List<Map<String, dynamic>>.from(data['products'] ?? []);
            } else if (data is List) {
              return List<Map<String, dynamic>>.from(data);
            }
          }
        } catch (e) {
          print('API Error for $category: $e');
        }
        return [];
      
      default:
        return [];
    }
  }

  Future<List<dynamic>> _fetchSecondLevelData(String category, String parentItem) async {
    switch (category) {
      case 'Brands':
        // Return brands for selected letter
        final brands = brandsByLetter[parentItem] ?? [];
        return brands.map((brand) => {'name': brand}).toList();
      
      case 'Skin Care':
        // Return items for selected category
        final items = skinCareCategories[parentItem] ?? [];
        return items.map((item) => {'name': item}).toList();
      
      case 'Hair':
        // Return items for selected category
        final items = hairCategories[parentItem] ?? [];
        return items.map((item) => {'name': item}).toList();
      
      case 'Bath & Body':
        // Return items for selected category
        final items = bathAndBodyCategories[parentItem] ?? [];
        return items.map((item) => {'name': item}).toList();
      
      case 'Suncare':
        // Return items for selected category
        final items = sunCareCategories[parentItem] ?? [];
        return items.map((item) => {'name': item}).toList();
      
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.04;

    final tiles = [
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

    return GestureDetector(
      onTap: _hideDropdown,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: SizedBox(width: w * 0.74, child: const AppSideDrawer()),
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
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
                                  child: _buildTile(tiles[i], i),
                                ),
                                const SizedBox(width: 10),
                                if (i + 1 < tiles.length)
                                  Expanded(
                                    child: _buildTile(tiles[i + 1], i + 1),
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
                            SnackBar(
                                content: Text('API not configured for $title')),
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
            if (_selectedCategory != null && _dropdownPosition != null)
              Positioned(
                top: _dropdownPosition!.dy + 90,
                left: pad,
                right: pad,
                child: _buildDropdown(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(_TileMeta tile, int index) {
    return _ShopTile(
      key: _tileKeys[index],
      label: tile.label,
      right: tile.right,
      onTap: () {
        print('Tapped on: ${tile.label}');
        final renderBox = _tileKeys[index].currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final offset = renderBox.localToGlobal(Offset.zero);
          print('Tile position for ${tile.label}: $offset');
          _showDropdown(tile.label, offset);
        }
      },
    );
  }

  Widget _buildDropdown() {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    final pad = w * 0.04;

    List<Widget> dropdownItems = [];
    
    if (_dropdownData == null) {
      dropdownItems = [
         Padding(
          padding: EdgeInsets.all(16.0),
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
        )
      ];
    } else if (_dropdownData!.isEmpty) {
      dropdownItems = [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No items found')),
        )
      ];
    } else {
      // Check if this is first level (letters/categories) or second level (actual items)
      final isFirstLevel = _dropdownData!.isNotEmpty && 
                          (_dropdownData![0]['isLetter'] == true || 
                           _dropdownData![0]['isCategory'] == true);

      if (isFirstLevel) {
        // First level - show letters or category names with arrow
        dropdownItems = _dropdownData!.map((item) {
          final name = item['name'] as String? ?? 'Unknown';
          return InkWell(
            onTap: () => _showSecondLevelDropdown(name),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  const Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.black54),
                ],
              ),
            ),
          );
        }).toList();
      } else {
        // Second level - show actual items (brands/products)
        dropdownItems = _dropdownData!.map((item) {
          final name = item['name'] as String? ?? 'Unknown';
          return InkWell(
            onTap: () {
              _hideDropdown();
              _navigateToCatalog(name);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111111),
                ),
              ),
            ),
          );
        }).toList();
      }
    }

    // Add back button if on second level
    if (_isSecondLevel && _selectedParentItem != null) {
      dropdownItems.insert(0, InkWell(
        onTap: () async {
          List<dynamic> data = await _fetchDropdownData(_selectedCategory!);
          setState(() {
            _dropdownData = data;
            _isSecondLevel = false;
            _selectedParentItem = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            border: Border(bottom: BorderSide(color: Color(0xFFEDEDED))),
          ),
          child: Row(
            children: [
              const Icon(CupertinoIcons.chevron_left, size: 16, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                'Back to ${_selectedCategory}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),
            ],
          ),
        ),
      ));
    }

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: w - (pad * 2),
        constraints: BoxConstraints(
          maxHeight: h * 0.6,
          minHeight: 100,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEDEDED), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: dropdownItems.length,
            separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
            itemBuilder: (context, index) => dropdownItems[index],
          ),
        ),
      ),
    );
  }

  void _navigateToCatalog(String name) {
    final slug = name
        .toLowerCase()
        .replaceAll(' ', '-')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '');
    
    String apiUrl;
    
    switch (_selectedCategory) {
      case 'Brands':
        apiUrl = 'https://beautyontapp.net/api/products/$slug?limit=100';
        break;
      case 'Skin Care':
        apiUrl = 'https://beautyontapp.net/api/products/skincare-$slug?limit=100';
        break;
      case 'Hair':
        apiUrl = 'https://beautyontapp.net/api/products/hair-$slug?limit=100';
        break;
      case 'Make Up':
        apiUrl = 'https://beautyontapp.net/api/products/make-up-$slug?limit=100';
        break;
      case 'Men':
        apiUrl = 'https://beautyontapp.net/api/products/men-$slug?limit=100';
        break;
      case 'Bath & Body':
        apiUrl = 'https://beautyontapp.net/api/products/bath-body-$slug?limit=100';
        break;
      case 'Korean Skincare':
        apiUrl = 'https://beautyontapp.net/api/products/korean-skincare-$slug?limit=100';
        break;
      case 'Suncare':
        apiUrl = 'https://beautyontapp.net/api/products/suncare-$slug?limit=100';
        break;
      default:
        apiUrl = 'https://beautyontapp.net/api/products/$slug?limit=100';
    }

    Get.toNamed(
      '/catalog',
      arguments: CatalogArgs(
        title: name,
        apiUrl: apiUrl,
        brand: _selectedCategory == 'Brands' ? name : '',
        products: const [],
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

  const _ShopTile({super.key, required this.label, this.right, this.onTap});

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