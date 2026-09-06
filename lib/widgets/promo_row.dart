import 'package:flutter/material.dart';
import '../widgets/promo.dart';

class PromoRow extends StatelessWidget {
  final List<Promo> items;
  final void Function(int index)? onTap;

  // Card size
  static const double _cardW = 240;
  static const double _cardH = 280;

  const PromoRow({
    super.key,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.04;
    const gap = 14.0;

    return SizedBox(
      height: _cardH,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: pad),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: gap),
        itemBuilder: (_, i) {
          final p = items[i];

          // Background colors
          final bgColors = [
            const Color(0xFFFBE4EB), // light pink
            const Color(0xFFFFF1D6), // light yellow
            const Color(0xFFEFF5F4), // light grey-green
            const Color(0xFFF1D4B9),
          ];

          return GestureDetector(
            onTap: onTap == null ? null : () => onTap!(i),
            child: Container(
              width: _cardW,
              height: _cardH,
              decoration: BoxDecoration(
                color: bgColors[i % bgColors.length],
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge, // so image clips to border radius
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section fills top
                  Expanded(
                    child: Image.asset(
                      p.imageAsset,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover, // cover full area, no side gaps
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Texts
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: onTap == null ? null : () => onTap!(i),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Text(p.cta.toUpperCase()),
                        ),
                      ],
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
