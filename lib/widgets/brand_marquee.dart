import 'package:flutter/material.dart';
import 'package:beautyontapp/widgets/asset_icon.dart';

class BrandMarquee extends StatelessWidget {
  final List<String> logos;
  const BrandMarquee({super.key, required this.logos});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.08;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 14),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 16,
        children: logos.map((p) {
          return Opacity(
            opacity: 0.35, 
            child: SizedBox(
              width: (w - pad * 2) / 3.2, 
              height: 28,
              child: AssetIcon(p, fit: BoxFit.contain),
            ),
          );
        }).toList(),
      ),
    );
  }
}
