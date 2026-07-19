import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FooterStatsRow extends StatelessWidget {
  final List<Map<String, String>> items; // 4 items expected
  const FooterStatsRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w * 0.08;
    final itemW = (w - pad * 2 - 12) / 2; // 2 per row

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 18),
      child: Wrap(
        spacing: 12,
        runSpacing: 18,
        children: List.generate(items.length, (i) {
          final e = items[i];
          return SizedBox(
            width: itemW,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.checkmark_seal, size: 28, color: Colors.white),
                const SizedBox(height: 8),
                Text(e['title']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  e['subtitle']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.25),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
