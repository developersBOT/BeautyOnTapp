import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final double width; // <-- dynamic width from scroller

  const ProductCard({super.key, required this.product, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // let height be natural
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // square image
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.asset(product.imageAsset, fit: BoxFit.cover),
            ),
          ),

          // title
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),

          // subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              product.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ),

          // rating + reviews
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
            child: Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < product.rating.round()
                        ? Icons.star
                        : Icons.star_border,
                    size: 13, // slightly smaller to avoid cramping
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '(${product.reviews})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 11.5, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'R ${product.price.toStringAsFixed(2)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
