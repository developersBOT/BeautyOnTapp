import 'package:flutter/material.dart';
import 'package:beautyontapp/widgets/popular_item.dart';
import 'package:beautyontapp/widgets/asset_icon.dart';

class PopularNowGrid extends StatelessWidget {
  final List<PopularItem> items;
  const PopularNowGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.04;

    // 3 × 2 grid — per your figma section
    const gapX = 9.0;
    const gapY = 12.0;
    final itemW = (w - pad * 2 - gapX * 2) / 3;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Wrap(
        spacing: gapX,
        runSpacing: gapY,
        children: items.take(6).map((e) {
          return SizedBox(
            width: itemW,
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 95 / 84,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE6E6E6)),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    // <-- yahan tint de rahe hain taake white SVGs visible ho jayein
                    child: AssetIcon(e.imageAsset, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  e.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
