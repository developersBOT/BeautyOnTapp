import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import '../models/product.dart';
import '../controllers/cart_controller.dart';
import '../widgets/home_header.dart';
import '../widgets/category_chips.dart';
import '../widgets/black_footer.dart';
import '../widgets/app_drawer.dart';
import '../data/static_data.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _qty = 1;
  int _variantIndex = 0; // demo variants
  final _variants = const ['100 ml', '200 ml', 'Treatment Pad'];

  @override
  Widget build(BuildContext context) {
    final arg = Get.arguments;
    final Product p = arg is Product ? arg : productsNewArrivals.first;

    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.06;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: SizedBox(width: w * 0.74, child: const AppSideDrawer()),
      body: ListView(
        children: [
          HomeHeader(
            onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            onSearch: () {},
            onCart: () => Get.toNamed('/cart'),
          ),

          CategoryChips(
            categories: topCategories,
            margin: const EdgeInsets.only(top: 10),
          ),
          const SizedBox(height: 10),

          // --- Hero image + share ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: p.imageUrl.isNotEmpty
                        ? Image.network(
                            p.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              size: 60,
                              color: Colors.grey,
                            ),
                          )
                        : Image.asset(p.imageAsset, fit: BoxFit.contain),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // --- Title + rating + price ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Stars(rating: p.rating, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '(${p.reviews} reviews)',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'R ${p.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // --- Variants ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_variants.length, (i) {
                final selected = i == _variantIndex;
                return ChoiceChip(
                  label: Text(_variants[i]),
                  selected: selected,
                  onSelected: (_) => setState(() => _variantIndex = i),
                  selectedColor: Colors.black,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: selected ? Colors.black : const Color(0xFFE0E0E0),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // --- Quantity + Add to cart ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Row(
              children: [
                _QtyStepper(
                  qty: _qty,
                  onMinus: () =>
                      setState(() => _qty = (_qty > 1) ? _qty - 1 : 1),
                  onPlus: () => setState(() => _qty++),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    onPressed: () async {
                      try {
                        final variantId = _variants[_variantIndex]; // Use demo variant as ID (adjust if real IDs available)
                        final variantTitle = _variants[_variantIndex];
                        await CartController.to.addToCart(
                          variantId,
                          _qty,
                          p,
                          variantTitle: variantTitle,
                        );
                        Get.snackbar(
                          'Cart',
                          'Added ${p.title} to cart',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } catch (_) {
                        Get.snackbar(
                          'Cart',
                          'Failed to add to cart',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    child: const Text(
                      'ADD TO CART',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  try {
                    final variantId = _variants[_variantIndex]; // Use demo variant as ID
                    final variantTitle = _variants[_variantIndex];
                    CartController.to.addToCart(
                      variantId,
                      _qty,
                      p,
                      variantTitle: variantTitle,
                    );
                  } catch (_) {
                    // Handle any errors if needed
                  }
                  Get.toNamed('/cart'); // Navigate to the cart screen
                },
                child: const Text(
                  'BUY IT NOW',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // --- Description (placeholder) ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'Glow, Dew & That Butter Treat for Dry, Dull Skin.\n\n'
                  'A rich body lotion with Niacinamide to brighten, even tone and lock in moisture...',
                  style: TextStyle(fontSize: 13.5, height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // --- Customer Reviews (mock) ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Reviews',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Stars(rating: p.rating, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${p.rating.toStringAsFixed(1)} average',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- You may also like ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: const Text(
              'You may also like',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          _MiniScroller(list: productsChosenForYou),

          const SizedBox(height: 16),

          // --- Recently viewed ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: const Text(
              'Recently viewed products',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          _MiniScroller(list: productsNewArrivals),

          const SizedBox(height: 20),

          const BlackFooter(),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const _QtyStepper({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove),
            splashRadius: 20,
          ),
          Text(
            '$qty',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final double rating;
  final double size;
  const _Stars({required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    return Row(
      children: List.generate(5, (i) {
        if (i < full) {
          return Icon(Icons.star, size: size, color: Colors.amber[700]);
        } else if (i == full && half) {
          return Icon(Icons.star_half, size: size, color: Colors.amber[700]);
        }
        return Icon(Icons.star_border, size: size, color: Colors.amber[700]);
      }),
    );
  }
}

class _MiniScroller extends StatelessWidget {
  final List<Product> list;
  const _MiniScroller({required this.list});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.06;
    return SizedBox(
      height: 210,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: pad),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final p = list[i];
          return SizedBox(
            width: 140,
            child: InkWell(
              onTap: () => Get.toNamed('/product', arguments: p),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: p.imageUrl.isNotEmpty
                          ? Image.network(p.imageUrl, fit: BoxFit.contain)
                          : Image.asset(p.imageAsset, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R ${p.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}