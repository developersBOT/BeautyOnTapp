import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductScroller extends StatelessWidget {
  final List<Product> products;
  final void Function(Product p)? onTap;

  static const double _cardW = 150;
  static const double _cardH = 210;

  const ProductScroller({
    super.key,
    required this.products,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.04;
    const gap = 12.0;

    return SizedBox(
      height: _cardH,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: pad),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: gap),
        itemBuilder: (_, i) {
          final p = products[i];

          return GestureDetector(
            onTap: onTap == null ? null : () => onTap!(p),
            child: Container(
              width: _cardW,
              height: _cardH,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9E9E9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Show network image if available
                  SizedBox(
                    height: 115,
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: p.imageUrl.isNotEmpty
                            ? Image.network(
                                p.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              )
                            : Image.asset(p.imageAsset, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  _MiniStars(rating: p.rating, size: 12),
                  const SizedBox(height: 2),
                  Text(
                    'R ${p.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
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

class _MiniStars extends StatelessWidget {
  final double rating;
  final double size;
  const _MiniStars({required this.rating, this.size = 12});

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
