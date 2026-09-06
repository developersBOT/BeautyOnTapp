import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'popular_item.dart';

class PopularNowScroller extends StatelessWidget {
  final List<PopularItem> items;
  final void Function(int index)? onTap;

  // Figma exact size
  static const double _cardW = 95;
  static const double _cardH = 84;

  const PopularNowScroller({
    super.key,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.04;
    const gap = 10.0;

    return SizedBox(
      height: _cardH,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: pad),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: gap),
        itemBuilder: (_, i) {
          final it = items[i];
          return GestureDetector(
            onTap: onTap == null ? null : () => onTap!(i),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // icon
                  Expanded(child: _PopularIcon(asset: it.imageAsset)),
                  const SizedBox(height: 6),
                  // text inside the card
                  Text(
                    it.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
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

class _PopularIcon extends StatelessWidget {
  final String asset;
  const _PopularIcon({required this.asset});

  @override
  Widget build(BuildContext context) {
    if (asset.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(asset, fit: BoxFit.contain);
    }
    return Image.asset(asset, fit: BoxFit.contain);
  }
}
