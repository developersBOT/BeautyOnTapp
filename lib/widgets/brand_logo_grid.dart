import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrandLogoGrid extends StatelessWidget {
  final List<Map<String, String>> logos;
  final void Function(String brand)? onLogoTap;

  const BrandLogoGrid({
    super.key,
    required this.logos,
    this.onLogoTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.04;
    const gap = 8.0; // Reduced from 18.0 to 8.0
    final itemW = (w - pad * 2 - gap * 2) / 3;

    Widget _logo(String asset) {
      final child = asset.toLowerCase().endsWith('.svg')
          ? SvgPicture.asset(asset, fit: BoxFit.contain)
          : Image.asset(asset, fit: BoxFit.contain);
      return Opacity(opacity: 0.35, child: child);
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 0, pad, 0),
      child: Wrap(
        spacing: gap,
        runSpacing: -20.0, // Reduced from 16.0 to 8.0
        children: logos.map((logo) {
          final brandName = logo['name'] ?? "Unknown";
          final asset = logo['asset'] ?? "";
          return SizedBox(
            width: itemW,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: InkWell(
                onTap: () {
                  print("🟢 tapped brand: $brandName");
                  onLogoTap?.call(brandName);
                },
                child: _logo(asset),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}