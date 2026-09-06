// lib/widgets/popular_now_cards_scroller.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:beautyontapp/widgets/popular_item.dart';

class PopularNowCardsScroller extends StatelessWidget {
  final List<PopularItem> items;
  final void Function(int index)? onTap;

  const PopularNowCardsScroller({
    super.key,
    required this.items,
    this.onTap,
  });

  bool _isSvg(String path) => path.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.04;
    const gap = 12.0;

    // 3 cards on screen, horizontally scrollable
    final cardW = (w - pad * 2 - gap * 2) / 3;
    const cardH = 132.0;

    return SizedBox(
      height: cardH, // text is INSIDE the card now
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
              width: cardW,
              height: cardH,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9E9E9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // icon/image area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _isSvg(it.imageAsset)
                          ? SvgPicture.asset(
                              it.imageAsset,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            )
                          : Image.asset(
                              it.imageAsset,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            ),
                    ),
                  ),
                  // title INSIDE card
                  Text(
                    it.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.5,
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
